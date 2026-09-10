# Lot 14 — Valider la version et préparer la bascule

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lots 01–13 terminés ; pour une version cœur après 10, déclarer 11–13 hors version. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

docs/refonte/02-plan-de-migration.md ; tous les comptes rendus de lots ; pipeline ; Dockerfile ; service worker ; outil de conversion. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Compile et exécute les suites adaptées au périmètre livré. Réalise les scénarios de bout en bout : créer/rechercher, prioriser, exécuter, commenter, clôturer, partager et retirer l'accès.
2. Teste les formats 390/768/1440, FR/EN, thèmes, clavier, lecteur d'écran, liens directs et retour arrière. Documente les vérifications manuelles réellement effectuées.
3. Mesure les budgets sur fixture définie, conserve protocole et résultats bruts ; profile et corrige les dépassements avérés.
4. Répète conversion, reprise, restauration et réconciliation sur copie ; vérifie anciennes URLs, fichiers, ACL et absence de doublons.
5. Teste un ancien onglet PWA face à la nouvelle API, mise à jour du service worker, expiration de session et reprise après erreur réseau.
6. Prépare image locale, plan pilote, monitoring, critères go/no-go et procédure d'incident avant/après nouvelles écritures.
7. Livre une liste fermée des défauts restants avec gravité et décision ; aucun P0 ouvert, aucune perte de données ni recette critique non exécutée ne permet le go.
8. Prépare le dossier concret de mise en production ; ne déploie pas, ne publie pas et ne convertis pas les données réelles sans autorisation explicite correspondante.

## Critères d'acceptation

- Chaque critère de la migration porte Pass/Fail/Non exécuté/Hors version et une preuve.
- Aucun Non exécuté critique n'est considéré comme réussite.
- Sauvegarde restaurée et nouvelles écritures préservables en incident.
- Pilote, version, périmètre et procédure de bascule sont identifiés.
- Aucune table historique n'est supprimée par commodité.

## Livrables et transmission

Dossier de recette final, mesures, image locale si possible, runbook de bascule et décision go/no-go motivée.

Crée `docs/refonte/suivi/14-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. La bascule réelle nécessite une autorisation de déploiement ; remets le dossier prêt à examiner.
