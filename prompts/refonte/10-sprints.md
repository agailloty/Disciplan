# Lot 10 — Achever la planification et la clôture des sprints

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 09 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Domain/Entities/Sprint.cs ; Project.cs ; src/Disciplaner.Application/Services/SprintService.cs ; src/Disciplaner.Web/Client/Pages/SprintView.razor ; ProjectView.razor. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Fournis préparation du sprint avec nom, objectif, dates et liste estimée. Distingue nombre de tickets, points connus et tickets non estimés.
2. Au démarrage, valide dates et unicité du sprint actif même sous concurrence ; fige le périmètre engagé pour les rapports futurs.
3. À la clôture, présente terminés/non terminés et demande une destination explicite : backlog ou sprint Planned du même projet.
4. Effectue clôture et report dans une transaction idempotente ; conserve l'appartenance historique via événements/snapshot.
5. Interdis l'ajout à un sprint Closed. Définis réouverture comme hors périmètre initial, avec message explicite.
6. Adapte calendrier/iCal aux dates et mouvements, avec droits vérifiés ; ne crée pas de cadence automatique non demandée.

## Critères d'acceptation

- Deux démarrages simultanés ne laissent qu'un sprint actif.
- Clôture avec reliquat reporte chaque ticket une seule fois.
- Relancer la même commande ne duplique ni événements ni report.
- Sprint destination tiers/fermé est rejeté ; erreurs réseau n'affichent pas de succès fictif.
- Rapport historique conserve l'engagement après changement ultérieur des tickets.

## Livrables et transmission

Planification et clôture UI/API, snapshots/événements, tests transactionnels et calendrier.

Crée `docs/refonte/suivi/10-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Ajouter mentions et notifications utiles](11-collaboration.md) ; ne le commence pas dans cette tâche.
