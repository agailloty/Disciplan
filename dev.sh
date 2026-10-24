#!/usr/bin/env bash
# Lancement de Disciplan en développement en une seule commande :
#   ./dev.sh
#
# Démarre :
#   - l'API ASP.NET Core sur http://localhost:5027
#   - le client Flutter web sur http://localhost:5000 (Chrome par défaut)
#
# Options :
#   DEVICE=windows ./dev.sh           # client desktop au lieu du web
#   API_PORT=5027 WEB_PORT=5000 ./dev.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_PORT="${API_PORT:-5027}"
WEB_PORT="${WEB_PORT:-5000}"
DEVICE="${DEVICE:-chrome}"

command -v dotnet >/dev/null || { echo "dotnet est introuvable. Installez-le avant de lancer le dev." >&2; exit 1; }
command -v flutter >/dev/null || { echo "flutter est introuvable. Installez-le avant de lancer le dev." >&2; exit 1; }

# Secret JWT de dev. Les user-secrets (dotnet user-secrets) ont priorité
# s'ils définissent déjà un Jwt:SecretKey valide.
export Jwt__SecretKey="dev_only_jwt_secret_change_me_1234567890"
export ASPNETCORE_ENVIRONMENT=Development
export ASPNETCORE_URLS="http://localhost:${API_PORT}"

API_PID=""
FLUTTER_PID=""

cleanup() {
  echo ">> Arrêt des processus de dev..."
  [ -n "$FLUTTER_PID" ] && kill "$FLUTTER_PID" 2>/dev/null || true
  [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null || true
  wait 2>/dev/null || true
  echo ">> Terminé."
}
trap cleanup EXIT INT TERM

echo ">> API : http://localhost:${API_PORT}"
(
  cd "${ROOT}/src/Disciplaner.Web/Server"
  exec dotnet run --no-launch-profile
) &
API_PID=$!

# Attendre que l'API écoute avant d'ouvrir le client.
api_up=0
for _ in $(seq 1 120); do
  if ! kill -0 "$API_PID" 2>/dev/null; then
    echo "L'API s'est arrêtée avant d'écouter. Consultez la sortie ci-dessus." >&2
    exit 1
  fi
  if (exec 3<>"/dev/tcp/127.0.0.1/${API_PORT}") 2>/dev/null; then
    exec 3>&- 3<&- 2>/dev/null || true
    api_up=1
    break
  fi
  sleep 1
done
if [ "$api_up" -ne 1 ]; then
  echo "L'API n'a pas répondu sur le port ${API_PORT} dans les 120 s." >&2
  exit 1
fi

echo ">> Client Flutter (${DEVICE}) : http://localhost:${WEB_PORT}"
(
  cd "${ROOT}/src/Disciplaner.Flutter"
  WEB_ARGS=""
  if [ "$DEVICE" = "chrome" ] || [ "$DEVICE" = "web-server" ]; then
    WEB_ARGS="--web-port ${WEB_PORT}"
  fi
  # shellcheck disable=SC2086
  exec flutter run -d "$DEVICE" $WEB_ARGS \
    --dart-define="DISCIPLAN_API_URL=http://localhost:${API_PORT}"
) &
FLUTTER_PID=$!

wait "$FLUTTER_PID" "$API_PID"
