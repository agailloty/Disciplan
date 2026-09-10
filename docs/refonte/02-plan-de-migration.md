# Plan de migration et refonte de Disciplan

Date : 11 septembre 2026. Entrée : [audit](01-audit-disciplan.md). Ce document spécifie une cible ; aucune migration ni modification applicative n'est exécutée par sa rédaction.

## Produit cible et décisions

Disciplan doit permettre de saisir, prioriser, attribuer, exécuter et suivre le même travail dans des vues cohérentes. Le périmètre initial vise les équipes projet ; il conserve l'hébergement actuel.

| Décision | Choix de référence | Motif |
|---|---|---|
| Unité de travail | Étendre Ticket ; retirer progressivement Card | Réutiliser références, historique, sprints et labels existants |
| Frontière de sécurité | Project et ses membres restent l'autorité | Éviter un changement simultané de toutes les permissions |
| Tableau | Nouvelle BoardViewDefinition, filtrant des tickets d'un projet | Ne pas confondre l'ancien Board avec la future présentation |
| Organisation | Une installation reste le conteneur initial ; pas de nouvel accès implicite | Workspace/Team multi-organisations différés jusqu'à besoin démontré |
| Workflow | Statuts de projet + transitions et règles explicites | Déploiement progressif, sans langage de règles universel |
| Stockage | SQLite conservé au premier palier | Changement de moteur indépendant, motivé par mesures ultérieures |
| Client | Blazor et composants partagés | Préserver l'investissement et éviter une seconde application |
| Déploiement | Schéma additif, conversion contrôlée, bascule par projet | Limiter les pertes et rendre les étapes vérifiables |

Les sprints restent rattachés à un projet : on ne transpose pas directement les cycles d'équipe de Linear. Les nouveaux regroupements organisationnels ne devront jamais élargir les droits existants automatiquement.

## Utilisateurs et parcours cibles

| Profil | Besoin principal | Parcours de référence |
|---|---|---|
| Contributeur | Savoir quoi faire et mettre à jour rapidement | Mon travail → ticket → statut/commentaire → retour au même endroit |
| Responsable projet | Arbitrer et planifier | Backlog classé → sélection → sprint → clôture avec reliquat |
| Observateur | Comprendre l'avancement | Projet → vue partagée → jalons/rapport, sans boutons d'écriture actifs |
| Administrateur | Gérer les accès et règles | Paramètres projet → membres/workflow → aperçu des conséquences |

## Architecture de l'information et spécification UI

Navigation principale : Mon travail, Notifications, Projets, Vues, Calendrier ; favoris de projets et vues ; paramètres en bas. Recherche et bouton Créer toujours accessibles. Tant que la conversion n'est pas terminée, une entrée « Anciens tableaux » reste disponible. Masquer les destinations non encore implémentées.

Projet : Vue d'ensemble, Tickets, Backlog, Tableau, Sprints, Jalons, Rapports, Paramètres. Afficher seulement les onglets livrés ; un projet Kanban peut désactiver les sprints. La page Tickets couvre tout le projet, indépendamment de la planification.

Structure de l'écran :
- Bureau : navigation latérale d'environ 224 px repliable ; en-tête contextuel ; barre de filtres ; contenu central ; panneau ticket facultatif de 480–640 px selon largeur.
- Table de tickets : référence, titre, statut, priorité, responsable, estimation, sprint, échéance ; colonnes configurables, entêtes stables, lignes de 40–44 px en densité standard.
- Tableau : colonnes liées à un ou plusieurs statuts, compteur et WIP, cartes compactes. Si plusieurs statuts sont possibles à l'arrivée, demander lequel. Prévoir une commande clavier « Déplacer » équivalente au glisser-déposer.
- Ticket : titre éditable, description, propriétés, sous-tickets, relations, commentaires et activité. Le même composant sert la page et le panneau ; conserver le lien /tickets/{Ref}.
- Mobile 390 px : menu tiroir, liste par défaut, fiche plein écran ; actions utilisables sans survol.
- Palette sobre, accent unique, couleurs sémantiques accompagnées de libellés/icônes. Tokens pour surfaces, texte, bordures, espaces, typographie, focus et états ; thèmes clair/sombre. Les thèmes personnalisés existants ont une conversion documentée.
- Chaque vue traite chargement, vide initial, aucun résultat, erreur réseau avec réessai, accès refusé et conflit de version.
- Filtres et présentation sérialisés dans l'URL ; le panneau conserve sélection, pagination et position de défilement au retour.
- Ctrl/Cmd+K pour rechercher, création via palette et raccourci documenté ; ne pas intercepter les frappes d'un champ de saisie.

