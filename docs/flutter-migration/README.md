# Documentation Client Multiplateforme Disciplan (Flutter)

Ce document détaille l'architecture, les commandes de développement, la compilation multiplateforme et le guide de déploiement Homelab du nouveau client unifié **Disciplaner Flutter** (`src/Disciplaner.Flutter`).

---

## 1. Vue d'Ensemble & Architecture

Le client Flutter est l'interface unique de Disciplaner : il a remplacé l'ancienne interface Blazor WebAssembly (retirée du dépôt) par une application ultra-réactive multiplateforme (Web, Desktop Windows/macOS/Linux, et Mobile Android/iOS) adoptant fidèlement le design system **Neo-Linear** (palette crème `#FDFBF7`, noir carbone `#1A1917`, accents ambrés `#E5A800` et typographies *Plus Jakarta Sans* / *JetBrains Mono*).

### Arborescence du Code (`src/Disciplaner.Flutter`)

```
src/Disciplaner.Flutter/
├── lib/
│   ├── app/
│   │   ├── router.dart                ← Navigation déclarative GoRouter avec redirection d'authentification
│   │   └── theme/                     ← Tokens Neo-Linear (NeoColors, NeoTypography, NeoSpacing, NeoTheme)
│   ├── core/
│   │   ├── models/                    ← DTOs sérialisés (Auth, Projets, Tickets, Sprints, Kanban, etc.)
│   │   ├── network/                   ← Client HTTP Dio (intercepteurs Bearer JWT et gestion d'erreurs)
│   │   ├── shortcuts/                 ← Raccourcis clavier globaux (C, ⌘K / Ctrl+K)
│   │   ├── storage/                   ← Persistance locale SharedPreferences (URL serveur Homelab et tokens)
│   │   └── widgets/                   ← Composants atomiques réutilisables (KbdChip, StatusBadge, etc.)
│   └── features/
│       ├── activity/                  ← Flux d'activité récente d'équipe & drawer latéral
│       ├── auth/                      ← Découverte Homelab, Setup initial, Login & Invitation
│       ├── calendar/                  ← Calendrier mensuel, échéances et intégration flux iCal
│       ├── kanban/                    ← Tableau Kanban interactif avec Drag & Drop multiplateforme
│       ├── projects/                  ← Explorateur de projets VS-Code style & modale de création
│       ├── search/                    ← Command Palette globale (⌘K / Ctrl+K)
│       ├── settings/                  ← Profil, URL Homelab, vues sauvegardées et administration des comptes
│       ├── shell/                     ← Shell adaptatif responsive (DesktopAppShell & MobileAppShell)
│       ├── sprints/                   ← Cycles, feuille de route et planification de sprint
│       └── tickets/                   ← Liste dense des tickets, création modale et Split Inspector
└── test/                              ← Suite complète de tests unitaires, widgets et E2E
```

---

## 2. Commandes de Développement & Compilation

### Prérequis
- Flutter SDK $\ge$ 3.24 (Dart SDK $\ge$ 3.5)
- .NET 10 SDK (pour l'exécution de l'API locale `src/Disciplaner.Web/Server`)

### Lancement en Développement
```powershell
cd src/Disciplaner.Flutter

# Récupération des dépendances
flutter pub get

# Analyse statique (0 erreur requise)
flutter analyze

# Exécution de la suite de tests complète (45 tests)
flutter test

# Lancement local (Web Chrome avec hot reload)
flutter run -d chrome

# Lancement Desktop Windows
flutter run -d windows
```

### Compilation de Production par Plateforme

| Plateforme | Commande de compilation | Emplacement de sortie |
| :--- | :--- | :--- |
| **Web** (SPA) | `flutter build web --release` | `build/web/` |
| **Windows** | `flutter build windows --release` | `build/windows/x64/runner/Release/` |
| **macOS** | `flutter build macos --release` | `build/macos/Build/Products/Release/` |
| **Linux** | `flutter build linux --release` | `build/linux/x64/release/bundle/` |
| **Android** | `flutter build apk --release` (ou `appbundle`) | `build/app/outputs/flutter-apk/` |
| **iOS** | `flutter build ipa --release` | `build/ios/ipa/` |

---

## 3. Guide de Déploiement Homelab & Configuration Réseau

L'application Flutter communique avec le serveur API .NET 10 via HTTP REST. L'URL du serveur est configurable dynamiquement au premier lancement de l'application ou à tout moment dans l'onglet **Paramètres**.

Deux modes d'hébergement sont possibles pour le web :

- **Origine distincte** : la SPA est servie par un serveur statique (nginx) et l'API doit autoriser son origine via `Cors__Origins__0` (voir ci-dessous).
- **Origine unique** : le résultat de `flutter build web --release` est copié dans le dossier `wwwroot` du serveur API (`dotnet publish ... --output` puis copie de `build/web` dans `publish/wwwroot`). Le serveur sert la SPA et redirige les liens profonds vers `index.html` ; aucune configuration CORS n'est nécessaire.

### Configuration CORS sur l'API .NET 10

Lorsque le client Flutter tourne sur le Web (ex. hébergé sur un domaine distinct ou un port différent sur votre Homelab), le serveur .NET 10 doit autoriser l'origine cliente.

Vous pouvez définir les origines autorisées via la variable d'environnement `Cors__Origins__0` (ou dans `appsettings.json`) :

#### Exemple `docker-compose.yml` Homelab :
```yaml
services:
  disciplan-server:
    image: ghcr.io/disciplaner/disciplaner:latest
    container_name: disciplan-api
    restart: unless-stopped
    ports:
      - "5000:8080"
    volumes:
      - ./data:/app/data
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - Cors__Origins__0=http://disciplan.homelab.local
      - Cors__Origins__1=http://localhost:3000
      - Cors__Origins__2=https://app.disciplan.yourdomain.com
      - Jwt__Key=your-very-secure-random-secret-key-at-least-32-chars
      - Jwt__Issuer=Disciplaner
      - Jwt__Audience=DisciplanerClient

  disciplan-web-client:
    image: nginx:alpine
    container_name: disciplan-web
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./build/web:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
```

### Configuration Reverse-Proxy (Traefik / Nginx)

Pour un reverse-proxy Nginx servant la SPA Flutter Web, assurez la redirection de toutes les routes vers `index.html` (support de GoRouter HTML5 History API) :

```nginx
server {
    listen 80;
    server_name disciplan.homelab.local;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Mise en cache optimale des assets statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|ttf|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, no-transform";
    }
}
```

---

## 4. Intégration Agenda & Flux iCal

L'application expose une synchronisation d'agenda compatible Google Calendar, Apple Calendar et Thunderbird :
1. Dans l'onglet **Calendrier**, copiez votre URL unique : `{serverUrl}/ical/{token}`.
2. Ajoutez ce flux dans votre client d'agenda préféré sous forme d'abonnement URL.
3. En cas de révocation ou compromission, régénérez le jeton en un clic depuis l'interface Paramètres ou Calendrier.
