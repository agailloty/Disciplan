# Tests de Disciplan

`dotnet restore Disciplaner.slnx`, puis `dotnet test tests/Disciplaner.Tests/Disciplaner.Tests.csproj --no-restore`.

Les tests API utilisent WebApplicationFactory, les migrations réelles et un fichier SQLite unique sous le répertoire temporaire du système. Les fichiers sont synthétiques ; la fixture refuse une base contenant déjà des projets. Le host de test désactive le journal Windows pour fonctionner sans droits sur l'Event Log.

La fixture de volume séparée valide exactement 10 000 tickets, 20 projets et 50 utilisateurs. Exclure sa catégorie pour une boucle rapide : `dotnet test tests/Disciplaner.Tests/Disciplaner.Tests.csproj --filter "Category!=Volume"`. Elle ne mesure pas encore les objectifs de performance.

Pour Chromium : depuis `tests/Disciplaner.BrowserTests`, exécuter `npm ci`, `npx playwright install chromium`, puis `npm test`. Un serveur autonome avec nouvelle base et dossier de fichiers temporaires est lancé sur le port 5187 ; un serveur existant n'est jamais réutilisé. Les captures sont dans test-results et le rapport dans playwright-report, ignorés par Git. Les traces ne doivent contenir que les identités de test.

Le test navigateur vérifie l'initialisation et le commentaire via UI ; projet, ticket et sprint sont préparés par API authentifiée. Il ne prétend pas certifier toutes les saisies métier via interface, ni le clavier/lecteur d'écran/FR-EN/thèmes. Ces recettes restent aux lots concernés.
