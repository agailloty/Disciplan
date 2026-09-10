# Lot 07 — Unifier la fiche et la création de tickets

## Instruction

Lis et applique [le contrat commun](00-contrat-agent.md), [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md). Exécute ce lot dans le dépôt ; ne te limite pas à proposer un plan.

## Prérequis

Lot 06 terminé. Vérifie les preuves dans `docs/refonte/suivi/` avant de poursuivre.

## Fichiers de départ

src/Disciplaner.Web/Client/Pages/TicketView.razor ; Components/Shared/TicketDetailModal.razor ; QuickCreateModal.razor ; AttachmentPanel.razor ; src/Disciplaner.Application/Services/TicketService.cs. Ces chemins orientent l'inspection et ne limitent pas les modifications nécessaires.

## Travail à réaliser

1. Extrais un contenu de fiche commun rendu en page et panneau contextuel, relié aux mêmes commandes et état d'édition.
2. Implémente création unique avec contexte projet/sprint prérempli et valeurs par défaut du projet ; titre seul requis lorsque les autres valeurs peuvent être déterminées.
3. Rends les propriétés éditables avec sauvegarde visible, validation serveur, erreurs locales et protection contre doublon de soumission.
4. Préserve description, commentaires, fichiers/prévisualisation et historique. Tout rendu enrichi de contenu utilisateur est assaini.
5. Conserve /tickets/{Id} et /tickets/{Ref}, et retour à la liste avec filtre, position et focus.
6. Gère explicitement conflit de version : montrer la valeur serveur et permettre rechargement/reprise, sans écrasement silencieux.

## Critères d'acceptation

- Créer depuis Mon travail, projet ou sprint donne un ticket consultable depuis chaque vue.
- Page et panneau produisent les mêmes modifications.
- Double clic ne crée pas deux tickets ; erreur réseau conserve le brouillon.
- Deux sessions modifiant le même ticket déclenchent le scénario de conflit.
- Ajout/lecture de fichiers et commentaires respecte Guest/non-membre ; nullables effaçables.

## Livrables et transmission

Fiche et création communes, adaptateurs de routes, tests API et parcours navigateur.

Crée `docs/refonte/suivi/07-compte-rendu.md` selon le contrat commun, avec résultats de tests réels et limites. Le prochain lot est [Livrer un backlog priorisable et un tableau unifié](08-backlog-kanban.md) ; ne le commence pas dans cette tâche.
