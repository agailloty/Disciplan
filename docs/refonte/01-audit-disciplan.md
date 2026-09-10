# Audit produit et technique de Disciplan

Date : 11 septembre 2026. Référence du code : `3cff211`.

## Synthèse et périmètre

Disciplan est une base de gestion de travail déjà substantielle : projets, tickets, tableaux Kanban, sprints, commentaires, fichiers, calendrier et vues personnelles. La prochaine étape doit transformer ces fonctions en un système cohérent : un ticket unique, plusieurs vues du même travail, des règles fiables et des parcours rapides.

Le diagnostic repose sur la lecture du dépôt : entités, services, repositories, contrôleurs, composants Razor, migrations, configuration et pipeline. Il ne constitue pas une recette en navigateur ni un test d'intrusion. Aucune base métier, statistique d'utilisation ou interview utilisateur n'a été consultée. Les remarques visuelles sont des observations du code de l'interface ; rendu, contraste effectif, performance et ergonomie tactile restent à mesurer. Le SDK disponible annonce `10.0.400-preview.0.26322.102` ; aucun build ni test applicatif n'a été exécuté pour cet audit documentaire.

Hypothèse produit : équipe de petite ou moyenne taille qui souhaite piloter des projets et son travail quotidien, avec hébergement simple. La volumétrie, les exigences réglementaires, le budget et le nombre d'organisations restent inconnus. Les objectifs proposés dans la migration sont des critères futurs, pas des résultats observés.

## Architecture actuelle

| Couche | Présent dans le dépôt | Conséquence |
|---|---|---|
| Domaine | Entités C#, méthodes métier, interfaces de repositories | Socle réutilisable ; certaines invariants restent dispersés ou incomplets |
| Application | Services et DTO par ressource | Bon point d'entrée pour unifier autorisations, validations et commandes |
| Infrastructure | EF Core, SQLite, ASP.NET Identity, stockage local | Déploiement simple ; concurrence et migration des fichiers à traiter explicitement |
| Serveur | ASP.NET Core, API authentifiées JWT, Swagger en développement | API exploitable ; harmonisation des erreurs et autorisations nécessaire |
| Client | Blazor WebAssembly .NET 10, Razor, CSS et utilitaires Tailwind, icônes Bootstrap | Une refonte est possible sans changer de framework |
| Exploitation | Docker, migrations au démarrage, workflow de publication | Déploiement existant ; recette et répétition de migration à ajouter |

Sources locales : [solution](../../Disciplaner.slnx), [serveur](../../src/Disciplaner.Web/Server/Program.cs), [contexte EF](../../src/Disciplaner.Infrastructure/Data/ApplicationDbContext.cs), [pipeline](../../.github/workflows/docker.yml).

## Inventaire fonctionnel

« Présent » signifie identifié dans le code, sans certification du fonctionnement en production.

| Domaine | Existant | Écart à traiter |
|---|---|---|
| Navigation | Barre latérale repliable, menu mobile, fil de navigation par section, création rapide | Deux entrées Tableaux/Projets pour deux modèles de travail ; absence de recherche globale dans le shell |
| Tableaux | Board → Column → Card, ordre des cartes, déplacement, membres | Les cartes n'ont pas le modèle complet des tickets |
| Projets | Clé, description, propriétaire, membres, statuts configurables, valeurs par défaut | Vue projet surtout structurée autour du sprint ; pilotage d'objectif et jalons à ajouter |
| Tickets | Référence lisible, type, priorité, points, échéance, responsable, rapporteur, parent | Pas de rang métier dans Ticket ; relations et hiérarchie insuffisamment validées |
| Travail quotidien | Mes tickets, accueil, vues personnelles enregistrées | À distinguer d'une boîte de notifications ; autorisations transversales à corriger |
| Présentations | SprintBoard propose Kanban, liste et grille | Réutiliser ces capacités ; harmoniser filtres, sélection, URL et état de navigation |
| Planification | Backlog, sprints Planned/Active/Closed, objectif et dates ; un sprint actif contrôlé au niveau Project | Clôture sans traitement explicite du reliquat ; dates et transitions de cycle à renforcer |
| Collaboration | Commentaires, historique ticket, pièces jointes | Mentions structurées, abonnements et notifications non identifiés dans le modèle |
| Vues | Filtres projet, sprint, statut, catégorie, type, priorité, auteur/responsable courant ; épinglage accueil | Vues partagées, tri/groupe persistés, recherche et pagination à développer |
| Calendrier | Page calendrier et contrôleurs calendrier/iCal, jetons dédiés | Préserver les abonnements et revalider les droits après migration |
| Administration | Invitations, activation des comptes, rôles globaux et par ressource | Clarifier la distinction Admin global / propriétaire de projet |
| Personnalisation | Ressources FR/EN, thèmes, préférences d'accueil, service worker | Accessibilité à compléter ; compatibilité client ancien/API lors des mises à jour à tester |
| Qualité | Workflow Docker identifié | Aucun projet de tests identifié dans la solution et l'inventaire du dépôt |