Critères visuels : pas de chiffres fictifs, pas de bouton inactif sans explication, pas d'empilement de modales pour le parcours nominal. Navigation clavier complète, focus visible, dialogue nommé avec focus contenu/restauré, messages d'erreur associés aux champs. Vérifier contrastes et lecteur d'écran dans la recette.

## Modèle métier et contrats à construire

| Objet | Évolution |
|---|---|
| Ticket | Rang persistant, jeton de concurrence, archivage, liens typés ; conserver GUID, numéro, référence et dates des tickets existants |
| Project | Mode Kanban/Scrum, archivage, objectif ; compteur atomique et contrainte unique (ProjectId, TicketNumber) |
| TicketStatus | Identité stable et catégorie ; ne jamais déduire la sémantique d'une couleur ou d'un nom |
| WorkflowTransition | Projet, statut source/cible, rôle minimal, validations limitées ; historique transactionnel |
| BoardViewDefinition | Projet, filtre versionné, colonnes et mapping de statuts, limites WIP, tri et affichage |
| SavedView | Propriétaire, visibilité privée/projet, version de filtre, tri, groupement, colonnes ; les résultats restent soumis aux droits du lecteur |
| TicketRelation | Parent/enfant validé séparément ; relations bloque/lié/duplique, sans auto-lien ni doublon |
| Sprint | Dates réelles, snapshots d'engagement et clôture, destination explicite des tickets non terminés |
| Notification/Subscription | Destinataire, événement, lecture et abonnement ; contrôle d'accès à la génération et à la lecture |
| Milestone/ProjectUpdate | Jalon, date cible, état et synthèse publiée par un responsable ; historique daté |
| MigrationMap/MigrationRun | Correspondances source/cible uniques, version, checksum, compteurs, erreurs et checkpoint |

Les nouveaux types peuvent être découpés différemment si une décision d'architecture documente le même comportement. Ajouter les catégories sans renuméroter les valeurs d'enum persistées. Conserver les statuts historiques tels quels ; définir leur mapping explicitement.

API cible : recherche paginée de tickets avec texte, projets autorisés, statuts/catégories, sprint (absent, précis ou tous), responsable, type, priorité, labels, dates, tri stable et curseur. Appliquer la sécurité avant comptage. Limite de page maximale définie, par exemple 100. Aucun langage SQL/JQL libre.

Commandes distinctes pour transition, rang, affectation au sprint et actions groupées ; jeton de version obligatoire sur écriture concurrente, réponse de conflit exploitable par le client. Les actions groupées initiales sont atomiques et limitées à un projet, avec refus complet si un ticket est interdit. L'historique et les événements à notifier sont sauvegardés dans la transaction métier.

## Matrice des permissions cible

| Action dans un projet | Guest | Member | Supervisor | Propriétaire |
|---|---|---|---|---|
| Lire tickets, fichiers et rapports | Oui | Oui | Oui | Oui |
| Créer/modifier/commenter un ticket | Non | Oui | Oui | Oui |
| Gérer ses commentaires | Non | Oui | Oui | Oui |
| Gérer sprints, workflow, vues partagées et jalons | Non | Non | Oui | Oui |
| Gérer membres et archivage projet | Non | Non | Non | Oui |
| Supprimer définitivement le projet | Non | Non | Non | Oui, confirmation explicite |

Un administrateur global gère les comptes ; un éventuel accès aux projets doit être une politique explicite et auditée, pas une conséquence implicite de ce rôle. Pas d'élévation de membre vers propriétaire pendant la migration. Retrait d'accès : éliminer immédiatement les résultats, totaux, fichiers, notifications, exports et iCal concernés.

## Conversion des données

### Correspondances

