# Lot 04 — Construire et répéter la conversion des tableaux

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 03 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Domain/Entities/Card.cs ; Board.cs ; Column.cs ; Comment.cs ; Attachment.cs ; Label.cs ; src/Disciplaner.Infrastructure/Storage/LocalFileStorageService.cs ; docs/refonte/02-plan-de-migration.md. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Construis un outil local de préflight/dry-run puis apply explicite, versionné et relançable. Il accepte une base source/cible explicitement désignée et refuse par défaut une cible non préparée.
2. Produis le manifeste Board→Project, Column→Status et Card→Ticket : clés de projet déterministes valides, catégories de statut explicites, ACL exactes, identifiants stables de mapping.
3. Convertis un Board en projet isolé avec vue tableau. Préserve texte, ordre, auteur, responsable, priorité, échéance et dates. Ne réutilise pas aveuglément un constructeur qui réinitialise les dates.
4. Rebranche les commentaires des cartes et conserve leurs fichiers ; transfère les fichiers/labels de Board au Project sans duplication des binaires ni propagation des labels à tous les tickets.
5. Ajoute verrouillage serveur du périmètre converti, transaction/checkpoint et résolution authentifiée des anciennes URLs. Ne maintiens pas de double écriture Card/Ticket.
6. Compare avant/après : compteurs, valeurs, ACL, fichiers/checksums et références. Toute anomalie bloque le lot et figure dans un rapport exploitable.
7. Répète interruption/reprise et double exécution sur copie. Rédige sauvegarde cohérente SQLite + fichiers, restauration, et stratégie après nouvelles écritures. N'applique aucune conversion aux données réelles dans ce lot.

## Critères d'acceptation

- Deux exécutions donnent exactement les mêmes objets cibles.
- Interruption à mi-lot n'entraîne ni perte ni doublon.
- Commentaire avec fichier, fichier de tableau, label de tableau, propriétaire, Guest et ancien lien sont conservés et autorisés correctement.
- Colonne ambiguë ou fichier manquant produit un échec explicite.
- Restauration locale prouvée ; le retour après nouvelles écritures inclut leur conservation.

## Livrables et transmission

Outil de conversion, tests d'intégration, exemple de manifeste, rapport de répétition et procédure de restauration.

Crée `docs/refonte/suivi/04-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Refondre le système de composants et la navigation](05-design-navigation.md) ; ne le commence pas dans cette tâche.
