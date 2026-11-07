using System.Text;
using Disciplaner.Application;
using Disciplaner.Infrastructure;
using Disciplaner.Infrastructure.Data;
using Disciplaner.Infrastructure.Identity;
using Disciplaner.Mcp;
using Disciplaner.Web.Server.Identity;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// ── Database (PostgreSQL prioritized, fallback to SQLite) ─────────────────────
builder.Services.AddDisciplanerDatabase(builder.Configuration);

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
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = async context =>
            {
                var users = context.HttpContext.RequestServices.GetRequiredService<UserManager<ApplicationUser>>();
                var user = context.Principal is null ? null : await users.GetUserAsync(context.Principal);
                if (user is null || !user.IsActive) context.Fail("Account is inactive or missing.");
            }
        };
    });

builder.Services.AddAuthorization();

// ── Infrastructure + Application services ────────────────────────────────────
builder.Services.AddInfrastructure();

// ── MCP connector (PAT-authenticated /mcp endpoint) ──────────────────────────
builder.Services.AddDisciplanerMcp(builder.Configuration);

// ── File storage ──────────────────────────────────────────────────────────────
builder.Services.Configure<FileStorageOptions>(
    builder.Configuration.GetSection(FileStorageOptions.SectionName));

// Allow up to 50 MB multipart uploads (matches MaxFileSizeBytes default)
builder.Services.Configure<Microsoft.AspNetCore.Http.Features.FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = 52_428_800;
});

// ── CORS ─────────────────────────────────────────────────────────────────────
// Configured via Cors:Origins in appsettings / env vars (CORS__ORIGINS__0=https://…).
// In development, falls back to the typical local dev-server addresses.
// Set Cors:Origins when an external client (mobile app, a Flutter web build
// hosted on another origin) consumes the API; a Flutter web build copied into
// wwwroot is same-origin and needs no CORS.
var corsOrigins = builder.Configuration.GetSection("Cors:Origins").Get<string[]>();
if (corsOrigins is null && builder.Environment.IsDevelopment())
    corsOrigins = ["http://localhost:5000", "https://localhost:5001",
                   "http://localhost:5027", "https://localhost:7250"];

if (corsOrigins?.Length > 0)
{
    builder.Services.AddCors(options =>
        options.AddDefaultPolicy(policy =>
            policy.WithOrigins(corsOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()));
}

// ── Forwarded headers (reverse proxy / tunnel) ─────────────────────────────────
// The server listens on a plain HTTP port behind a TLS-terminating reverse proxy
// (or tunnel). Honor X-Forwarded-Proto/Host so URLs built from the request —
// notably the MCP OAuth discovery documents (RFC 9728/8414) — use the public
// https:// scheme instead of the internal http:// one. Disable with
// ForwardedHeaders:Enabled=false when the app is exposed directly.
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    // Every connection arrives through the proxy (the container port is not
    // published directly), so accept forwarded headers from any source.
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});
var useForwardedHeaders = builder.Configuration.GetValue("ForwardedHeaders:Enabled", true);

// ── Controllers + Swagger ─────────────────────────────────────────────────────
builder.Services.AddControllers(options => options.Filters.Add<Disciplaner.Web.Server.ApiExceptionFilter>());
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
if (useForwardedHeaders)
    app.UseForwardedHeaders();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();
if (corsOrigins?.Length > 0)
    app.UseCors();
app.UseStaticFiles();            // serve wwwroot (e.g. a Flutter web build copied in)
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();
app.MapControllers();
app.MapDisciplanerMcp("/mcp");
app.MapFallbackToFile("index.html"); // SPA fallback — deep links of the hosted Flutter web client

app.Run();

// Expose the entry point to the isolated API integration test host.
public partial class Program { }
