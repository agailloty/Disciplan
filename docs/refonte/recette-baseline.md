# Référence et protocole de recette

Date : 11 septembre 2026. Cette référence distingue la lecture statique du code et l'exécution. Les résultats réels de compilation, tests et lancement du lot 01 sont consignés dans [son compte rendu](suivi/01-compte-rendu.md) ; ils ne sont pas déduits de cet inventaire.

## Comparaison avec l'audit

Au début du lot, `git rev-parse HEAD` retourne `3cff2113bf5f53fe5130aec23573a89889a32d1f` et `git diff 3cff211 HEAD --stat` ne retourne aucun écart. Le code committé est donc celui de l'audit. Les ajouts en cours du lot 01 ne constituent pas des corrections antérieures. Aucun constat A01–A15 n'est rendu obsolète par une évolution de HEAD. A01–A05 restent des risques relevés statiquement à reproduire/corriger au lot 02, pas des incidents de production démontrés.

Inventaire obtenu par `rg --files` et `rg '@page'` / `rg '\[Route|\[Http'` sur les dossiers concernés. Aucune donnée de base utilisateur ni fichier téléversé réel n'a été consulté.

## Routes de référence

Les pages dans `src/Disciplaner.Web/Client/Pages` déclarent :

| Parcours | Routes client |
|---|---|
| Accueil, authentification | `/`, `/login`, `/setup`, `/invitation/{Token}`, `/not-found` |
| Ancien Kanban | `/boards`, `/boards/{Id:guid}` |
| Projets et travail | `/projects`, `/projects/{Id:guid}`, `/sprints/{Id:guid}`, `/my-tickets` |
| Ticket | `/tickets/{Id:guid}`, `/tickets/{Ref}` |
| Labels et calendrier | `/labels`, `/labels/{Id:guid}`, `/calendar` |
| Administration | `/settings`, `/admin/users` |

Les contrôleurs dans `src/Disciplaner.Web/Server/Controllers` couvrent les familles suivantes. Les suffixes indiquent les routes particulières à préserver ou réexaminer ; les fichiers contrôleurs restent la source exhaustive des verbes et paramètres.

| Contrôleurs | Racines et opérations particulières |
|---|---|
| Auth, Setup | `/api/auth` (register, login, invitation/{token}, register-invited), `/api/setup` et `/status` |
| AdminUsers, Users | `/api/admin/users`, activation/désactivation/rôle ; `/api/admin/invitations` ; `/api/users`, `/me/display-name`, `/me/profile-picture` ; `/api/attachments/profile/{**storagePath}` |
| Boards, BoardMembers | `/api/boards`, `/{id}`, `/{boardId}/members`, `/{userId}` |
| Columns, Cards | `/api/boards/{boardId}/columns`, `/api/columns/{columnId}`, `/{columnId}/cards`, `/api/cards/{cardId}`, `/{cardId}/move` |
| Projects, ProjectMembers | `/api/projects`, `/{id}`, `/{id}/defaults`, `/{projectId}/statuses`, `/{statusId}`, `/{projectId}/members`, `/{userId}` |
| Tickets, TicketHistory | `/api/projects/{projectId}/tickets` et `/backlog`, `/api/sprints/{sprintId}/tickets`, `/api/tickets/mine`, `/{ticketId}`, `/by-ref/{projectKey}/{ticketNumber}`, `/{ticketId}/status`, `/sprint`, `/history` |
| Sprints | `/api/sprints/active`, `/with-dates`, `/{id}`, `/{sprintId}/start`, `/close`, `/api/projects/{projectId}/sprints` |
| Comments | `/api/cards/{cardId}/comments`, `/api/tickets/{ticketId}/comments`, `/api/comments/{commentId}` |
| Attachments | `/api/tickets/{ticketId}/attachments`, `/api/comments/{commentId}/attachments`, `/api/boards/{boardId}/attachments`, `/api/attachments/{id}`, `/{id}/download` |
| Labels | `/api/labels`, `/{id}`, `/{id}/items`, `/{labelId}/tickets/{ticketId}`, `/{labelId}/boards/{boardId}` |
| SavedViews, Activity | `/api/saved-views`, `/{viewId}`, `/{viewId}/tickets` ; `/api/activity/recent`, `/grouped` |
| Calendar, ICal | `/api/calendar/token` ; `/ical/{token}` |

Le fallback SPA est défini dans `Program.cs`. La présence d'une route n'atteste ni son accessibilité anonyme ni ses droits effectifs. Vérifier aussi les accès indirects fichiers, iCal, labels, activité et vues.

## Modèles et stockage

`ApplicationDbContext` expose 16 ensembles métier : Boards, Columns, Cards, Comments, Attachments, Projects, Sprints, Tickets, TicketStatuses, Labels, SavedViews, TicketHistories, UserInvitations, BoardMembers, ProjectMembers et CalendarTokens. Identity gère comptes/rôles et tables associées. `Domain.User` est explicitement ignoré par EF et adapté depuis `ApplicationUser`. Les configurations EF portent les relations et tables de jonction ; leur inspection est requise avant toute conversion.

Le serveur utilise la chaîne `ConnectionStrings:DefaultConnection`, avec fallback relatif `Data Source=disciplaner.db`. Le Dockerfile configure `/data/disciplaner.db` et un volume `/data`. Le démarrage applique `MigrateAsync`, puis initialise Identity : lancer sans configuration temporaire peut donc modifier une base existante.

