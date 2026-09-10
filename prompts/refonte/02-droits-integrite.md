# Lot 02 — Corriger les droits et l'intégrité du cœur

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 01 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Application/Services/TicketService.cs ; SprintService.cs ; SavedViewService.cs ; src/Disciplaner.Infrastructure/Repositories/TicketRepository.cs ; src/Disciplaner.Web/Server/Controllers ; src/Disciplaner.Domain/Entities/Project.cs et Sprint.cs. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Reproduis A01 à A05 avec des tests API locaux : vue sans filtre, membre retiré, Guest qui modifie/supprime un sprint, affectation à un sprint tiers, effacement des points/date.
2. Applique le périmètre d'accès serveur avant filtrage, comptage et projection. Inspecte aussi Activity, Labels, Calendar/iCal, Comments, Attachments et listes personnelles : une ressource indirecte ne contourne jamais les droits.
3. Impose CanManage aux mutations de sprints ; harmonise ForbiddenException et la réponse HTTP 403 dans tous les contrôleurs concernés.
4. Valide sprint et parent dans le même projet, utilisateur affecté autorisé/actif, points non négatifs, dates de sprint ordonnées et transitions Planned→Active→Closed. Refuse cycle parental et auto-parent.
5. Définis la sémantique des champs nullables : PUT remplace la valeur, ou commande partielle explicite distinguant absent/null ; adapte le client et historise uniquement la modification appliquée.
6. Protège les numéros de tickets contre les créations simultanées : contrainte unique et allocation atomique/retry borné compatible SQLite, avec inventaire préalable des collisions existantes.
7. Ne modifie pas les anciens historiques incohérents sans trace ; documente leur limite.

## Critères d'acceptation

- Guest ne peut ni modifier ni supprimer un sprint ; non-membre et membre retiré ne voient ni données ni totaux interdits.
- Une vue vide de filtres retourne seulement les projets autorisés.
- Effacer échéance/points persiste null et produit une histoire cohérente.
- Les références interprojets sont rejetées sans mutation partielle.
- Deux créations concurrentes ne produisent pas de doublon ; un échec n'écrit pas de faux historique.

## Livrables et transmission

Correctifs et tests de non-régression ; matrice des permissions réellement vérifiée.

Crée `docs/refonte/suivi/02-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Ajouter le modèle canonique et les contrats compatibles](03-modele-canonique.md) ; ne le commence pas dans cette tâche.
