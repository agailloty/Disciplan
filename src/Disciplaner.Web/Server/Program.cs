using System.Text;
using Disciplaner.Infrastructure;
using Disciplaner.Infrastructure.Data;
using Disciplaner.Infrastructure.Identity;
using Disciplaner.Web.Server.Identity;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// ── Database ──────────────────────────────────────────────────────────────────
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Data Source=disciplaner.db";

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(connectionString));

// ── Identity (Core only — no cookie middleware for API) ───────────────────────
builder.Services.AddIdentityCore<ApplicationUser>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
})
.AddRoles<IdentityRole>()
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// ── JWT ───────────────────────────────────────────────────────────────────────
builder.Services.Configure<JwtSettings>(
    builder.Configuration.GetSection(JwtSettings.SectionName));
builder.Services.AddScoped<JwtTokenService>();

var jwtSettings = builder.Configuration.GetSection(JwtSettings.SectionName).Get<JwtSettings>()
    ?? throw new InvalidOperationException("JWT settings are not configured.");

if (string.IsNullOrWhiteSpace(jwtSettings.SecretKey)
    || jwtSettings.SecretKey.Length < 32
    || jwtSettings.SecretKey.Contains("REPLACE"))
    throw new InvalidOperationException(
        "Jwt:SecretKey must be at least 32 characters and must not be the placeholder value. " +
        "Set the environment variable Jwt__SecretKey=<your-secret>.");

// AdminSeed credentials are optional — if absent or placeholder, the application enters
// first-run mode and the /api/setup endpoint allows creating the first admin account.

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidateAudience         = true,
            ValidateLifetime         = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer              = jwtSettings.Issuer,
            ValidAudience            = jwtSettings.Audience,
            IssuerSigningKey         = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings.SecretKey)),
            ClockSkew = TimeSpan.Zero // no grace period on token expiry
        };
    });

builder.Services.AddAuthorization();

// ── Infrastructure + Application services ────────────────────────────────────
builder.Services.AddInfrastructure();

// ── CORS ─────────────────────────────────────────────────────────────────────
// Configured via Cors:Origins in appsettings / env vars (CORS__ORIGINS__0=https://…).
// In development, falls back to the Blazor WASM dev-server addresses.
// In a production hosted-WASM deployment the client is same-origin, so CORS is
// not needed for the SPA — set Cors:Origins only when an external client (mobile
// app, another frontend) also consumes the API.
var corsOrigins = builder.Configuration.GetSection("Cors:Origins").Get<string[]>();
if (corsOrigins is null && builder.Environment.IsDevelopment())
    corsOrigins = ["http://localhost:5027", "https://localhost:7250",
                   "http://localhost:5000", "https://localhost:5001"];

if (corsOrigins?.Length > 0)
{
    builder.Services.AddCors(options =>
        options.AddDefaultPolicy(policy =>
            policy.WithOrigins(corsOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()));
}

// ── Controllers + Swagger ─────────────────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// ── Startup: apply pending migrations, then seed roles + admin ────────────────
await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await db.Database.MigrateAsync();
}
await IdentitySeeder.SeedAsync(app.Services, app.Configuration);

// ── Middleware pipeline ───────────────────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();
if (corsOrigins?.Length > 0)
    app.UseCors();
app.UseBlazorFrameworkFiles();   // serve _framework/ files from Client WASM
app.UseStaticFiles();            // serve wwwroot of both Server and Client
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapFallbackToFile("index.html"); // SPA fallback — all non-API routes → Client

app.Run();
