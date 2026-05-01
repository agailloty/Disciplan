# Disciplaner

Disciplaner is a self-hostable, Jira-like project management application built with **Blazor WebAssembly** (client) and **ASP.NET Core 10** (API + host). Data is persisted in a **SQLite** database.

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
Disciplaner.Domain          ← Entities, business rules, interfaces
Disciplaner.Application     ← Services, DTOs, mappings
Disciplaner.Infrastructure  ← EF Core, SQLite, Identity, repositories
Disciplaner.Web/
  Client/                   ← Blazor WebAssembly (SPA)
  Server/                   ← ASP.NET Core (REST API + WASM host)
```

The application is a **hosted Blazor WASM** project: the server serves both the REST API and the static files for the client. On first startup, EF Core migrations are applied automatically and an administrator account is seeded.

---

## Features

- **Projects** — create with a short key (e.g. `DISC`), customisable statuses, automatic ticket numbering
- **Tickets** — types (Bug, Feature…), priorities, assignment, comments
- **Boards** — drag-and-drop columns, Kanban view
- **Sprints** — planning and tracking
- **JWT authentication** — registration / login, Admin / User roles
- **Swagger UI** — available in development mode at `/swagger`

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

# Set development secrets
dotnet user-secrets set "Jwt:SecretKey" "dev_secret_key_min_32_chars_xxxxxx"
dotnet user-secrets set "AdminSeed:Email" "admin@local.dev"
dotnet user-secrets set "AdminSeed:Password" "Admin1234!"

dotnet run
```

The API and the Blazor client are available at `https://localhost:7xxx` (the exact port is printed on startup).

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