| Source | Cible | Règle de conservation |
|---|---|---|
| Project existant | Même Project | GUID, clé, propriétaire et ACL inchangés |
| Ticket existant | Même Ticket enrichi | Référence, parent, sprint, labels, commentaires, fichiers et historique inchangés |
| Board ancien | Nouveau Project isolé + BoardViewDefinition | Un projet par tableau, mêmes propriétaire et membres ; aucune fusion automatique avec un projet existant |
| Column | TicketStatus + mapping de colonne | Nom, ordre, couleur conservés ; catégorie validée dans un manifeste avant conversion |
| Card | Ticket de type Task | Nouveau GUID via mapping stable, numéro alloué, titre, description, priorité, auteur, responsable, échéance, dates conservés ; rang issu de colonne/ordre/ID |
| Comment.CardId | Comment.TicketId | Même commentaire, auteur, dates et fichiers ; remplacer la relation dans une transaction |
| Attachment.CommentId/TicketId | Même relation | Ne pas recopier inutilement le binaire |
| Attachment.BoardId | Pièce jointe de projet | Ajouter ProjectId et son support API ; préserver métadonnées, chemin et binaire |
| Labels associés à Board | Labels de projet | Ajouter l'association projet ; ne pas attribuer arbitrairement le label à chaque ticket |
| SavedView | Vue privée versionnée | Même propriétaire et préférences ; convertir filtres/catégories sans élargir les droits |
| Anciennes URL tableau/carte | Résolution via MigrationMap | Lien authentifié vers la nouvelle vue/fiche, permissions recontrôlées |
| Préférences locales | Adaptateur versionné | Conserver favoris/thème ; valeur ancienne invalide → défaut documenté |

Clés des nouveaux projets : générateur déterministe de lettres, entre 2 et 10 caractères pour respecter la contrainte actuelle, avec résolution des collisions dans le manifeste. Aucun compteur ou identifiant métier existant n'est renuméroté.

Cas qui bloquent le lot concerné : auteur manquant sans politique de conservation, statut non mappé, membre orphelin, clé conflictuelle, lien parent cyclique/interprojet, fichier absent. Produire un rapport ; ne pas corriger silencieusement en supprimant ou en attribuant à l'admin. Les dates passées sont conservées lors de l'import, même si les formulaires actuels limitent certaines saisies.

### Séquence opérationnelle

1. **Inventorier.** Détecter version de schéma, comptes, cartes, tickets, commentaires, fichiers, ACL, relations et collisions. Créer manifeste et rapport sans écriture métier.
2. **Sauvegarder.** Snapshot SQLite cohérent incluant la gestion WAL et copie des fichiers au même point de gel ; tester la restauration dans un environnement isolé. Enregistrer taille, checksums, version applicative et schéma.
3. **Étendre.** Migrations EF additives ; nouveaux champs compatibles avec l'ancien client. Conversion métier séparée du démarrage web.
4. **Répéter.** Appliquer sur copie anonymisée avec fichiers ; vérifier compteurs, checksums, liens et droits ; relancer pour prouver l'absence de doublons.
5. **Convertir par lot.** Mettre le tableau concerné en lecture seule côté serveur, bloquer ses écritures API et uploads, attendre les opérations en cours ; conversion transactionnelle avec checkpoint. Ne pas compter sur un bouton masqué.
6. **Comparer.** Chaque carte a exactement un ticket cible ; chaque commentaire/fichier attendu est rattaché ; dates et ACL sont identiques. Toute différence non expliquée empêche la bascule.
7. **Basculer.** Activer les routes et vues nouvelles pour ce projet, conserver anciennes tables archivées en lecture seule, contrôler les liens et le client PWA.
8. **Observer.** Journaliser conflits, erreurs, refus, latences et retours utilisateurs ; étendre après recette du pilote.
9. **Retirer.** Après deux versions stables et au moins 30 jours proposés de conservation, préparer la suppression des structures anciennes avec rapport de dépendances ; la suppression réelle est une opération distincte explicitement autorisée.

Aucune double écriture durable Card/Ticket. Avant ouverture des nouvelles écritures, retour possible à l'ancien parcours après validation de l'état pré-bascule. Après ouverture, un simple flag ne constitue plus un rollback : geler, exporter les nouvelles écritures et corriger en avant, ou restaurer une sauvegarde avec rejeu vérifié. Ne pas accepter de perte silencieuse. Cible proposée : RPO nul pendant le gel, interruption inférieure à 30 minutes par lot, à confirmer par répétition chronométrée.

