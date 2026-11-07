# Disciplaner

Disciplaner is a self-hostable project management application inspired by Jira and Linear, powered by a robust **ASP.NET Core 10** REST API backend and a **modern multiplatform Flutter client** (Web, Desktop Windows/macOS/Linux, and Mobile Android/iOS). Data is persisted in **PostgreSQL** (prioritized when configured or via `DATABASE_URL`) with an automatic zero-config fallback to **SQLite**. The Flutter client implements the **Neo-Linear** design system with a clean, high-density keyboard-first UX.

## Table of Contents

- [Architecture](#architecture)
- [Multiplatform Flutter Client](#multiplatform-flutter-client)
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
Disciplaner.Infrastructure  ← EF Core (PostgreSQL + SQLite fallback), ASP.NET Core Identity, repositories
Disciplaner.Web/
  Server/                   ← ASP.NET Core 10 REST API (+ optional static host for the Flutter web build)
src/Disciplaner.Flutter/    ← Multiplatform Flutter client (Web, Desktop & Mobile)
```

The application is powered by an ASP.NET Core 10 REST API and consumed seamlessly by the Flutter client (`src/Disciplaner.Flutter`), the single frontend of the project. On first startup EF Core migrations are applied automatically. If no admin seed credentials are supplied, the application enters **setup mode** and exposes a `/setup` wizard (also available in the Flutter client) to create the first administrator account.

---

## Multiplatform Flutter Client

The unified Flutter client is located in `src/Disciplaner.Flutter/`. It features:
- **Neo-Linear Design System**: High-density typography (*Plus Jakarta Sans* / *JetBrains Mono*), minimal borders, subtle shadows and warm cream tones (`#FDFBF7` / `#1A1917` / `#E5A800`).
- **Adaptive Shell**: Responsive switching between the VS Code style activity bar with workspace tabs (desktop) and mobile ergonomics with bottom navigation.
- **Speed & Shortcuts**: Global Command Palette (`⌘K` / `Ctrl+K`), quick ticket creation modal (`C`).
- **Interactive Kanban**: Drag & drop multiplatform board with cycle filters and real-time WIP metrics.
- **Team Calendar & iCal**: Monthly sprint roadmap, ticket deadlines, and private iCal feed subscription (`/ical/{token}`).
- **Administration & Homelab**: Server base URL discovery, invitation link generation (7 days), and account management.

For full development, compilation commands, and Homelab reverse-proxy guides, see [Flutter Client Documentation](docs/flutter-migration/README.md).

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
- **MCP connector** — AI assistants (Mistral Le Chat, ChatGPT, Claude Desktop, Cursor, ...) can browse and manage your projects through the Model Context Protocol endpoint `/mcp`, authenticated via OAuth 2.1 (RFC 9728 discovery, PKCE S256) or revocable personal access Bearer tokens (read or read+write); see the [MCP connector documentation](docs/mcp-connector/README.md) and the [chat clients connection guide](docs/mcp-connector/03-connexion-clients-chat.md)
- **JWT authentication** — stateless Bearer tokens; configurable issuer, audience, expiry
- **Swagger UI** — available in development mode at `/swagger`
- **Docker** — multi-stage Dockerfile, single container, SQLite database persisted to a named volume
- **Internationalisation** — French (default) and English ARB resources in the Flutter client (`app_fr.arb` / `app_en.arb`)

---

## Quick Start with Docker

The image is published to GitHub Container Registry on every `vX.Y.Z` tag. It bundles **both the REST API and the Flutter web client**: a single container serves the web front from the same origin as the API (no CORS needed), while mobile and desktop clients consume the same REST API.

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

The application is then available at [http://localhost:8080](http://localhost:8080): a public home page presents the product and invites the visitor to authenticate; the REST API (`/api/…`) is served by the same process for the mobile and desktop clients.

To serve the web front from a separate static host instead (advanced setup):

```bash
cd src/Disciplaner.Flutter
flutter build web --release
```

Serve `build/web/` with nginx or any static server behind the same reverse proxy, and set `Cors__Origins__0` to the client origin on the API container.

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

A ready-to-use `compose.yml` is provided at the repository root. It builds the local image (API + web front) and persists data to a named volume:

```bash
cp .env.example .env   # then fill in JWT_SECRET_KEY
docker compose up -d
```

The stack is then available at [http://localhost:8080](http://localhost:8080).

Create a `.env` file alongside it (never commit this file):

```env
JWT_SECRET_KEY=replace_with_a_random_string_of_at_least_48_characters
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=YourStr0ngPassword!
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
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Web, Desktop & Mobile client)

### Running the application

#### One-command dev script

The repository root provides a script that starts both the API and the Flutter client, waits for the API to be up, and tears everything down on `Ctrl+C`:

```bash
# Windows (PowerShell) — opens the Flutter web client in Chrome
./dev.ps1

# Windows (cmd)
dev.cmd

# Git Bash / Linux / macOS
./dev.sh

# Options: desktop client instead of the web, custom ports
./dev.ps1 -Device windows
API_PORT=5027 WEB_PORT=5000 ./dev.sh
```

The script injects a development JWT secret (your `dotnet user-secrets` take precedence if set) and points the client at the local API via `DISCIPLAN_API_URL`.

#### Manual setup

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

The API is then available at `http://localhost:<port>` (the exact port is printed on startup; the Flutter client defaults to `http://localhost:5000`).

Start the Flutter client against it:

```bash
cd src/Disciplaner.Flutter
flutter run -d chrome   # or: -d windows / -d macos / -d linux
```

> **First run without seed credentials:** the Flutter client opens its `/setup` wizard to create the first administrator account. The endpoint is disabled once an admin user exists.

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

The multi-stage `Dockerfile` builds the Flutter web client, publishes the .NET API, and assembles a single runtime image serving both:

```bash
# From the repository root
docker build -t disciplaner:local .

# Quick smoke test (API + web front at http://localhost:8080)
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
