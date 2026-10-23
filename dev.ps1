# Lancement de Disciplan en developpement en une seule commande :
#   ./dev.ps1
#
# Demarre :
#   - l'API ASP.NET Core sur http://localhost:5027
#   - le client Flutter web sur http://localhost:5000 (Chrome par defaut)
#
# Options :
#   ./dev.ps1 -Device windows     # client desktop Windows au lieu du web
#   ./dev.ps1 -ApiPort 5027 -WebPort 5000
[CmdletBinding()]
param(
    [string]$Device = 'chrome',
    [int]$ApiPort = 5027,
    [int]$WebPort = 5000
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverDir = Join-Path $root 'src/Disciplaner.Web/Server'
$flutterDir = Join-Path $root 'src/Disciplaner.Flutter'

foreach ($cmd in 'dotnet', 'flutter') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd est introuvable. Installez-le avant de lancer le dev."
    }
}

# Secret JWT de dev. Les user-secrets (dotnet user-secrets) ont priorite
# s'ils definissent deja un Jwt:SecretKey valide.
$env:Jwt__SecretKey = 'dev_only_jwt_secret_change_me_1234567890'
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:ASPNETCORE_URLS = "http://localhost:$ApiPort"

$flutter = $null
$api = $null

function Stop-Tree([System.Diagnostics.Process]$p) {
    if ($p -and -not $p.HasExited) {
        & taskkill /PID $p.Id /T /F | Out-Null
    }
}

try {
    Write-Host ">> API  : http://localhost:$ApiPort" -ForegroundColor Cyan
    $api = Start-Process -FilePath 'dotnet' `
        -ArgumentList @('run', '--no-launch-profile', '--project', $serverDir) `
        -WorkingDirectory $serverDir -NoNewWindow -PassThru

    # Attendre que l'API ecoute avant d'ouvrir le client.
    $deadline = (Get-Date).AddSeconds(120)
    $apiUp = $false
    while ((Get-Date) -lt $deadline) {
        if ($api.HasExited) { throw "L'API s'est arretee avant d'ecouter. Consultez la sortie ci-dessus." }
        $client = New-Object Net.Sockets.TcpClient
        try {
            $async = $client.BeginConnect('localhost', $ApiPort, $null, $null)
            if ($async.AsyncWaitHandle.WaitOne(500) -and $client.Connected) { $apiUp = $true; break }
        } finally { $client.Close() }
        Start-Sleep -Milliseconds 500
    }
    if (-not $apiUp) { throw "L'API n'a pas repondu sur le port $ApiPort dans les 120 s." }

    Write-Host ">> Client Flutter ($Device) : http://localhost:$WebPort" -ForegroundColor Cyan
    $flutterArgs = @('run', '-d', $Device, '--dart-define', "DISCIPLAN_API_URL=http://localhost:$ApiPort")
    if ($Device -eq 'chrome' -or $Device -eq 'web-server') {
        $flutterArgs += @('--web-port', "$WebPort")
    }
    $flutter = Start-Process -FilePath 'flutter' -ArgumentList $flutterArgs `
        -WorkingDirectory $flutterDir -NoNewWindow -PassThru

    # Boucle d'attente : le script se termine des qu'un processus s'arrete.
    while (-not $api.HasExited -and -not $flutter.HasExited) {
        Start-Sleep -Seconds 1
    }
}
finally {
    Write-Host ">> Arret des processus de dev..." -ForegroundColor Cyan
    Stop-Tree $flutter
    Stop-Tree $api
    Write-Host ">> Termine." -ForegroundColor Cyan
}