Preuves : [navigation](../../src/Disciplaner.Web/Client/Layout/NavMenu.razor), [shell](../../src/Disciplaner.Web/Client/Layout/MainLayout.razor), [projet](../../src/Disciplaner.Web/Client/Pages/ProjectView.razor), [présentations des tickets](../../src/Disciplaner.Web/Client/Components/Shared/SprintBoard.razor), [ticket](../../src/Disciplaner.Domain/Entities/Ticket.cs), [carte](../../src/Disciplaner.Domain/Entities/Card.cs), [vue enregistrée](../../src/Disciplaner.Domain/Entities/SavedView.cs).

## Constats prioritaires et preuves

Priorités : P0 = confidentialité/intégrité avant nouvelle diffusion ; P1 = cœur de la refonte ; P2 = enrichissement après stabilisation.

| ID | Priorité | Constat vérifiable | Impact et action |
|---|---|---|---|
| A01 | P0 | SavedViewService.ExecuteAsync vérifie le propriétaire de la vue, puis GetFilteredAsync interroge les tickets sans périmètre d'accès projet ; aucun filtre global d'accès n'est déclaré dans ApplicationDbContext | Risque de lecture de tickets de projets tiers, notamment avec une vue sans filtre. Appliquer les droits dans la requête avant projection, comptage et pagination |
| A02 | P0 | GetAssignedToUserAsync filtre seulement AssigneeId ; GetCreatedByUserAsync seulement ReporterId | Après retrait d'un projet, les agrégations peuvent encore retourner des tickets. Rechercher et corriger tous les chemins transversaux |
| A03 | P0 | SprintService.UpdateAsync et DeleteAsync appellent EnsureProjectAccessAsync ; Create/Start/Close exigent Supervisor | Un Guest reconnu membre passe le contrôle métier de mise à jour/suppression. Reproduire via API puis imposer le droit de gestion |
| A04 | P0 | TicketService.CreateAsync affecte SprintId, ParentTicketId et AssigneeId directement ; MoveToSprintAsync ne charge pas le sprint cible | Relations interprojets ou incohérentes possibles au niveau applicatif. Valider existence, périmètre, membre actif et absence de cycle |
| A05 | P1 | TicketService.UpdateAsync historise un passage des points/date à null mais ne les applique que si HasValue | Effacement impossible et historique potentiellement contraire à la valeur persistée. Définir les sémantiques de mise à jour |
| A06 | P1 | Card/Column/Board et Ticket/Status/Project sont distincts, jusque dans Comment.CardId ou TicketId | Expérience fragmentée, double maintenance ; converger vers Ticket sans perdre les cartes |
| A07 | P1 | Ticket n'a pas de rang ; GetBacklogAsync trie par TicketNumber et sélectionne seulement SprintId == null | Backlog non priorisable manuellement ; tickets terminés sans sprint inclus dans la requête. Séparer absence de sprint et état de travail |
| A08 | P1 | Sprint.Close modifie seulement le statut ; Start/Update n'imposent pas eux-mêmes l'ordre des dates ni toutes les transitions | Une clôture n'explicite pas le report ; invariants à garantir aussi sous concurrence |
| A09 | P1 | TicketService.ChangeStatusAsync vérifie que le statut appartient au projet, mais pas de graphe de transitions | Statuts configurables présents ; moteur de workflow à construire progressivement |
| A10 | P1 | TicketRepository retourne des listes complètes ; ToDtoListAsync fait une lecture par utilisateur distinct ; SprintService charge les tickets pour les compter | Coût croissant des listes et accueil ; pagination, projections SQL et mesures nécessaires |
| A11 | P1 | Project.ConsumeNextTicketNumber incrémente un champ en mémoire avant sauvegarde | Risque de concurrence à reproduire ; allocation atomique et unicité projet/numéro à garantir, sans conclure à un doublon observé |
| A12 | P1 | Modal.razor traite Escape mais n'implémente pas de piège/restauration de focus ni role=dialog/aria-modal | Parcours clavier et lecteur d'écran incomplets à ce niveau ; valider ensuite en navigateur |
| A13 | P1 | TicketView et TicketDetailModal existent séparément ; styles utilitaires, variables et styles inline coexistent | Risque de divergence entre fiche pleine page et modale ; mutualiser contenu et composants |
| A14 | P1 | Program.cs applique MigrateAsync au démarrage ; pipeline identifié orienté image/push | Une conversion métier lourde doit devenir une opération dédiée, répétable et contrôlée |
| A15 | P2 | Pas d'entités de dépendances, notifications, jalons ou versions identifiées | Ajouter seulement après le socle ; ne pas présenter ces fonctions comme déjà livrées |

