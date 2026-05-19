# Disciplaner

Disciplaner is a self-hostable project management application inspired by Jira and Linear, built with **Blazor WebAssembly** (client) and **ASP.NET Core 10** (API + host). Data is persisted in a **SQLite** database. The UI is styled with **Tailwind CSS** and **Bootstrap Icons** and is available in **French** (default) and **English**.

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Quick Start with Docker](#quick-start-with-docker)
- [Environment Variables](#environment-variables)
- [Docker Compose](#docker-compose)
- [Local Development](#local-development)
- [Building the Docker Image](#building-the-docker-image)

---

## Architecture

```
Disciplaner.Domain          ← Entities, business rules, value objects, domain exceptions
Disciplaner.Application     ← Services, DTOs, mappings (MediatR-free CQRS-lite)
Disciplaner.Infrastructure  ← EF Core + SQLite, ASP.NET Core Identity, repositories
Disciplaner.Web/
  Client/                   ← Blazor WebAssembly SPA (Tailwind CSS, Bootstrap Icons)
  Server/                   ← ASP.NET Core (REST API + static WASM host)
```

The application is a **hosted Blazor WASM** project: the server serves both the REST API and the compiled client-side SPA. On first startup EF Core migrations are applied automatically. If no admin seed credentials are supplied, the application enters **setup mode** and exposes a `/setup` wizard to create the first administrator account.

---

## Features

### Projects & Tickets
- **Projects** — created with a short unique key (e.g. `DISC`), optional description, automatic sequential ticket numbering, configurable default ticket type and default-assignee policy
- **Custom workflows** — each project defines its own ticket statuses with a status category (To Do / In Progress / Done)
- **Tickets** — five types: **Story**, **Bug**, **Task**, **Epic**, **Subtask**; four priorities; story points; due date; rich-text description; parent ticket (subtask hierarchy)
- **Assignment & comments** — tickets can be assigned to project members; threaded comments per ticket
- **Labels** — color-coded labels created per board, attachable to tickets
- **Ticket history** — every field change (title, description, status, type, priority, assignee, sprint, story points, due date) and comment event is recorded in a per-ticket audit trail

### Boards & Sprints
- **Boards** — personal Kanban boards with drag-and-drop columns and cards; independent of projects; own member list and labels
- **Sprints** — Planned / Active / Closed lifecycle; tickets can be assigned to a sprint or left in the backlog; dedicated sprint view with a ticket board

### Personal Views
- **My Tickets** — personal inbox showing all tickets assigned to or reported by the current user, grouped by status category
- **Saved Views** — user-defined filtered views (filter by project, sprint, status, type, priority, status category, assigned-to-me, reported-by-me); pinnable to the home dashboard

### Settings
- **Profile** — update display name
- **Appearance** — light / dark / custom theme with CSS variable overrides
- **Dashboard** — choose which saved views appear on the home page and in which order

### Access Control & Administration
- **Role system** — four roles per board and per project: **Guest** (read-only), **Member**, **Supervisor**, **Admin**; the resource owner always has Admin rights
- **User invitations** — admins generate single-use invitation links (valid 7 days); recipients register via the link without an open registration endpoint
- **Admin panel** — activate / deactivate user accounts, promote users to application Admin role

### Developer & Operations
- **JWT authentication** — stateless Bearer tokens; configurable issuer, audience, expiry
- **Swagger UI** — available in development mode at `/swagger`
- **Docker** — multi-stage Dockerfile, single container, SQLite database persisted to a named volume
- **Internationalisation** — resource files for French (default) and English (`AppResources.resx` / `AppResources.en.resx`)

---

## Quick Start with Docker

The image is published to GitHub Container Registry on every `vX.Y.Z` tag.

```bash
docker run -d \
  --name disciplaner \
  -p 8080:8080 \
  -v disciplaner-data:/data \
  -e Jwt__SecretKey="<secret_at_least_32_characters>" \
  -e AdminSeed__Email="admin@example.com" \
  -e AdminSeed__Password="YourStr0ngPassword!" \
  ghcr.io/agailloty/disciplan:latest
```

The application is then available at [http://localhost:8080](http://localhost:8080).

> **Note:** the `/data` volume holds the SQLite database. Mount it to a named volume or host directory to persist data across container restarts.

---

## Environment Variables

All sensitive values must be supplied at runtime via environment variables. The application will refuse to start if required variables are missing or still contain their placeholder defaults.

| Variable | Required | Description |
|---|---|---|
| `Jwt__SecretKey` | ✅ | HMAC-SHA256 secret key, minimum 32 characters |
| `Jwt__Issuer` | no | JWT token issuer (default: `Disciplaner`) |
| `Jwt__Audience` | no | JWT token audience (default: `Disciplaner`) |
| `Jwt__ExpiryMinutes` | no | Token validity duration in minutes (default: `60`) |
| `AdminSeed__Email` | ✅ | E-mail address for the admin account created on first startup |
| `AdminSeed__Password` | ✅ | Admin password (min. 8 chars, uppercase, lowercase, digit) |
| `ConnectionStrings__DefaultConnection` | no | SQLite connection string (default: `Data Source=/data/disciplaner.db`) |
| `Cors__Origins__0` | no | Allowed CORS origin (e.g. `https://my-domain.com`) |

> The `__` separator is the ASP.NET Core configuration hierarchy delimiter (equivalent to `:` in `appsettings.json`).

### Generate a secure JWT key

```bash
# Linux / macOS
openssl rand -base64 48

# PowerShell
[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Max 256 }))
```

---

## Docker Compose

Example `compose.yml` for a full deployment:

```yaml
services:
  disciplaner:
    image: ghcr.io/agailloty/disciplan:latest
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - disciplaner-data:/data
    environment:
      Jwt__SecretKey: "${JWT_SECRET_KEY}"
      Jwt__Issuer: "Disciplaner"
      Jwt__Audience: "Disciplaner"
      AdminSeed__Email: "${ADMIN_EMAIL}"
      AdminSeed__Password: "${ADMIN_PASSWORD}"
      # Uncomment if a reverse proxy terminates TLS upstream
      # ASPNETCORE_FORWARDEDHEADERS_ENABLED: "true"

volumes:
  disciplaner-data:
```

Create a `.env` file alongside it (never commit this file):

```env
JWT_SECRET_KEY=replace_with_a_random_string_of_at_least_48_characters
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=YourStr0ngPassword!
```

Then start the stack:

```bash
docker compose up -d
```

### Behind a reverse proxy (Nginx, Traefik…)

The image listens on port **8080** over HTTP. Terminate TLS at the reverse proxy level. Minimal Traefik example:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.disciplaner.rule=Host(`disciplaner.my-domain.com`)"
  - "traefik.http.routers.disciplaner.entrypoints=websecure"
  - "traefik.http.routers.disciplaner.tls.certresolver=letsencrypt"
  - "traefik.http.services.disciplaner.loadbalancer.server.port=8080"
```

---

## Local Development

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- Blazor WASM workload: `dotnet workload install wasm-tools`

### Running the application

```bash
cd src/Disciplaner.Web/Server

# Required: set a JWT secret (min. 32 characters, no placeholder)
dotnet user-secrets set "Jwt:SecretKey" "dev_secret_key_min_32_chars_xxxxxx"

# Optional: seed an admin account on first startup
# If omitted, a setup wizard is available at /setup on first run
dotnet user-secrets set "AdminSeed:Email" "admin@local.dev"
dotnet user-secrets set "AdminSeed:Password" "Admin1234!"

dotnet run
```

The API and the Blazor client are available at `https://localhost:<port>` (the exact port is printed on startup).

> **First run without seed credentials:** navigate to `/setup` and complete the wizard to create the first administrator account. The endpoint is disabled once an admin user exists.

### EF Core migrations

Migrations are applied automatically on startup. To create a new one:

```bash
cd src
dotnet ef migrations add MigrationName \
  --project Disciplaner.Infrastructure \
  --startup-project Disciplaner.Web/Server
```

---

## Building the Docker Image

```bash
# From the repository root
docker build -t disciplaner:local .

# Quick smoke test
docker run --rm \
  -p 8080:8080 \
  -v disciplaner-data:/data \
  -e Jwt__SecretKey="local_dev_secret_key_at_least_32_chars!" \
  -e AdminSeed__Email="admin@local.dev" \
  -e AdminSeed__Password="Admin1234!" \
  disciplaner:local
```

### Automated publishing (CI/CD)

The `.github/workflows/docker.yml` workflow automatically publishes the image to `ghcr.io` on every Git tag matching `vX.Y.Z`:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The produced image tags are: `v1.0.0`, `v1.0`, and `sha-<commit>`.
