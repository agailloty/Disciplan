# Tests de Disciplan

`dotnet restore Disciplaner.slnx`, puis `dotnet test tests/Disciplaner.Tests/Disciplaner.Tests.csproj --no-restore`.

Les tests API utilisent WebApplicationFactory, les migrations réelles et un fichier SQLite unique sous le répertoire temporaire du système. Les fichiers sont synthétiques ; la fixture refuse une base contenant déjà des projets. Le host de test désactive le journal Windows pour fonctionner sans droits sur l'Event Log.

La fixture de volume séparée valide exactement 10 000 tickets, 20 projets et 50 utilisateurs. Exclure sa catégorie pour une boucle rapide : `dotnet test tests/Disciplaner.Tests/Disciplaner.Tests.csproj --filter "Category!=Volume"`. Elle ne mesure pas encore les objectifs de performance.

Les tests du client Flutter (widgets et E2E) se lancent depuis `src/Disciplaner.Flutter` avec `flutter test`.
