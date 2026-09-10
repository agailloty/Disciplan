# Lot 06 — Créer la recherche et les vues de tickets cohérentes

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 05 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Infrastructure/Repositories/TicketRepository.cs ; src/Disciplaner.Application/Services/SavedViewService.cs ; src/Disciplaner.Web/Client/Pages/MyTickets.razor ; Home.razor ; Components/Shared/SavedViewFormModal.razor. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Implémente la requête commune sécurisée et paginée spécifiée dans la migration ; requête SQL projetée, tri stable avec départage par ID, limite de page et annulation.
2. Ajoute recherche par référence et titre, filtres explicites dont sprint absent/précis/tous. Résous les noms d'utilisateurs par lot et évite de charger tous les tickets pour compter.
3. Implémente liste de tickets avec filtres, tri, groupement et colonnes. Synchronise URL, retour arrière et état persistant.
4. Étends SavedView : privée par défaut, partage projet géré par Supervisor ; une vue partagée ne donne aucun droit sur ses tickets.
5. Convertis les vues existantes en conservant filtres, ordre et épinglage. Mon travail utilise la même requête.
6. Active Ctrl/Cmd+K avec recherche réelle, états chargement/aucun résultat/erreur et raccourcis accessibles.

## Critères d'acceptation

- Vue, URL copiée et actualisation retournent les mêmes filtres.
- Utilisateur retiré ne voit aucun ticket, nom ni total du projet via recherche/vue partagée.
- Pagination n'omet/duplique pas de résultat sur jeu stable.
- Fixture volumineuse mesurée avec nombre de requêtes et p95 ; absence de seuil atteint signalée.
- Filtres invalides répondent avec erreur claire, sans SQL libre.

## Livrables et transmission

API/repository de recherche, UI, migration des vues, tests de droits/pagination et rapport de mesure.

Crée `docs/refonte/suivi/06-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Unifier la fiche et la création de tickets](07-fiche-creation.md) ; ne le commence pas dans cette tâche.
