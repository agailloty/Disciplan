namespace Disciplaner.Application.DTOs.Auth;

/// <summary>Response for the GET /api/setup/status endpoint.</summary>
public sealed record SetupStatusResponse(bool SetupRequired);
