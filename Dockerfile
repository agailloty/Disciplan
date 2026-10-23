# ── Stage 1: Flutter web client ───────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS web
WORKDIR /client

# Copy manifests first for optimal layer caching on pub get
COPY src/Disciplaner.Flutter/pubspec.yaml src/Disciplaner.Flutter/pubspec.lock ./
RUN flutter pub get

# Copy remaining client source and build the release web bundle
COPY src/Disciplaner.Flutter/ .
# No DISCIPLAN_API_URL define: on the web the client defaults to the current
# origin (same-origin API), which is how the container serves both.
RUN flutter build web --release

# ── Stage 2: build the .NET API ──────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files first for optimal layer caching on restore
COPY Disciplaner.slnx ./
COPY src/Disciplaner.Domain/Disciplaner.Domain.csproj                 src/Disciplaner.Domain/
COPY src/Disciplaner.Application/Disciplaner.Application.csproj       src/Disciplaner.Application/
COPY src/Disciplaner.Infrastructure/Disciplaner.Infrastructure.csproj src/Disciplaner.Infrastructure/
COPY src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj         src/Disciplaner.Web/Server/

RUN dotnet restore src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj

# Copy remaining source and publish
COPY src/ src/

RUN dotnet publish src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ── Stage 3: runtime (API + web front in a single container) ─────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# /data is the mount point for the SQLite database and uploaded files
RUN mkdir -p /data /data/uploads && chown $APP_UID /data /data/uploads
VOLUME ["/data"]

COPY --from=build /app/publish .

# Serve the Flutter web build from wwwroot (same origin as the API, SPA
# fallback to index.html). Mobile and desktop clients keep consuming the
# same REST API on this container's port.
COPY --from=web /client/build/web ./wwwroot

# Override the connection string to point at the persisted volume
ENV ConnectionStrings__DefaultConnection="Data Source=/data/disciplaner.db"

# ASP.NET Core listens on 8080 by default in container images (.NET 8+)
EXPOSE 8080

# Run as the non-root app user supplied by the base image
USER $APP_UID

ENTRYPOINT ["dotnet", "Disciplaner.Web.Server.dll"]