## Livraison par lots

| Lot / prompt | Résultat démontrable | Dépendance | Priorité |
|---|---|---|---|
| 01 | État de référence, fixtures, protocole de recette, décisions | Audit | P0 |
| 02 | Droits et invariants corrigés, tests de non-régression | 01 | P0 |
| 03 | Modèle canonique additif et contrats | 02 | P1 |
| 04 | Conversion répétable sur copie et rollback documenté | 03 | P1 |
| 05 | Système de composants, shell et navigation | 03–04 | P1 |
| 06 | Requête sécurisée, recherche et vues partagées | 05 | P1 |
| 07 | Fiche ticket commune et création unique | 06 | P1 |
| 08 | Backlog classé et tableau unifié | 07 | P1 |
| 09 | Workflows et hiérarchie/relations | 08 | P1 |
| 10 | Sprints et clôture fiable | 09 | P1 |
| 11 | Mentions, abonnements et notifications | 10 | P2 |
| 12 | Jalons, rapports et bilan projet | 11 | P2 |
| 13 | Import/export et automatisations limitées | 12 | P2 |
| 14 | Recette complète, pilote et dossier de bascule | 13 | P1 pour toute diffusion générale |

Ordre volontairement séquentiel pour l'agent. Une première version du cœur produit peut sortir après 10 en appliquant la recette 14 à ce périmètre ; les critères 11–13 sont alors indiqués « hors version », jamais « validés ». Pas d'estimation calendaire ferme avant baseline et répétition de conversion.

Hors périmètre initial : marketplace, clone complet de JQL, moteur d'automatisation arbitraire, SSO/SCIM, applications natives, multi-tenant et portefeuille avancé. Les imports Jira/Linear commencent par des fichiers validés ; connexion OAuth et synchronisation bidirectionnelle sont des projets distincts.

## Critères de recette et mesure

| Axe | Critère de sortie proposé |
|---|---|
| Conservation | 100 % des objets attendus réconciliés ; aucun fichier perdu ; identifiants historiques stables ; conversion relançable sans duplication |
| Confidentialité | Tests négatifs Guest/non-membre/membre retiré sur API, recherche, totaux, historique, fichiers, vues, calendrier et notifications |
| Métier | Conflits concurrents explicites ; aucun numéro dupliqué ; pas de sprint interprojet ; graphe parent sans cycle ; clôture idempotente |
| UI | Parcours complets à 390, 768 et 1440 px ; clavier et lecteur d'écran ; thèmes FR/EN ; retour arrière et liens directs |
| Performance | Fixture 10 000 tickets / 20 projets / 50 utilisateurs ; p95 serveur listes/recherche < 500 ms et affichage utilisable < 2 s après chargement client, sur machine/réseau documentés |
| Utilisabilité | Au moins 4 utilisateurs sur 5 réussissent création, recherche, classement et clôture sans aide ; documenter les échecs |
| Exploitation | Sauvegarde restaurée, répétition chronométrée, journal de conversion, compatibilité PWA/API et procédure de retour vérifiés |

Ces seuils sont à mesurer, pas présumés atteints. Le rapport précise matériel, volume, caches, réseau, nombre de requêtes, essais, outils et limites. Une mesure absente n'est pas une réussite.

## Risques et réponses

- Unification trop large : préserver les ACL par projet, convertir un tableau pilote avant généralisation.
- Historique incomplet : enregistrer les événements nécessaires à partir de la nouvelle version ; afficher « données disponibles depuis… ».
- Refonte uniquement esthétique : chaque lot UI doit traverser composant, API, persistance et recette réelle.
- Concurrence SQLite : tests d'écritures simultanées et stratégie de retry bornée ; envisager un autre moteur seulement après mesure.
- Ancien client PWA : versionner les contrats, tester un onglet resté ouvert et l'actualisation du service worker ; refus lisible des écritures incompatibles.
- Durée et périmètre : livrer le cœur avant les intégrations et les métriques avancées ; documenter les fonctions différées.

## Utilisation des prompts

Ouvrir [le guide des prompts](../../prompts/refonte/README.md), donner à l'agent le contrat commun puis le lot suivant. Chaque lot produit son compte rendu et ses preuves. La refonte applicative, la conversion de données réelles et la mise en production ne sont pas réalisées par les présents documents.