`FileStorageOptions.BasePath` vaut par défaut `/data/uploads`. `LocalFileStorageService` organise les fichiers par `{context}/{préfixe GUID}/{GUID}{extension}` ; le chemin relatif est conservé dans les métadonnées. Les pièces jointes concernent tickets/commentaires/tableaux et les photos de profil ont aussi un stockage dédié. Un snapshot doit réconcilier base, métadonnées et binaires au même point, y compris WAL/SHM si présents. Ce document ne certifie aucune sauvegarde restaurée.

Le navigateur conserve JWT, thème, culture, état de barre latérale (`sidebar:collapsed`) et configuration d'accueil (`disciplaner-dashboard-v1`) en localStorage. Préserver ou convertir les préférences ; ne jamais exporter les jetons dans les preuves de recette. Le service worker impose un scénario ancien onglet/nouvelle API lors de la bascule.

## Historique EF de départ

17 migrations identifiées dans `src/Disciplaner.Infrastructure/Data/Migrations`, plus leurs fichiers Designer et `ApplicationDbContextModelSnapshot.cs` :

1. `20260429171647_InitialCreate`
2. `20260429211518_AddComments`
3. `20260429215021_AddProjectSprintTicketModel`
4. `20260429231055_AddTicketComments`
5. `20260430081011_AddProjectTicketCounter`
6. `20260430091126_AddCreatorAssigneeToCards`
7. `20260505120043_AddLabels`
8. `20260505154029_AddProjectDefaults`
9. `20260508135947_AddSavedViews`
10. `20260508144845_UpdateSavedViewStatusCategories`
11. `20260508145755_AddIsCollapsedByDefault`
12. `20260508181312_AddTicketHistories`
13. `20260508181716_AddTicketHistoriesSnapshot`
14. `20260518185417_AddUserInvitations`
15. `20260518202820_AddMembership`
16. `20260521192605_AddAttachments`
17. `20260604124506_AddCalendarToken`

Cet inventaire ne prouve pas que ces migrations sont appliquées sur une installation. Lire `__EFMigrationsHistory` uniquement sur les bases isolées autorisées pour les répétitions et comparer au manifeste.

## Protocole des parcours

Recette visuelle : **non exécutée dans cette inspection documentaire**. Aucune capture ni mesure de contraste, de lecteur d'écran ou de performance n'est produite ici. Chaque scénario doit conserver rôle, fixture, version, navigateur, résultat attendu/réel et capture anonymisée. Exécuter en FR/EN, clair/sombre, à 390, 768 et 1440 px, puis entièrement au clavier. Les observations du code de l'audit ne sont pas des défauts visuels reproduits.

| Scénario | Étapes reproductibles sur fixture | Vérification attendue |
|---|---|---|
| Créer et retrouver | Member ouvre un projet, crée un ticket, note sa référence, recharge sa fiche puis ouvre le lien direct. | Même identité/contenu persisté ; retour au contexte ; erreur explicite pour non-membre. |
| Prioriser | Ouvrir le backlog, créer plusieurs tickets dont un terminé, modifier priorité et recharger. | Relever l'ordre réel actuel (numéro dans le code), les filtres et la présence du terminé ; ne pas présumer de rang manuel livré. |
| Exécuter | Ouvrir un sprint en Kanban puis liste/grille, changer le statut, rouvrir la fiche. | Même ticket et statut persisté dans les présentations ; simuler erreur réseau puis refus Guest. |
| Planifier et clôturer | Supervisor crée et démarre un sprint contenant un ticket fini et un inachevé, puis clôture. | Relever la destination réelle du reliquat et les confirmations ; tenter modification/suppression Guest via API. Le comportement cible sera vérifié au lot 10. |
| Collaborer et partager | Member commente, ajoute un fichier factice, enregistre une vue et ouvre le calendrier ; retirer son accès. | Recontrôler fiche, vue, totaux, activité, fichier et iCal après retrait. Le partage de vue est une cible future, pas une fonction certifiée de la baseline. |

Complément pilotage : ouvrir la vue projet, relever définition et provenance des statistiques ; aucun chiffre reconstruit ne doit être présenté comme un historique réel.

## Exécution et limites

La compilation, l'infrastructure de tests et les fixtures sont réalisées par le lot 01 et doivent être accompagnées de leurs commandes exactes dans son compte rendu. Tester au minimum domaine, distinction membre/non-membre via API et rendu client. Un test rouge reproduisant une faille devient une preuve pour le lot 02 ; ne pas l'annoncer comme protection acquise.

La fixture performance doit compter 10 000 tickets, 20 projets et 50 comptes synthétiques, indépendamment de la petite fixture fonctionnelle. La simple création du jeu ne valide aucun seuil : préciser matériel, configuration, échauffement, durée, répétitions et p95 avant toute conclusion. Les objectifs <500 ms serveur et <2 s client du plan restent non mesurés tant qu'un rapport ne fournit pas ces preuves.

Avant le lot 02 : vérifier les accès transversaux A01/A02, gestion sprint A03, intégrité relationnelle A04 et effacement nullable A05 ; préserver les routes et le schéma inventoriés pendant les corrections.
