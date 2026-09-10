# Lot 13 — Permettre import/export et automatisations limitées

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 12 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

Contrats Ticket et recherche ; stockage et contrôle d'accès ; infrastructure d'événements/outbox du lot 11. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Livre export CSV des tickets accessibles et format JSON versionné pour réimport contrôlé ; échappe les cellules CSV interprétables comme formules.
2. Ajoute import par fichier avec aperçu/mapping, validations ligne par ligne et résumé avant confirmation ; supporte un CSV normalisé avec exemple de mapping Jira/Linear, sans promettre d'import natif exhaustif.
3. Préserve la référence externe dans un champ dédié ; n'écrase pas les références Disciplan. Définis idempotence par identifiant externe et source d'import.
4. N'importe pas silencieusement membres, ACL ou utilisateurs ; les responsables sont mappés à des membres existants. Les lignes invalides ne deviennent pas des tickets partiels.
5. Ajoute deux règles internes configurables : affectation par défaut à la création et notification interne lors d'une transition définie. Journalise exécution et refus ; limite profondeur/récursion et reprises.
6. Pas de connexion OAuth, synchronisation bidirectionnelle ou webhook externe dans ce lot.

## Critères d'acceptation

- Export ne contient aucune donnée interdite.
- CSV avec virgules, retours ligne, accents et formule potentielle s'ouvre correctement.
- Dry-run ne modifie aucune donnée ; import répété ne duplique rien.
- Référence externe et interne restent distinctes.
- Règle qui réagit à un événement déjà traité n'entraîne ni boucle ni double notification.

## Livrables et transmission

Formats et exemples, assistant d'import, export, règles limitées et tests d'idempotence.

Crée `docs/refonte/suivi/13-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Valider la version et préparer la bascule](14-recette-bascule.md) ; ne le commence pas dans cette tâche.
