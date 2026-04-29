using Disciplaner.Web.Client;
using Disciplaner.Web.Client.Auth;
using Disciplaner.Web.Client.Services;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

// Base URL of the API server (defaults to same origin for homelab hosted setup)
var apiBase = builder.Configuration["ApiBaseUrl"];
if (string.IsNullOrWhiteSpace(apiBase))
    apiBase = builder.HostEnvironment.BaseAddress;
if (!apiBase.EndsWith('/'))
    apiBase += "/";

// ── Auth ──────────────────────────────────────────────────────────────────────
builder.Services.AddScoped<TokenStorageService>();
builder.Services.AddScoped<JwtAuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp =>
    sp.GetRequiredService<JwtAuthStateProvider>());
builder.Services.AddAuthorizationCore();
builder.Services.AddScoped<AuthHttpMessageHandler>();

// ── HTTP clients ──────────────────────────────────────────────────────────────
// "Public"  — unauthenticated, used only for /api/auth/* endpoints
builder.Services.AddHttpClient("Public", c => c.BaseAddress = new Uri(apiBase));

// "Api"     — carries the JWT Bearer header via AuthHttpMessageHandler
builder.Services.AddHttpClient("Api", c => c.BaseAddress = new Uri(apiBase))
    .AddHttpMessageHandler<AuthHttpMessageHandler>();

// ── Application services ──────────────────────────────────────────────────────
builder.Services.AddScoped<AuthApiClient>();
builder.Services.AddScoped<BoardApiClient>();
builder.Services.AddScoped<ColumnApiClient>();
builder.Services.AddScoped<CardApiClient>();
builder.Services.AddScoped<CommentApiClient>();
builder.Services.AddScoped<ProjectApiClient>();
builder.Services.AddScoped<SprintApiClient>();
builder.Services.AddScoped<TicketApiClient>();
builder.Services.AddScoped<KanbanDragState>();

await builder.Build().RunAsync();