Sources des constats :
- A01–A02, A10 : [SavedViewService](../../src/Disciplaner.Application/Services/SavedViewService.cs), [TicketRepository](../../src/Disciplaner.Infrastructure/Repositories/TicketRepository.cs).
- A03, A08 : [SprintService](../../src/Disciplaner.Application/Services/SprintService.cs), [Sprint](../../src/Disciplaner.Domain/Entities/Sprint.cs), [SprintsController](../../src/Disciplaner.Web/Server/Controllers/SprintsController.cs). Le contrôleur impose l'authentification ; il ne remplace pas la vérification de rôle métier.
- A04–A05, A09–A11 : [TicketService](../../src/Disciplaner.Application/Services/TicketService.cs), [Project](../../src/Disciplaner.Domain/Entities/Project.cs).
- A12–A13 : [Modal](../../src/Disciplaner.Web/Client/Components/Shared/Modal.razor), [TicketView](../../src/Disciplaner.Web/Client/Pages/TicketView.razor), [TicketDetailModal](../../src/Disciplaner.Web/Client/Components/Shared/TicketDetailModal.razor).

Ces risques sont établis par lecture statique des chemins cités. Leur reproduction et la recherche d'éventuelles protections additionnelles font partie du premier lot technique.

## Audit des parcours

1. **Créer puis retrouver une tâche.** La création rapide existe, mais l'utilisateur choisit entre des cartes et des tickets qui n'offrent pas les mêmes possibilités. Cible : création unique, contexte prérempli, recherche par référence ou texte, retour à la liste d'origine.
2. **Prioriser le travail.** Le backlog est défini par l'absence de sprint et l'ordre des numéros. Cible : liste ordonnée persistée, filtres explicites, sélection multiple, séparation du travail terminé.
3. **Exécuter.** Les présentations liste/Kanban/grille existent pour les tickets de sprint. Cible : même ticket accessible depuis toute vue, changement de statut immédiat avec gestion des erreurs et conflits.
4. **Planifier et clôturer.** La structure des sprints est présente. Cible : objectif, contenu engagé, dates valides, destination du reliquat et rapport conservé.
5. **Collaborer.** Commentaires et pièces jointes constituent un bon socle. Cible : mentions, abonnements et boîte de réception sans exposition d'informations après retrait d'accès.
6. **Piloter.** Des statistiques projet sont affichées, mais aucun historique analytique complet n'est établi. Cible : indicateurs dont la définition et la période sont visibles, jamais reconstruits artificiellement.

## Principes empruntés aux solutions éprouvées

| Référence officielle consultée | Principe retenu | Adaptation proposée pour Disciplan |
|---|---|---|
| [Jira : workflows](https://www.atlassian.com/software/jira/guides/workflows/overview) | États et transitions forment le workflow | Configurer quelques transitions utiles, séparées de la présentation du tableau |
| [Jira : Kanban](https://www.atlassian.com/software/jira/features/kanban-boards) | Visualiser le flux et limiter le travail en cours | Limites WIP visibles ; avertissement par défaut, blocage seulement configuré |
| [Linear : modèle conceptuel](https://linear.app/docs/conceptual-model) | Le ticket est l'unité du travail ; équipes, projets et cycles ont des rôles distincts | Unifier Card vers Ticket ; garder initialement Project comme frontière des droits |
| [Linear : vues](https://linear.app/docs/custom-views) | Enregistrer un sous-ensemble de travail et sa présentation | Un moteur de requête commun aux listes, tableaux et vues sauvegardées |
| [Linear : cycles](https://linear.app/docs/use-cycles) | Cadence récurrente et gestion du travail inachevé | Conserver le mot Sprint et la clôture explicite ; automatisation récurrente ultérieure |

Sources consultées le 11 septembre 2026. Ce sont des inspirations fonctionnelles ; la cible ci-dessous est une décision de conception propre à Disciplan. Elle ne promet pas une parité complète avec Jira ou Linear et ne reproduit pas leurs différences de modèle.

## Recommandation

Conserver Blazor, ASP.NET Core et la séparation en couches. Réparer les droits et les invariants, prendre Ticket comme modèle canonique, convertir chaque ancien tableau dans un projet isolé, puis construire une navigation et des vues communes. Livrer ensuite workflows, planification, collaboration et pilotage. Ne pas commencer par une nouvelle pile technique ni par un éditeur de workflows universel.

Une validation terrain doit compléter cet audit : cinq utilisateurs représentatifs exécutent création, recherche, priorisation, clôture et partage d'une vue ; relever succès, durée et hésitations. Les mesures réelles décideront des ajustements de navigation et de densité.
