# ── Stage 1: build ────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files first for optimal layer caching on restore
COPY Disciplaner.slnx .
COPY src/Disciplaner.Domain/Disciplaner.Domain.csproj                 src/Disciplaner.Domain/
COPY src/Disciplaner.Application/Disciplaner.Application.csproj       src/Disciplaner.Application/
COPY src/Disciplaner.Infrastructure/Disciplaner.Infrastructure.csproj src/Disciplaner.Infrastructure/
COPY src/Disciplaner.Web/Client/Disciplaner.Web.Client.csproj         src/Disciplaner.Web/Client/
COPY src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj         src/Disciplaner.Web/Server/

RUN dotnet workload restore src/Disciplaner.Web/Client/Disciplaner.Web.Client.csproj

RUN dotnet restore src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj

# Copy remaining source and publish
COPY src/ src/

RUN dotnet publish src/Disciplaner.Web/Server/Disciplaner.Web.Server.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# /data is the mount point for the SQLite database volume
RUN mkdir -p /data && chown $APP_UID /data
VOLUME ["/data"]

COPY --from=build /app/publish .

# Override the connection string to point at the persisted volume
ENV ConnectionStrings__DefaultConnection="Data Source=/data/disciplaner.db"

# ASP.NET Core listens on 8080 by default in container images (.NET 8+)
EXPOSE 8080

# Run as the non-root app user supplied by the base image
USER $APP_UID

ENTRYPOINT ["dotnet", "Disciplaner.Web.Server.dll"]
