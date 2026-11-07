using System.Net;
using System.Text.Encodings.Web;

namespace Disciplaner.Mcp.OAuth;

/// <summary>
/// Renders an ergonomic, responsive HTML consent and login interface for OAuth 2.1 authorization requests.
/// </summary>
public static class McpOAuthConsentPage
{
    public static string Render(
        string clientName,
        string scope,
        string redirectUri,
        string state,
        string clientId,
        string codeChallenge,
        string codeChallengeMethod,
        string? currentUserEmail = null,
        string? errorMessage = null)
    {
        var encoder = HtmlEncoder.Default;
        var safeClient = encoder.Encode(clientName);
        var safeScope = encoder.Encode(scope);
        var safeRedirect = encoder.Encode(redirectUri);
        var safeState = encoder.Encode(state ?? string.Empty);
        var safeClientId = encoder.Encode(clientId);
        var safeChallenge = encoder.Encode(codeChallenge);
        var safeMethod = encoder.Encode(codeChallengeMethod);
        var safeUser = currentUserEmail != null ? encoder.Encode(currentUserEmail) : null;
        var safeError = errorMessage != null ? encoder.Encode(errorMessage) : null;

        var isReadWrite = string.Equals(scope, "read+write", StringComparison.OrdinalIgnoreCase);

        var scopeDetails = isReadWrite
            ? "Accès complet en lecture et écriture (consulter les projets, tickets, sprints et effectuer des modifications pour votre compte)."
            : "Accès en lecture seule (consulter les projets, tickets, sprints et commentaires sans modification).";

        var userSection = safeUser != null
            ? $"""
                <div class="user-badge">
                    <span>Connecté en tant que <strong>{safeUser}</strong></span>
                </div>
              """
            : $"""
                <div class="input-group">
                    <label for="email">Adresse e-mail</label>
                    <input type="email" id="email" name="email" required placeholder="nom@exemple.com" autocomplete="username" />
                </div>
                <div class="input-group">
                    <label for="password">Mot de passe</label>
                    <input type="password" id="password" name="password" required placeholder="••••••••" autocomplete="current-password" />
                </div>
              """;

        var errorSection = safeError != null
            ? $"""<div class="alert error">{safeError}</div>"""
            : string.Empty;

        return $$"""
            <!DOCTYPE html>
            <html lang="fr">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Autorisation — Disciplaner MCP</title>
                <style>
                    :root {
                        --primary: #2563eb;
                        --primary-hover: #1d4ed8;
                        --bg: #0f172a;
                        --card-bg: #1e293b;
                        --border: #334155;
                        --text: #f8fafc;
                        --text-muted: #94a3b8;
                        --danger: #ef4444;
                        --danger-bg: #450a0a;
                        --badge-bg: #0369a1;
                    }
                    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
                    body {
                        background-color: var(--bg);
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-height: 100vh;
                        padding: 1.5rem;
                    }
                    .card {
                        background: var(--card-bg);
                        border: 1px solid var(--border);
                        border-radius: 1rem;
                        max-width: 480px;
                        width: 100%;
                        padding: 2rem;
                        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
                    }
                    .brand {
                        display: flex;
                        align-items: center;
                        gap: 0.75rem;
                        margin-bottom: 1.5rem;
                    }
                    .brand-logo {
                        width: 40px;
                        height: 40px;
                        background: linear-gradient(135deg, #3b82f6, #1d4ed8);
                        border-radius: 0.5rem;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-weight: bold;
                        font-size: 1.25rem;
                        color: white;
                    }
                    .brand-title {
                        font-size: 1.25rem;
                        font-weight: 700;
                        color: var(--text);
                    }
                    h1 {
                        font-size: 1.25rem;
                        margin-bottom: 0.5rem;
                        line-height: 1.4;
                    }
                    p.desc {
                        color: var(--text-muted);
                        font-size: 0.95rem;
                        margin-bottom: 1.5rem;
                    }
                    .scope-box {
                        background: rgba(15, 23, 42, 0.6);
                        border: 1px solid var(--border);
                        border-radius: 0.5rem;
                        padding: 1rem;
                        margin-bottom: 1.5rem;
                    }
                    .scope-header {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 0.5rem;
                    }
                    .scope-badge {
                        background: var(--badge-bg);
                        color: #e0f2fe;
                        font-size: 0.75rem;
                        font-weight: 600;
                        padding: 0.2rem 0.5rem;
                        border-radius: 9999px;
                        text-transform: uppercase;
                    }
                    .scope-desc {
                        font-size: 0.875rem;
                        color: var(--text-muted);
                        line-height: 1.4;
                    }
                    .alert.error {
                        background: var(--danger-bg);
                        border: 1px solid var(--danger);
                        color: #fca5a5;
                        padding: 0.75rem 1rem;
                        border-radius: 0.5rem;
                        margin-bottom: 1rem;
                        font-size: 0.875rem;
                    }
                    .user-badge {
                        background: rgba(37, 99, 235, 0.15);
                        border: 1px solid rgba(59, 130, 246, 0.3);
                        padding: 0.75rem 1rem;
                        border-radius: 0.5rem;
                        margin-bottom: 1.5rem;
                        font-size: 0.9rem;
                    }
                    .input-group {
                        margin-bottom: 1rem;
                        text-align: left;
                    }
                    .input-group label {
                        display: block;
                        font-size: 0.875rem;
                        color: var(--text-muted);
                        margin-bottom: 0.375rem;
                    }
                    .input-group input {
                        width: 100%;
                        background: #0f172a;
                        border: 1px solid var(--border);
                        border-radius: 0.5rem;
                        padding: 0.625rem 0.75rem;
                        color: var(--text);
                        font-size: 0.95rem;
                    }
                    .input-group input:focus {
                        outline: none;
                        border-color: var(--primary);
                        box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2);
                    }
                    .actions {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 0.75rem;
                        margin-top: 1.5rem;
                    }
                    button {
                        padding: 0.75rem 1rem;
                        border-radius: 0.5rem;
                        font-size: 0.95rem;
                        font-weight: 600;
                        cursor: pointer;
                        border: none;
                        transition: all 0.15s ease-in-out;
                    }
                    .btn-primary {
                        background: var(--primary);
                        color: white;
                    }
                    .btn-primary:hover {
                        background: var(--primary-hover);
                    }
                    .btn-secondary {
                        background: transparent;
                        border: 1px solid var(--border);
                        color: var(--text-muted);
                    }
                    .btn-secondary:hover {
                        background: #334155;
                        color: var(--text);
                    }
                    .footer-note {
                        margin-top: 1.25rem;
                        font-size: 0.75rem;
                        color: var(--text-muted);
                        text-align: center;
                    }
                </style>
            </head>
            <body>
                <div class="card">
                    <div class="brand">
                        <div class="brand-logo">D</div>
                        <div class="brand-title">Disciplaner</div>
                    </div>

                    <h1>Autoriser <strong>{{safeClient}}</strong></h1>
                    <p class="desc">Cette application souhaite se connecter à votre serveur Disciplaner via le Model Context Protocol (MCP).</p>

                    <div class="scope-box">
                        <div class="scope-header">
                            <span style="font-weight: 600; font-size: 0.9rem;">Portée demandée</span>
                            <span class="scope-badge">{{safeScope}}</span>
                        </div>
                        <div class="scope-desc">{{scopeDetails}}</div>
                    </div>

                    {{errorSection}}

                    <form method="post" action="/oauth/authorize">
                        <input type="hidden" name="client_id" value="{{safeClientId}}" />
                        <input type="hidden" name="redirect_uri" value="{{safeRedirect}}" />
                        <input type="hidden" name="scope" value="{{safeScope}}" />
                        <input type="hidden" name="state" value="{{safeState}}" />
                        <input type="hidden" name="code_challenge" value="{{safeChallenge}}" />
                        <input type="hidden" name="code_challenge_method" value="{{safeMethod}}" />

                        {{userSection}}

                        <div class="actions">
                            <button type="submit" name="action" value="deny" class="btn-secondary" formnovalidate>Refuser</button>
                            <button type="submit" name="action" value="approve" class="btn-primary">Autoriser</button>
                        </div>
                    </form>

                    <div class="footer-note">
                        Vous pourrez révoquer cette autorisation à tout moment depuis les paramètres de votre compte.
                    </div>
                </div>
            </body>
            </html>
            """;
    }
}
