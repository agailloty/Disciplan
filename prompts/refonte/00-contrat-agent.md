# Contrat commun pour l'agent de refonte

Tu interviens dans le dépôt Disciplan en tant qu'agent de développement produit. Réalise uniquement le lot fourni, jusqu'à son résultat vérifiable. Lis d'abord [l'audit](../../docs/refonte/01-audit-disciplan.md) et [la migration](../../docs/refonte/02-plan-de-migration.md), puis le code actuel et les instructions AGENTS.md applicables. Le code peut avoir évolué depuis l'audit.

## Règles d'exécution

1. Vérifie git status, les comptes rendus des prérequis et les changements utilisateur ; ne les écrase pas. Ne déclare pas un lot terminé sur la seule existence de son fichier.
2. Résume le résultat attendu et les écarts constatés. Fais les choix réversibles cohérents avec le plan sans demander une validation à chaque détail ; documente les décisions.
3. Conserve .NET/Blazor, les couches et les ressources FR/EN. Tout changement de pile ou de frontière d'accès doit être une décision justifiée distincte.
4. Travaille de bout en bout : domaine, persistance, services, API et interface selon le lot. Aucun bouton simulé, compteur fictif ou stockage navigateur utilisé comme base métier.
5. Vérifie les autorisations côté serveur sur chaque chemin, y compris listes, compteurs, fichiers et opérations indirectes. Le partage d'une vue ne partage jamais automatiquement les tickets.
6. Migrations additives et compatibles ; ne réécris pas l'historique EF, ne supprime pas de données existantes, ne renumérote pas les tickets. Toute conversion est répétée sur copie isolée avec rapport de conservation.
7. Ne lis/affiche pas de secrets et n'utilise pas de données utilisateur pour les fixtures. Ne publie, ne déploie, n'envoie de message ni ne modifie de données de production sans autorisation correspondante.
8. Pour tout changement métier sensible, tests de comportement : droits négatifs, erreurs, transaction, concurrence et reprise selon le périmètre. Pour l'UI, teste le parcours réel et les états réseau/clavier/mobile.
9. Respecte le shell de l'environnement. Lance les commandes réelles, rapporte leur résultat exact ; un outil manquant ou un test non exécuté est une limite explicite, jamais un succès.
10. Si un prérequis est absent, complète uniquement la correction nécessaire et documentée, ou indique précisément le blocage. Ne réalise pas silencieusement plusieurs lots majeurs.

## Définition de terminé

- Critères du lot vérifiés et preuves conservées.
- Aucun élargissement involontaire des permissions ni perte de données.
- Compilation et tests concernés exécutés ; nouvelles erreurs corrigées.
- UI avec chargement, vide, erreur, validation, conflit et droits adaptés.
- Documentation de migration/compatibilité mise à jour si le lot la change.
- Compte rendu `docs/refonte/suivi/NN-compte-rendu.md` : périmètre, fichiers, décisions, commandes et résultats, captures si possibles, critères Pass/Fail/Non exécuté, limites et prochain lot.
- Réponse finale concise indiquant résultat, vérifications et limites. N'annonce pas de déploiement si seule une préparation a été faite.

Si un navigateur ou un service est indisponible, livre le travail indépendant possible et le protocole précis restant ; le lot reste « à valider » tant que ses critères critiques ne sont pas vérifiés.
