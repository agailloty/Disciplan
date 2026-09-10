# Lot 09 — Renforcer les workflows et les relations métier

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 08 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Domain/Entities/TicketStatus.cs ; Ticket.cs ; Project.cs ; src/Disciplaner.Application/Services/ProjectService.cs ; TicketService.cs ; paramètres projet. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Ajoute transitions source/cible, rôle minimal et validations limitées, configurables par Supervisor. Le serveur retourne les transitions disponibles.
2. Initialise le workflow des projets existants pour conserver leurs mouvements autorisés tant qu'aucune règle spécifique n'est choisie.
3. Lors de suppression de statut utilisé, exige une destination de remplacement compatible et applique la migration atomiquement.
4. Implémente hiérarchie existante : Epic→Story/Task/Bug→Subtask selon les enums réels, en documentant le mapping si les noms diffèrent ; pas de cycle ni parent interprojet.
5. Ajoute relations bloque/est bloqué par, lié, duplique ; liens limités au même projet pour cette version, et aucune auto-relation.
6. Affiche relations et transitions dans la fiche, sans créer un éditeur graphique générique. Historise chaque changement ; les opérations batch suivent les mêmes règles.

## Critères d'acceptation

- Transition interdite échoue via API et glisser-déposer.
- Ancien projet conserve son fonctionnement par défaut.
- Suppression d'un statut n'orpheline aucun ticket.
- Parent cyclique, relation à soi-même et relation interprojet sont rejetés.
- Retrait de droits masque les relations et empêche leur modification.

## Livrables et transmission

Workflow et relations persistés, paramètres UI, migrations et tests des graphes/invariants.

Crée `docs/refonte/suivi/09-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Achever la planification et la clôture des sprints](10-sprints.md) ; ne le commence pas dans cette tâche.
