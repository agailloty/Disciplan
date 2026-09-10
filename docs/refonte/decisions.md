# Décisions de référence de la refonte

Date : 11 septembre 2026. Référence initiale : `3cff2113bf5f53fe5130aec23573a89889a32d1f`. Ces décisions appliquent le [plan de migration](02-plan-de-migration.md). Elles décrivent la cible ; leur présence ne signifie pas que les fonctionnalités sont livrées.

| ID | Décision | Conséquence vérifiable |
|---|---|---|
| D01 | Project reste la frontière des droits. | Toutes les requêtes transversales filtrent les projets autorisés avant projection, comptage et pagination. Le partage d'une vue ne crée aucun accès. |
| D02 | Ticket devient l'unité canonique. | Les tickets existants gardent GUID et référence. Chaque ancien Board devient un projet isolé ; Card est converti via une correspondance persistée, sans fusion automatique. |
| D03 | Conserver SQLite, ASP.NET Core, Blazor WebAssembly et les couches existantes. | Pas de changement de framework pour contourner un problème de compilation. La concurrence se vérifie avec SQLite réel ; un changement de moteur exige des mesures. |
| D04 | Migrer par extensions additives et conversion dédiée. | Ne pas réécrire l'historique EF. La conversion métier ne tourne pas au démarrage web. Répétition sur copie, restauration, checksums et ACL précèdent la bascule. |
| D05 | Utiliser la matrice Guest/Member/Supervisor/propriétaire du plan. | Guest lit ; Member contribue ; Supervisor gère planification et règles ; le propriétaire gère membres et projet. Admin global ne reçoit pas implicitement les droits métier. |
| D06 | Livrer les lots 01 à 14 dans l'ordre, avec un commit par lot terminé. | Les comptes rendus indiquent Pass/Fail/Non exécuté et les limites. Un commit ne prouve pas une recette visuelle ou un déploiement. |
| D07 | Le cœur produit correspond aux lots 01 à 10. | Une diffusion de ce cœur nécessite la recette 14 adaptée ; notifications, pilotage avancé et imports/automatisations 11–13 restent hors de cette version jusqu'à validation. L'exécution demandée couvre bien toute la série. |
| D08 | Fixtures exclusivement synthétiques et isolées. | Bases temporaires et répertoire de fichiers temporaire distincts ; aucune lecture de données métier réelles, aucun compte utilisateur réutilisé. Le jeu de performance est séparé du jeu fonctionnel. |
| D09 | Préserver les parcours et les liens historiques pendant la transition. | Maintenir les routes ticket GUID/référence et les anciens tableaux jusqu'à conversion. Revalider les accès lors de toute résolution de lien. |
| D10 | Mutualiser les composants et préserver FR/EN. | La fiche page/panneau partage son contenu. États vide, erreur, refus, chargement et conflit sont explicites ; recette clavier et mobile distincte du build. |

La suppression définitive des anciennes données, l'utilisation de données de production et le déploiement sont des opérations distinctes des commits locaux autorisés. Le périmètre initial exclut multi-tenant, SSO/SCIM, marketplace, langage JQL libre et synchronisation bidirectionnelle Jira/Linear.

Une décision modifiée devra citer le lot, sa justification, ses conséquences sur les données/permissions et les preuves de validation. Les constats de départ et la recette sont conservés dans [recette-baseline.md](recette-baseline.md).
