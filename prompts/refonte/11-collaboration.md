# Lot 11 — Ajouter mentions et notifications utiles

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 10 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Application/Services/CommentService.cs ; TicketHistoryService.cs ; src/Disciplaner.Domain/Entities/Comment.cs ; src/Disciplaner.Web/Client/Layout ; fiche ticket commune. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Ajoute mentions structurées sélectionnées parmi les membres autorisés, abonnements ticket et notification interne.
2. Définis événements : attribution à une personne, mention, nouveau commentaire pour abonnés ; pas de notification à l'auteur pour son propre acte.
3. Persiste événement/outbox avec la mutation métier, puis traitement idempotent à reprise ; ne dépends pas d'un envoi en mémoire après commit.
4. Livre boîte de réception non lus/tous, ouvrir le ticket, marquer lu et tout lire avec pagination.
5. Déduplique un même événement/destinataire ; recontrôle accès au traitement et à la lecture, retire les extraits devenus interdits.
6. Notifications internes uniquement dans ce lot ; pas d'envoi email ni connexion à un service externe.

## Critères d'acceptation

- Une mention génère exactement une notification à son destinataire.
- Reprise du worker ne duplique pas la notification.
- Retrait de membre empêche lecture de l'extrait et accès au ticket.
- Marquage lu est persistant et propre à l'utilisateur.
- Création du commentaire réussit même si le traitement différé est temporairement indisponible.

## Livrables et transmission

Entités/outbox/worker, UI de mentions/inbox, tests de reprise et confidentialité.

Crée `docs/refonte/suivi/11-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Ajouter jalons et rapports fiables](12-pilotage.md) ; ne le commence pas dans cette tâche.
