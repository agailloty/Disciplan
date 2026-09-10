# Lot 05 — Refondre le système de composants et la navigation

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lots 03 et 04 terminés. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Web/Client/Layout ; Components/Shared/Modal.razor ; Services/ThemeService.cs ; wwwroot/css ; wwwroot/index.html ; Resources. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Implémente les tokens et composants décrits dans la migration : boutons, champs, select, badge de statut, avatar, menu, onglets, tableau, panneau, dialogue, notification et états vides/erreur.
2. Réorganise le shell autour de Mon travail, Projets, Vues et Calendrier ; n'affiche Notifications/Jalons/Rapports que lorsqu'ils fonctionnent. Maintiens Anciens tableaux tant qu'il en existe.
3. Conserve les liens et ajoute une navigation projet contextuelle, favoris et fil de navigation réel. Réserve l'entrée de recherche pour son activation au lot 06.
4. Rends les dialogues accessibles : rôle/nom, focus initial, piégeage, Escape, retour du focus ; confirme la sortie si édition non enregistrée.
5. Unifie clair/sombre et conversion des préférences de thème existantes. Préserve les ressources FR/EN et le démarrage sans flash de thème.
6. Livre un écran réel de liste projet avec les nouveaux composants, connecté aux services existants. Une galerie de composants seule ne suffit pas.

## Critères d'acceptation

- Parcours navigation/création existante fonctionne à 390/768/1440 px.
- Navigation clavier et fermeture de dialogue rendent le focus au déclencheur.
- Thèmes et libellés FR/EN contrôlés ; aucun lien vers page fictive.
- Aucune régression des anciens tableaux avant conversion et des liens directs.

## Livrables et transmission

Composants, shell et première page migrée ; captures et recette d'accessibilité indiquant les contrôles réellement faits.

Crée `docs/refonte/suivi/05-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Créer la recherche et les vues de tickets cohérentes](06-recherche-vues.md) ; ne le commence pas dans cette tâche.
