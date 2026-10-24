// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get create => 'Créer';

  @override
  String get close => 'Fermer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get back => 'Retour';

  @override
  String get name => 'Nom';

  @override
  String get description => 'Description';

  @override
  String get title => 'Titre';

  @override
  String get type => 'Type';

  @override
  String get priority => 'Priorité';

  @override
  String get loading => 'Chargement…';

  @override
  String get nodescription => 'Aucune description.';

  @override
  String get errorDefault => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get errorLoad => 'Impossible de charger les données.';

  @override
  String get errorCreate => 'La création a échoué.';

  @override
  String get errorUpdate => 'La mise à jour a échoué.';

  @override
  String get errorDelete => 'La suppression a échoué.';

  @override
  String get errorMove => 'Le déplacement a échoué. Veuillez réessayer.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navBoards => 'Tableaux';

  @override
  String get navProjects => 'Projets';

  @override
  String get navMyTickets => 'Mes tickets';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navLabels => 'Étiquettes';

  @override
  String get navAdmin => 'Admin';

  @override
  String get navLogout => 'Se déconnecter';

  @override
  String get authSubtitle => 'Connectez-vous pour continuer';

  @override
  String get authEmail => 'Adresse e-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authSubmit => 'Se connecter';

  @override
  String get authSubmitting => 'Connexion…';

  @override
  String get authErrorInvalid => 'Identifiants incorrects.';

  @override
  String dashboardGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardSubtitle =>
      'Vue d\'ensemble de vos projets et de vos tickets assignés';

  @override
  String get dashboardProjectsSection => 'Vos projets';

  @override
  String get dashboardNoProjects =>
      'Aucun projet pour le moment. Créez-en un pour démarrer.';

  @override
  String get dashboardOpenProject => 'Ouvrir';

  @override
  String get dashboardMyTicketsSection => 'Mes tickets';

  @override
  String get dashboardStatusFilterTooltip => 'Statuts affichés';

  @override
  String get dashboardNoTickets =>
      'Aucun ticket ne correspond aux statuts sélectionnés.';

  @override
  String get boardCreateTitle => 'Nouveau tableau';

  @override
  String get boardAddColumn => 'Ajouter une colonne';

  @override
  String get boardDropHere => 'Déposer ici';

  @override
  String get boardEditTitle => 'Modifier le tableau';

  @override
  String get boardEmpty => 'Aucun tableau pour l\'instant.';

  @override
  String get boardCreateFirst => 'Créer mon premier tableau';

  @override
  String get boardDescription => 'Description (optionnel)';

  @override
  String get boardDeleteTitle => 'Supprimer le tableau';

  @override
  String boardDeleteConfirm(String name) {
    return 'Supprimer « $name » ? Toutes ses colonnes et cartes seront perdues.';
  }

  @override
  String get boardDeleteWarning =>
      'Cette action est irréversible. Toutes les colonnes, cartes et données seront supprimées.';

  @override
  String get boardSettings => 'Paramètres';

  @override
  String get boardGeneralInfo => 'Général';

  @override
  String boardColumnCount(int count) {
    return '$count col.';
  }

  @override
  String get boardAddCard => 'Ajouter une carte';

  @override
  String get projectCreateTitle => 'Nouveau projet';

  @override
  String projectTicketCount(int count) {
    return '$count ticket(s)';
  }

  @override
  String projectSprintCount(int count) {
    return '$count sprint(s)';
  }

  @override
  String get projectEditTitle => 'Modifier le projet';

  @override
  String get projectEmpty => 'Aucun projet pour l\'instant.';

  @override
  String get projectCreateFirst => 'Créer mon premier projet';

  @override
  String get projectKey => 'Clé';

  @override
  String get projectKeyLabel => 'Clé projet';

  @override
  String get projectKeyHint => '2 à 10 lettres, ex : DISC.';

  @override
  String get projectSubtitle =>
      'Organise les tickets, le backlog et les sprints.';

  @override
  String get projectBacklog => 'Backlog';

  @override
  String get projectBacklogEmpty => 'Le backlog est vide.';

  @override
  String get projectDeleteTitle => 'Supprimer le projet';

  @override
  String projectDeleteConfirm(String name) {
    return 'Supprimer « $name » et tous ses tickets ?';
  }

  @override
  String get projectDeleteWarning =>
      'Cette action est irréversible. Tous les tickets et données seront supprimés.';

  @override
  String get projectStatuses => 'Statuts du projet';

  @override
  String get projectSettings => 'Paramètres';

  @override
  String get projectDangerZone => 'Zone dangereuse';

  @override
  String get projectDefaults => 'Valeurs par défaut des tickets';

  @override
  String get projectDefaultsHint =>
      'Ces valeurs sont pré-remplies à la création d\'un ticket.';

  @override
  String get projectDefaultTicketType => 'Type par défaut';

  @override
  String get projectDefaultAssignee => 'Assigné par défaut';

  @override
  String get defaultassigneepolicyNone => 'Aucun';

  @override
  String get defaultassigneepolicyCreator => 'Créateur du ticket';

  @override
  String get projectStatsTitle => 'Statistiques';

  @override
  String get projectStatsBacklog => 'Backlog';

  @override
  String get projectStatsBacklogSub => 'tickets non planifiés';

  @override
  String get projectStatsSprints => 'Sprints';

  @override
  String get projectStatsSprintsSub => 'itérations créées';

  @override
  String get projectStatsWorkflow => 'Workflow';

  @override
  String get projectStatsWorkflowSub => 'statuts de tickets';

  @override
  String get projectStatsNoSprints => 'Aucun sprint pour ce projet.';

  @override
  String get sprintActive => 'Sprint actif';

  @override
  String get sprintPlanning => 'Planning';

  @override
  String get sprintStatuses => 'Statuts';

  @override
  String get sprintStart => 'Démarrer';

  @override
  String get sprintClose => 'Clore';

  @override
  String get sprintCreateTitle => 'Créer un sprint';

  @override
  String get sprintGoal => 'Objectif';

  @override
  String get sprintNoActive => 'Aucun sprint actif';

  @override
  String get sprintNoActiveDesc =>
      'Démarre un sprint planifié depuis l\'onglet Planning. Un seul sprint peut être actif à la fois.';

  @override
  String get sprintViewKanban => 'Kanban';

  @override
  String get sprintViewList => 'Liste';

  @override
  String get sprintViewGrid => 'Grille';

  @override
  String sprintSelectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String get sprintTicketHint => 'Coche des tickets puis crée un sprint.';

  @override
  String sprintTicketsMoved(int count) {
    return '$count tickets seront déplacés depuis le backlog.';
  }

  @override
  String get sprintStartHint => 'Démarrer ce sprint';

  @override
  String get sprintAlreadyActive => 'Un sprint est déjà actif';

  @override
  String get sprintAddTicket => 'Ticket';

  @override
  String get sprintAddTicketNew => 'Nouveau ticket';

  @override
  String get sprintAddToSprint => 'Ajouter au sprint';

  @override
  String get sprintNoTickets => 'Ce sprint ne contient aucun ticket.';

  @override
  String get sprintColumnEmpty => 'Aucun ticket';

  @override
  String get sprintAddCard => 'Ajouter';

  @override
  String get sprintCreateButton => 'Créer un sprint';

  @override
  String get sprintMoveToBacklog => 'Backlog';

  @override
  String sprintTicketCount(int count) {
    return '$count tickets';
  }

  @override
  String get sprintMySprints => 'Mes sprints actifs';

  @override
  String get sprintNoneActive => 'Vous ne participez à aucun sprint actif.';

  @override
  String get sprintLabel => 'Sprint';

  @override
  String get sprintLoading => 'Chargement du sprint…';

  @override
  String get sprintNotFound => 'Sprint introuvable.';

  @override
  String get sprintTickets => 'tickets';

  @override
  String get cardCreateTitle => 'Nouvelle carte';

  @override
  String get ticketCreateTitle => 'Nouveau ticket';

  @override
  String get ticketNotFound => 'Ticket introuvable.';

  @override
  String get ticketOpenPage => 'Ouvrir la page';

  @override
  String get ticketStoryPoints => 'Story points';

  @override
  String get ticketDueDate => 'Échéance';

  @override
  String get ticketSprint => 'Sprint';

  @override
  String get ticketBacklogOption => '— Backlog —';

  @override
  String get ticketReporter => 'Créé par';

  @override
  String get ticketAssignee => 'Assigné à';

  @override
  String get ticketNoAssignee => 'Non assigné';

  @override
  String get ticketComments => 'Commentaires';

  @override
  String get ticketCommentAdd => 'Ajouter un commentaire…';

  @override
  String get ticketCommentEdit => 'Modifier';

  @override
  String get ticketCommentDelete => 'Supprimer';

  @override
  String get ticketCommentSave => 'Sauvegarder';

  @override
  String get ticketNoDescription => 'Aucune description.';

  @override
  String get ticketOverdue => 'en retard';

  @override
  String get ticketDeleteTitle => 'Supprimer le ticket';

  @override
  String ticketCreatedOn(String date) {
    return 'le $date';
  }

  @override
  String ticketUpdatedOn(String date) {
    return 'Modifié le $date';
  }

  @override
  String ticketParent(String parent) {
    return 'Parent : $parent';
  }

  @override
  String get ticketParentLabel => 'Parent';

  @override
  String get statusCategory => 'Catégorie';

  @override
  String get status => 'Statut';

  @override
  String get created => 'Créé';

  @override
  String get updated => 'Modifié';

  @override
  String get statusColor => 'Couleur';

  @override
  String statusOrderLabel(int order) {
    return 'ordre $order';
  }

  @override
  String get statusCreateTitle => 'Nouveau statut';

  @override
  String get statusEditTitle => 'Modifier le statut';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navMenu => 'Menu';

  @override
  String get pwaUpdateAvailable => 'Une nouvelle version est disponible.';

  @override
  String get appTitle => 'Disciplan';

  @override
  String get pwaUpdate => 'Mettre à jour';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue de l\'application';

  @override
  String get settingsLanguageHint =>
      'Le changement de langue recharge l\'application.';

  @override
  String get settingsDisplayName => 'Nom d\'affichage';

  @override
  String get settingsDisplayNameHint =>
      'Ce nom est affiché aux autres utilisateurs de l\'application.';

  @override
  String get settingsDisplayNamePlaceholder => 'Votre nom d\'affichage';

  @override
  String get settingsDisplayNameSaved => 'Nom mis à jour.';

  @override
  String get settingsDisplayNameError =>
      'Impossible de mettre à jour le nom d\'affichage. Veuillez réessayer.';

  @override
  String get settingsTabProfile => 'Profil';

  @override
  String get settingsTabDashboard => 'Tableau de bord';

  @override
  String get settingsDashboardHint =>
      'Ordonnez et affichez les widgets de votre tableau de bord.';

  @override
  String get settingsDashboardEmpty => 'Aucun widget configuré.';

  @override
  String get settingsDashboardHide => 'Masquer';

  @override
  String get settingsDashboardShow => 'Afficher';

  @override
  String get savedviewLabel => 'Vue';

  @override
  String get savedviewCreateTitle => 'Nouvelle vue';

  @override
  String get savedviewEditTitle => 'Modifier la vue';

  @override
  String get savedviewFilters => 'Filtres';

  @override
  String get savedviewAllProjects => 'Tous les projets';

  @override
  String get savedviewAllTypes => 'Tous les types';

  @override
  String get savedviewAllPriorities => 'Toutes les priorités';

  @override
  String get savedviewStatusCategory => 'Catégorie de statut';

  @override
  String get savedviewAllCategories => 'Toutes les catégories';

  @override
  String get savedviewOnlyAssignedToMe => 'Uniquement assignés à moi';

  @override
  String get savedviewOnlyReportedByMe => 'Uniquement créés par moi';

  @override
  String get savedviewCollapsedByDefault =>
      'Réduit par défaut sur le tableau de bord';

  @override
  String get savedviewNameRequired => 'Le nom est requis.';

  @override
  String get ticketHistory => 'Activité';

  @override
  String get ticketHistoryEmpty => 'Aucune activité enregistrée.';

  @override
  String get historyCreated => 'a créé ce ticket';

  @override
  String get historyTitleChanged => 'a modifié le titre';

  @override
  String get historyDescriptionChanged => 'a modifié la description';

  @override
  String get historyStatusChanged => 'a changé le statut';

  @override
  String get historyTypeChanged => 'a changé le type';

  @override
  String get historyPriorityChanged => 'a changé la priorité';

  @override
  String get historyAssigneeChanged => 'a réassigné le ticket';

  @override
  String get historySprintChanged => 'a changé le sprint';

  @override
  String get historyStoryPointsChanged => 'a modifié les points';

  @override
  String get historyDueDateChanged => 'a modifié l\'échéance';

  @override
  String get historyCommentAdded => 'a ajouté un commentaire';

  @override
  String get historyCommentDeleted => 'a supprimé un commentaire';

  @override
  String get historyAttachmentAdded => 'a joint une pièce jointe';

  @override
  String get colCreateTitle => 'Nouvelle colonne';

  @override
  String get colEditTitle => 'Renommer la colonne';

  @override
  String get colDeleteTitle => 'Supprimer la colonne';

  @override
  String colDeleteConfirm(String name) {
    return 'Supprimer « $name » et toutes ses cartes ?';
  }

  @override
  String get colRef => 'Réf.';

  @override
  String get colTitle => 'Titre';

  @override
  String get colPriority => 'Priorité';

  @override
  String get colStatus => 'Statut';

  @override
  String get colSprint => 'Sprint';

  @override
  String get colDueDate => 'Échéance';

  @override
  String get colProject => 'Projet';

  @override
  String get colDueDateOptional => 'Due date (optional)';

  @override
  String homeWelcome(String name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get homeMyTickets => 'Mes tickets';

  @override
  String get homeActivity => 'Activité récente';

  @override
  String get homeNoTickets => 'Aucun ticket assigné.';

  @override
  String get homeNoActivity => 'Aucune activité récente.';

  @override
  String get homeViewAll => 'Voir tous';

  @override
  String get homeActivityCreated => 'Ticket créé';

  @override
  String get homeActivityUpdated => 'Ticket modifié';

  @override
  String get homeActivityCommented => 'Commentaire ajouté';

  @override
  String get homeActivityAttachment => 'Pièce jointe ajoutée';

  @override
  String get homeConfigure => 'Configurer';

  @override
  String get homeNoDashboardWidgets => 'Aucun widget visible.';

  @override
  String get homeConfigureDashboard => 'Configurer le tableau de bord';

  @override
  String get homeNoViewTickets => 'Aucun ticket pour cette vue.';

  @override
  String get myticketsTitle => 'Mes tickets';

  @override
  String get myticketsEmpty => 'Aucun ticket assigné.';

  @override
  String get statuscategoryBacklog => 'Backlog';

  @override
  String get statuscategoryInProgress => 'En cours';

  @override
  String get statuscategoryDone => 'Terminé';

  @override
  String get adminUsersTitle => 'Gestion des utilisateurs';

  @override
  String get adminUsersHeading => 'Utilisateurs';

  @override
  String get adminUsersPlaceholder =>
      'Administration des comptes. À implémenter.';

  @override
  String get adminUsersInvite => 'Inviter';

  @override
  String get adminUsersCreate => 'Créer un utilisateur';

  @override
  String adminUsersHeadingCount(int count) {
    return 'Utilisateurs ($count)';
  }

  @override
  String get adminUsersEmpty => 'Aucun utilisateur.';

  @override
  String get adminUsersCreatedOn => 'Créé le';

  @override
  String get adminUsersDeactivate => 'Désactiver';

  @override
  String get adminUsersActivate => 'Activer';

  @override
  String get adminUsersPromoteAdmin => 'Promouvoir Admin';

  @override
  String get adminUsersDemoteUser => 'Rétrograder en User';

  @override
  String get adminUsersCreateTitle => 'Créer un utilisateur';

  @override
  String get adminUsersDisplayName => 'Nom d\'affichage';

  @override
  String get adminUsersRole => 'Rôle';

  @override
  String get adminUsersRoleUser => 'Utilisateur';

  @override
  String get adminUsersRoleAdmin => 'Administrateur';

  @override
  String adminInvitationsHeading(int count) {
    return 'Invitations actives ($count)';
  }

  @override
  String get adminInvitationsEmpty => 'Aucune invitation en attente.';

  @override
  String get adminInviteOpenLink => 'Lien ouvert';

  @override
  String get adminInviteExpiresOn => 'Expire le';

  @override
  String get adminInviteCopyLink => 'Copier le lien';

  @override
  String get adminInviteTitle => 'Inviter un utilisateur';

  @override
  String get adminInviteDescription =>
      'Un lien d\'invitation sera généré. Partagez-le avec la personne à inviter. Le lien expire après 7 jours.';

  @override
  String get adminInviteEmailLabel => 'Email (optionnel)';

  @override
  String get adminInviteEmailHint =>
      'Si renseigné, l\'invitation sera limitée à cette adresse.';

  @override
  String get adminInviteGenerate => 'Générer le lien';

  @override
  String get notfoundTitle => 'Page introuvable';

  @override
  String get notfoundMessage =>
      'Désolé, le contenu que vous recherchez n\'existe pas.';

  @override
  String get timeJustNow => 'à l’instant';

  @override
  String timeMinutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String timeHoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String timeDaysAgo(int count) {
    return 'il y a $count j';
  }

  @override
  String get labelTitle => 'Étiquettes';

  @override
  String labelCount(int count) {
    return '$count étiquette(s)';
  }

  @override
  String get labelCreateTitle => 'Nouvelle étiquette';

  @override
  String get labelEditTitle => 'Modifier l\'étiquette';

  @override
  String get labelDeleteTitle => 'Supprimer l\'étiquette';

  @override
  String labelDeleteConfirm(String name) {
    return 'Supprimer « $name » ? L\'étiquette sera retirée de tous les tickets et boards.';
  }

  @override
  String get labelEmpty =>
      'Aucune étiquette. Créez-en une pour organiser vos tickets et boards.';

  @override
  String get labelCreateFirst => 'Créer une étiquette';

  @override
  String get labelName => 'Nom';

  @override
  String get labelColor => 'Couleur';

  @override
  String get labelPreview => 'Aperçu';

  @override
  String get labelField => 'Étiquettes';

  @override
  String get labelNoItems =>
      'Aucun ticket ni board avec cette étiquette pour le moment.';

  @override
  String labelItemCount(int tickets, int boards) {
    return '$tickets ticket(s) · $boards board(s)';
  }

  @override
  String get membersTitle => 'Membres';

  @override
  String get membersAdd => 'Ajouter un membre';

  @override
  String get membersNone => 'Aucun membre pour le moment.';

  @override
  String get membersSelectUser => 'Sélectionner un utilisateur';

  @override
  String get membersRole => 'Rôle';

  @override
  String get membersChangeRole => 'Changer le rôle';

  @override
  String get membersRemove => 'Retirer le membre';

  @override
  String membersRemoveConfirm(String name) {
    return 'Retirer $name de cette ressource ?';
  }

  @override
  String get homeActiveSprints => 'Sprints actifs';

  @override
  String get homeOverdue => 'En retard';

  @override
  String get homeInProgress => 'En cours';

  @override
  String get setupSubtitle => 'Configuration initiale';

  @override
  String get setupNoAccount =>
      'Aucun compte n\'existe encore. Créez le premier compte administrateur.';

  @override
  String get setupPasswordHint =>
      'Minimum 8 caractères, avec majuscule, minuscule et chiffre.';

  @override
  String get setupCreating => 'Création en cours…';

  @override
  String get setupCreateAdmin => 'Créer le compte administrateur';

  @override
  String get invitationSubtitle => 'Créer votre compte';

  @override
  String get invitationInvalid => 'Invitation invalide ou expirée';

  @override
  String get invitationInvalidDesc =>
      'Ce lien d\'invitation n\'est plus valide.';

  @override
  String get invitationBackToLogin => 'Retour à la connexion';

  @override
  String get invitationValid =>
      'Invitation valide. Renseignez vos informations pour créer votre compte.';

  @override
  String get invitationCreateAccount => 'Créer mon compte';

  @override
  String get settingsTabAppearance => 'Apparence';

  @override
  String get settingsThemeLabel => 'Thème';

  @override
  String get settingsThemeCustom => 'Thème personnalisé';

  @override
  String get settingsThemeActive => 'Actif';

  @override
  String get settingsThemeActivate => 'Activer';

  @override
  String get settingsStatsShow => 'Afficher les statistiques rapides';

  @override
  String get settingsStatsDescription =>
      'Tickets assignés, sprints actifs, retards et tickets en cours.';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeToDark => 'Passer en mode sombre';

  @override
  String get settingsThemeToLight => 'Passer en mode clair';

  @override
  String get cardCreatedOn => 'Créée le';

  @override
  String get cardUpdatedOn => 'Modifiée le';

  @override
  String get cardCreatedBy => 'Créé par :';

  @override
  String get cardAssignedTo => 'Assigné à :';

  @override
  String get cardNoComments => 'Aucun commentaire pour l\'instant.';

  @override
  String get cardEdited => '(modifié)';

  @override
  String get cardCommentSend => 'Envoyer';

  @override
  String get cardEditTitle => 'Modifier la carte';

  @override
  String get cardDeleteTitle => 'Supprimer la carte';

  @override
  String cardDeleteConfirm(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get cardCommentPlaceholder => 'Ajouter un commentaire…';

  @override
  String get cardNoDescription => 'Aucune description.';

  @override
  String get cardOverdue => '— en retard';

  @override
  String get labelpickerRemove => 'Retirer';

  @override
  String get labelpickerFilter => 'Filtrer…';

  @override
  String get labelpickerEmpty => 'Aucune étiquette trouvée.';

  @override
  String get labelTickets => 'Tickets';

  @override
  String get adminActivate => 'Activer';

  @override
  String get adminPromoteAdmin => 'Promouvoir Admin';

  @override
  String get attachmentSectionLabel => 'Pièces jointes';

  @override
  String get attachmentAdd => 'Ajouter';

  @override
  String get attachmentAddFiles => 'Ajouter des fichiers';

  @override
  String get attachmentAttach => 'Joindre';

  @override
  String get attachmentAttachFiles => 'Joindre des fichiers';

  @override
  String get attachmentUploading => 'Envoi en cours…';

  @override
  String get attachmentEmpty =>
      'Aucune pièce jointe — cliquez sur Ajouter pour en joindre';

  @override
  String get attachmentPreview => 'Aperçu';

  @override
  String get attachmentOpenInTab => 'Ouvrir dans un onglet';

  @override
  String get attachmentOpenInNewTab => 'Ouvrir dans un nouvel onglet';

  @override
  String get attachmentNewTab => 'Nouvel onglet';

  @override
  String get attachmentDownload => 'Télécharger';

  @override
  String get attachmentDownloadFile => 'Télécharger le fichier';

  @override
  String get attachmentNoPreview =>
      'L\'aperçu n\'est pas disponible pour ce type de fichier.';

  @override
  String get attachmentLoadingPreview => 'Chargement en cours…';

  @override
  String get attachmentRetry => 'Réessayer';

  @override
  String attachmentErrorUpload(String error) {
    return 'Erreur lors de l\'envoi : $error';
  }

  @override
  String attachmentErrorDownload(String error) {
    return 'Erreur lors du téléchargement : $error';
  }

  @override
  String attachmentErrorOpen(String error) {
    return 'Erreur lors de l\'ouverture : $error';
  }

  @override
  String attachmentErrorDelete(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String attachmentErrorLoad(String error) {
    return 'Impossible de charger le fichier : $error';
  }

  @override
  String get ticketCommentSubmit => 'Commenter';

  @override
  String get authHeadline => 'De l’idée à l’accomplissement.';

  @override
  String get authIntroduction =>
      'Un espace pour organiser vos projets, faire avancer vos équipes et vous concentrer sur l’essentiel.';

  @override
  String get authDisplayNameHint => 'ex. Marie Curie';

  @override
  String get authEmailHint => 'vous@exemple.com';

  @override
  String get authHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get authHomelabServer => 'Serveur Homelab';

  @override
  String get authInvitationSubtitle =>
      'Complétez votre inscription via votre jeton d\'invitation.';

  @override
  String get authInvitationTokenHint => 'ex. inv_8f93ab...';

  @override
  String get authInvitationTokenLabel => 'Jeton d\'invitation';

  @override
  String get authJoinTeam => 'Rejoindre une Équipe';

  @override
  String get authLoginTagline =>
      'Pilotez vos sprints et tickets en haute vélocité.';

  @override
  String get authLoginTitle => 'Connexion à Disciplan';

  @override
  String get authReceivedInvitation => 'Vous avez reçu une invitation ?';

  @override
  String get authServerTest => 'Tester';

  @override
  String get authServerTestFailed => 'Échec de connexion au serveur Homelab.';

  @override
  String get authServerTestSuccess => 'Connexion établie avec succès.';

  @override
  String get authSetupDisplayNameHint => 'ex. Alexandre Gailloty';

  @override
  String get authSetupFillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get authSetupIntro =>
      'Initialisez votre instance Homelab en créant le compte administrateur racine.';

  @override
  String get authSetupPasswordLabel => 'Mot de passe (min. 8 caractères)';

  @override
  String get authSetupPasswordTooShort =>
      'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get authSetupTitle => 'Premier Démarrage';

  @override
  String get authValidateInvitation => 'Valider l\'invitation';

  @override
  String get calCopyIcalUrl => 'Copier l\'URL iCal';

  @override
  String get calFilterAll => 'Tout voir';

  @override
  String get calFilterSprints => 'Sprints';

  @override
  String get calGenerateToken => 'Générer le jeton';

  @override
  String get calIcalNoFeed =>
      'Aucun flux actif. Générez votre jeton privé pour synchroniser votre calendrier.';

  @override
  String get calIcalSyncTitle => 'Synchronisation iCal / Agenda externe';

  @override
  String get calIcalUrlCopied => 'URL du flux iCal copiée';

  @override
  String get calNoMilestones => 'Aucun jalon ou ticket daté pour ce filtre.';

  @override
  String get calRegenerateToken => 'Régénérer le jeton';

  @override
  String get calSprintMilestone => 'Jalon de cycle';

  @override
  String get calTeamCalendarSubtitle =>
      'Jalons de sprint, échéances de tickets et synchronisation iCal';

  @override
  String get calTeamCalendarTitle => 'Calendrier d\'Équipe';

  @override
  String calTokenError(String error) {
    return 'Erreur token: $error';
  }

  @override
  String get cmdCategoryActions => 'Actions rapides';

  @override
  String get cmdCategoryNavigation => 'Navigation';

  @override
  String get cmdCategoryTickets => 'Tickets';

  @override
  String get cmdCreateTask => 'Créer une tâche';

  @override
  String get cmdEscapeKey => 'Échap';

  @override
  String get cmdFooterBrand => 'Disciplan Neo-Linear';

  @override
  String get cmdNavCalendar => 'Calendrier d\'Équipe';

  @override
  String get cmdNavCycles => 'Cycles & Sprints';

  @override
  String get cmdNavSettings => 'Paramètres & Administration';

  @override
  String get cmdNavSprintKanban => 'Tableau Kanban du Sprint';

  @override
  String get cmdNavigate => 'Naviguer';

  @override
  String cmdNoResults(String query) {
    return 'Aucun résultat correspondant à “$query”';
  }

  @override
  String get cmdOpen => 'Ouvrir';

  @override
  String get cmdSearchHint => 'Rechercher un ticket, une action ou naviguer...';

  @override
  String get errorBadRequest => 'Requête invalide.';

  @override
  String get errorConflict =>
      'Un conflit est survenu (élément déjà existant ou modifié).';

  @override
  String get errorForbidden => 'Accès refusé pour cette opération.';

  @override
  String get errorGenericNetwork => 'Une erreur réseau est survenue.';

  @override
  String get errorNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion et l\'URL du serveur.';

  @override
  String get errorNotFound => 'Ressource introuvable.';

  @override
  String get errorServer => 'Une erreur interne est survenue sur le serveur.';

  @override
  String get errorUnauthorized => 'Identifiants invalides ou session expirée.';

  @override
  String kanbanBoardLoadError(String error) {
    return 'Erreur de chargement du tableau: $error';
  }

  @override
  String get kanbanDropTicketHere => 'Glisser une tâche ici';

  @override
  String get kanbanDueToday => 'Aujourd\'hui';

  @override
  String get kanbanDueTomorrow => 'Demain';

  @override
  String get kanbanDueYesterday => 'Hier';

  @override
  String kanbanErrorWithDetail(String error) {
    return 'Erreur: $error';
  }

  @override
  String get kanbanFilterCardsHint => 'Filtrer les cartes...';

  @override
  String get kanbanHideMetrics => 'Masquer en-tête';

  @override
  String get kanbanMoveToStatus => 'Déplacer vers...';

  @override
  String get kanbanNoStatuses => 'Aucun statut défini pour ce projet.';

  @override
  String get kanbanNoStatusesAvailable => 'Aucun statut disponible.';

  @override
  String kanbanNoTicketsInStatus(String status) {
    return 'Aucune tâche dans \"$status\"';
  }

  @override
  String kanbanOpenSprintBoard(String name) {
    return 'Ouvrir le Kanban de \"$name\"';
  }

  @override
  String get kanbanPriorityHighFilter => 'Priorité Haute';

  @override
  String get kanbanSelectProject =>
      'Sélectionnez un projet pour afficher son tableau Kanban.';

  @override
  String get kanbanShowMetrics => 'Afficher métriques';

  @override
  String kanbanStartNamed(String name) {
    return 'Démarrer \"$name\"';
  }

  @override
  String get kanbanSwitchSprintTooltip => 'Changer de sprint affiché';

  @override
  String get kanbanViewBacklog => 'Voir le Backlog';

  @override
  String get priorityCritical => 'Urgente';

  @override
  String get priorityHigh => 'Haute';

  @override
  String get priorityLow => 'Basse';

  @override
  String get priorityMedium => 'Moyenne';

  @override
  String get projActiveProjects => 'Projets actifs';

  @override
  String projActiveSpace(String key, String name) {
    return 'Espace actif : $key — $name';
  }

  @override
  String get projActiveSpaceBadge => 'Espace actif';

  @override
  String get projAllMyProjects => 'Tous mes projets';

  @override
  String get projCardDescriptionFallback =>
      'Espace projet encapsulé — cliquez pour accéder à ses tickets et cycles.';

  @override
  String get projCreateNew => 'Créer un projet';

  @override
  String get projCreateSubmit => 'Créer le projet';

  @override
  String get projCreateSubtitle =>
      'Configurez un espace de travail collaboratif pour aligner vos sprints et tickets.';

  @override
  String get projCycles => 'Cycles';

  @override
  String get projDashboardGeneral => 'Dashboard Général';

  @override
  String get projDescriptionHint =>
      'Résumez les objectifs stratégiques et le périmètre...';

  @override
  String get projDescriptionLabel => 'Description & vision';

  @override
  String get projEmptyHint =>
      'Créez votre premier projet pour organiser vos tickets et sprints.';

  @override
  String get projExplorerSubtitle =>
      'Sélectionnez ou créez un projet pour afficher sa vue liste et son backlog.';

  @override
  String get projExplorerTitle => 'Explorateur de Projets';

  @override
  String get projFilterMember => 'Membre d\'équipe';

  @override
  String get projInitiationAgile => 'Initiation agile';

  @override
  String get projKeyAuto => 'Auto';

  @override
  String projLoadError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get projMember => 'Membre du projet';

  @override
  String get projNameHint => 'ex. Campagne de Marque 2025';

  @override
  String get projNameLabel => 'Nom du projet *';

  @override
  String get projNameRequired => 'Veuillez saisir le nom du projet.';

  @override
  String get projNoMatch => 'Aucun projet ne correspond à ce filtre.';

  @override
  String get projOwner => 'Propriétaire';

  @override
  String get projPortfolio => 'Portefeuille de projets';

  @override
  String get projSearchHint => 'Rechercher un projet (nom, clé)...';

  @override
  String get projSelectSubtitle =>
      'Sélectionnez un projet pour encapsuler votre espace de travail ou accédez directement à son Backlog, Kanban ou Cycles.';

  @override
  String get projSprintsCycles => 'Sprints & Cycles';

  @override
  String get projTotalTickets => 'Tickets cumulés';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleGuest => 'Invité';

  @override
  String get roleMember => 'Membre';

  @override
  String get roleSupervisor => 'Superviseur';

  @override
  String get settingsActive => 'Actif';

  @override
  String get settingsAdminInvitationsSubtitle =>
      'Générez des liens d\'invitation à usage unique pour intégrer de nouveaux membres';

  @override
  String get settingsAdminInvitationsTitle =>
      'Administration — Invitations (7 jours)';

  @override
  String get settingsAdminUsersSubtitle =>
      'Activer, désactiver ou changer les rôles des utilisateurs de l\'instance';

  @override
  String get settingsAdminUsersTitle => 'Administration — Gestion des Comptes';

  @override
  String get settingsAll => 'Tous';

  @override
  String get settingsApply => 'Appliquer';

  @override
  String get settingsCopyToken => 'Copier le jeton';

  @override
  String get settingsDefaultUser => 'Utilisateur';

  @override
  String get settingsGenerateInviteLink => 'Générer un lien (7j)';

  @override
  String get settingsHeaderSubtitle =>
      'Préférences utilisateur, configuration Homelab et gestion des accès';

  @override
  String get settingsInactive => 'Inactif';

  @override
  String settingsInvitationsError(String error) {
    return 'Erreur chargement invitations: $error';
  }

  @override
  String get settingsInviteEmailHint => 'adresse@entreprise.com';

  @override
  String get settingsInviteEmailInvalid =>
      'Veuillez saisir une adresse email valide.';

  @override
  String settingsInviteError(String error) {
    return 'Erreur lors de la création de l\'invitation : $error';
  }

  @override
  String get settingsInviteExpired => 'Expirée';

  @override
  String settingsInviteGenerated(String email) {
    return 'Invitation générée pour $email !';
  }

  @override
  String get settingsInviteLinkCopied =>
      'Lien d\'invitation copié dans le presse-papiers';

  @override
  String get settingsInviteUsed => 'Déjà utilisée';

  @override
  String get settingsInviteValid => 'Valide';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsNotConnected => 'Non connecté';

  @override
  String get settingsPendingInvitations => 'Invitations en attente ou récentes';

  @override
  String get settingsPin => 'Épingler';

  @override
  String get settingsProfileSubtitle =>
      'Gérez vos informations de compte Disciplan';

  @override
  String get settingsProfileTitle => 'Profil & Compte';

  @override
  String settingsSavedViewSummary(String project, String type) {
    return 'Projet: $project • Type: $type';
  }

  @override
  String get settingsSavedViewsEmpty =>
      'Aucune vue sauvegardée pour le moment. Vous pouvez en créer depuis la Vue Liste.';

  @override
  String settingsSavedViewsError(String error) {
    return 'Impossible de charger les vues : $error';
  }

  @override
  String get settingsSavedViewsSubtitle =>
      'Gérez vos filtres et vues personnalisées épinglées à la barre latérale';

  @override
  String get settingsSavedViewsTitle => 'Vues Sauvegardées';

  @override
  String get settingsScaleComfort => 'Confort (110%)';

  @override
  String get settingsScaleCompact => 'Compact (90%)';

  @override
  String get settingsScaleDecrease => 'Réduire (-5%)';

  @override
  String get settingsScaleFactor => 'Facteur de mise à l\'échelle';

  @override
  String get settingsScaleHint =>
      'Astuce : vous pouvez saisir n\'importe quel pourcentage entre 50% et 200%, ou ajuster le facteur depuis la barre supérieure.';

  @override
  String get settingsScaleIncrease => 'Augmenter (+5%)';

  @override
  String get settingsScaleLarge => 'Grand écran (120%)';

  @override
  String get settingsScaleReset => 'Réinitialiser (100%)';

  @override
  String get settingsScaleStandard => 'Standard (100%)';

  @override
  String get settingsScalingSubtitle =>
      'Adaptez la taille des polices et des éléments visuels à la résolution de votre écran';

  @override
  String get settingsScalingTitle =>
      'Affichage & Mise à l\'échelle (UI Scaling)';

  @override
  String get settingsServerHint =>
      'Les requêtes HTTP et l\'abonnement iCal s\'appuient sur cette URL de base.';

  @override
  String get settingsServerSubtitle =>
      'Adresse de votre instance Disciplan sur le réseau local ou distant';

  @override
  String get settingsServerTitle => 'Serveur Homelab';

  @override
  String get settingsServerUnreachable => 'Impossible de contacter le serveur';

  @override
  String get settingsServerUrlUpdated => 'URL du serveur Homelab mise à jour';

  @override
  String get settingsSessionSubtitle =>
      'Déconnecte ce poste de votre instance Disciplan';

  @override
  String get settingsSessionTitle => 'Session active';

  @override
  String get settingsTokenCopied => 'Jeton d\'invitation copié';

  @override
  String get settingsUnpin => 'Détacher';

  @override
  String settingsUpdateError(String error) {
    return 'Erreur lors de la mise à jour : $error';
  }

  @override
  String settingsUsersError(String error) {
    return 'Erreur chargement utilisateurs: $error';
  }

  @override
  String get settingsYou => '(vous)';

  @override
  String shellActiveSprintName(String name) {
    return 'Sprint actif : $name';
  }

  @override
  String shellActivityError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get shellAllProjects => 'Tous mes Projets';

  @override
  String get shellApply => 'Appliquer';

  @override
  String get shellChangeProject => 'Changer de projet';

  @override
  String get shellCollapseSidebar => 'Replier la barre latérale (⌘B)';

  @override
  String get shellCrumbBacklog => 'Backlog du Projet';

  @override
  String get shellCrumbBacklogList => 'Backlog & Vue Liste';

  @override
  String get shellCrumbCycles => 'Cycles & Sprints';

  @override
  String get shellCrumbMyTasks => 'Mon Dashboard & Tâches';

  @override
  String get shellCrumbWorkspace => 'Espace';

  @override
  String shellDisplaySize(int percent) {
    return 'Taille d\'affichage ($percent%)';
  }

  @override
  String get shellMobileCycles => 'Cycles';

  @override
  String get shellMobileDashboard => 'Dashboard';

  @override
  String get shellMobileProjects => 'Mes Projets';

  @override
  String get shellMobileTasks => 'Tâches';

  @override
  String get shellNewTask => 'Nouvelle tâche';

  @override
  String get shellPersonalSpace => 'Espace personnel';

  @override
  String get shellSidebarDashboardSubtitle => 'Projets et mes tickets';

  @override
  String get shellTooltipDashboard => 'Tableau de bord';

  @override
  String get shellProjectPlan => 'Plan du projet';

  @override
  String get shellProjectViews => 'Vues du projet';

  @override
  String get shellScaleComfort => 'Confort (110%)';

  @override
  String get shellScaleCompact => 'Compact (90%)';

  @override
  String shellScaleCustom(int percent) {
    return 'Facteur personnalisé ($percent%)...';
  }

  @override
  String get shellScaleCustomHint =>
      'Choisissez un facteur entre 50% et 200% (ou utilisez les préréglages 90%, 100%, 110%, 120%).';

  @override
  String get shellScaleCustomTitle =>
      'Facteur de mise à l\'échelle personnalisé';

  @override
  String get shellScaleLarge => 'Grand écran (120%)';

  @override
  String get shellScaleReset => '100% (Défaut)';

  @override
  String get shellScaleStandard => 'Standard (100%)';

  @override
  String get shellSearchPlaceholder =>
      'Rechercher une tâche, aller au Kanban, Backlog...';

  @override
  String get shellSelectProject => 'Sélectionner un projet';

  @override
  String get shellSidebarAdmin => 'Administration';

  @override
  String get shellSidebarCalendar => 'Calendrier & Jalons';

  @override
  String get shellSidebarCalendarSubtitle => 'Échéances & flux iCal';

  @override
  String get shellSidebarCurrentSprints => 'Sprints en cours';

  @override
  String get shellSidebarCyclesSubtitle => 'Cycles, vélocité & roadmap';

  @override
  String get shellSidebarKanban => 'Tableau Kanban';

  @override
  String get shellSidebarListSubtitle => 'Backlog & tickets du projet';

  @override
  String get shellSidebarListView => 'Vue Liste';

  @override
  String get shellSidebarMyTasks => 'Dashboard & Mes Tâches';

  @override
  String get shellSidebarMyTasksSubtitle => 'Vue globale & tickets assignés';

  @override
  String get shellSidebarPlanning => 'Planning & Cycles';

  @override
  String get shellSidebarPortfolioSubtitle => 'Portefeuille & espaces projets';

  @override
  String get shellSidebarTeamSettings => 'Paramètres d\'équipe';

  @override
  String get shellSprintCapacity => 'Capacité Sprint';

  @override
  String get shellSprintNoneActive => 'Aucun actif';

  @override
  String get shellSprintProgress => 'Avancement Sprint';

  @override
  String get shellSwitchProject => 'Changer de projet actif';

  @override
  String get shellToggleSidebar => 'Basculer la barre latérale (⌘B)';

  @override
  String get shellTooltipBacklog => 'Backlog & Tickets du projet';

  @override
  String get shellTooltipCalendar => 'Calendrier d\'équipe';

  @override
  String get shellTooltipCycles => 'Cycles & Feuille de route';

  @override
  String get shellTooltipKanban => 'Tableau Kanban des Sprints';

  @override
  String get shellTooltipMyTasks => 'Tableau de bord & Mes Tâches';

  @override
  String get shellTooltipSearch => 'Recherche globale (⌘K)';

  @override
  String get shellTooltipSettings => 'Paramètres (⌘,)';

  @override
  String get sprintBacklogTicketsTitle => 'Tickets du Backlog à inclure';

  @override
  String get sprintCadenceFlash => 'Flash (7j)';

  @override
  String get sprintCadenceOneMonth => '1 mois';

  @override
  String get sprintCadenceOneWeek => '1 sem.';

  @override
  String get sprintCadenceOptimal => 'Optimal (14j)';

  @override
  String get sprintCadenceProject => 'Projet (30j)';

  @override
  String get sprintCadenceTitle => 'Rythme & Fréquence';

  @override
  String get sprintCadenceTwoWeeks => '2 sem.';

  @override
  String sprintCadenceWeeks(int weeks, int days) {
    return '$weeks semaine(s) (${days}j)';
  }

  @override
  String get sprintClosedCyclesSection => 'Cycles clôturés & historique';

  @override
  String sprintClosedTicketsProgress(int closed, int total) {
    return '$closed/$total terminées';
  }

  @override
  String sprintContributorsCount(int count) {
    return '$count contributeurs';
  }

  @override
  String get sprintCreateCycle => 'Créer un cycle';

  @override
  String get sprintCreateModalTitle => 'Créer et planifier un cycle';

  @override
  String get sprintCreatedSuccess => 'Sprint créé avec succès !';

  @override
  String sprintCyclesSubtitle(String name) {
    return 'Planification temporelle et métriques de vélocité du projet $name.';
  }

  @override
  String get sprintCyclesTitle => 'Cycles & Sprints';

  @override
  String get sprintDatesNotDefined => 'Dates non définies';

  @override
  String get sprintDatesUndefined => 'Dates indéfinies';

  @override
  String sprintDaysRemaining(int count) {
    return 'J-$count restants';
  }

  @override
  String sprintDaysRemainingBadge(int count) {
    return 'J-$count';
  }

  @override
  String sprintDefaultName(int month) {
    return 'Sprint $month — Optimisations & Livrables';
  }

  @override
  String get sprintEndDate => 'Date de fin';

  @override
  String get sprintFinish => 'Terminer le sprint';

  @override
  String get sprintGoalHint =>
      'Ex: Finaliser la refonte graphique et valider la campagne de marque...';

  @override
  String get sprintGoalLabel => 'Objectif principal du cycle (Sprint Goal)';

  @override
  String sprintLoadError(String error) {
    return 'Erreur de chargement: $error';
  }

  @override
  String get sprintNameHint => 'Ex: Sprint 5 — Production & Lancement';

  @override
  String get sprintNameLabel => 'Nom du cycle / sprint';

  @override
  String get sprintNameRequired => 'Veuillez saisir un nom de sprint.';

  @override
  String get sprintNewTask => 'Nouvelle tâche';

  @override
  String get sprintNoActiveCycleDesc =>
      'Démarrez un cycle planifié, prévisualisez son Kanban ou créez un nouveau sprint.';

  @override
  String get sprintNoBacklogTickets =>
      'Aucun ticket disponible dans le backlog.';

  @override
  String get sprintNoClosedCycles => 'Aucun cycle clôturé.';

  @override
  String get sprintNoPlannedCycles => 'Aucun cycle planifié pour le moment.';

  @override
  String sprintPercentCompleted(int percent) {
    return '$percent% complété';
  }

  @override
  String get sprintPlannedCyclesSection => 'Cycles planifiés';

  @override
  String sprintPointsShort(int points) {
    return '$points pts';
  }

  @override
  String sprintRemainingTickets(int count) {
    return '$count restantes';
  }

  @override
  String get sprintRemainingTicketsSub => 'en cours / à faire';

  @override
  String get sprintSelectProject =>
      'Sélectionnez un projet pour afficher ses cycles.';

  @override
  String sprintSelectedTicketsSummary(int count, int points) {
    return '$count tâche(s) · $points pts';
  }

  @override
  String get sprintStartCycle => 'Démarrer le cycle';

  @override
  String get sprintStartDate => 'Date de début';

  @override
  String get sprintStartImmediately => 'Démarrer immédiatement ce sprint';

  @override
  String get sprintStartImmediatelyHint =>
      'Le sprint passera au statut Actif dès sa création.';

  @override
  String get sprintStatusActive => 'Actif';

  @override
  String get sprintStatusClosed => 'Clos';

  @override
  String get sprintStatusPlanned => 'Planifié';

  @override
  String get sprintSuggested => 'Suggéré :';

  @override
  String get sprintSuggestion1 => 'Déploiement Capsule Q3';

  @override
  String get sprintSuggestion2 => 'Optimisations & Recette';

  @override
  String sprintTaskCount(int count) {
    return '$count tâche(s)';
  }

  @override
  String get sprintTeamBurndown => 'Burn-down d\'équipe';

  @override
  String get ticketsActiveCycle => 'Cycle actif';

  @override
  String ticketsActiveSprintName(String name) {
    return 'Sprint actif : $name';
  }

  @override
  String get ticketsAddFirstQuickTask =>
      'Ajoutez votre première tâche rapide ci-dessous.';

  @override
  String get ticketsAddNoteHint => 'Ajouter une note...';

  @override
  String get ticketsAddSubtaskHint => '+ Ajouter une sous-tâche...';

  @override
  String get ticketsAssign => 'Assigner';

  @override
  String get ticketsAssignMember => 'Assigner à un membre du projet';

  @override
  String get ticketsAssignSelectionToSprint =>
      'Affecter la sélection à un sprint';

  @override
  String get ticketsAssignTo => 'Assigner à';

  @override
  String get ticketsAssignToSprint => 'Affecter à un sprint';

  @override
  String ticketsAssignToSprintFailed(String detail) {
    return 'Erreur lors de l\'affectation au sprint : $detail';
  }

  @override
  String get ticketsAssignedLabel => 'ASSIGNÉ';

  @override
  String get ticketsAssigneeLabel => 'Assigné';

  @override
  String get ticketsBacklogHeaderDesc =>
      'Tickets hors sprint en attente de planification. Affectez-les à un sprint ou modifiez leur priorité.';

  @override
  String get ticketsBacklogListView => 'Backlog & Vue Liste';

  @override
  String get ticketsBacklogNoSprint => 'Backlog (sans sprint)';

  @override
  String get ticketsBacklogPrioritize => 'Lister et prioriser le backlog';

  @override
  String get ticketsBacklogProjectBadge => 'BACKLOG DU PROJET';

  @override
  String get ticketsBacklogScopeChip => 'Backlog (Hors sprint)';

  @override
  String get ticketsBacklogSectionSubtitle =>
      'Tickets du backlog prêts à être planifiés ou démarrés';

  @override
  String ticketsBacklogToPlan(int count) {
    return '$count ticket(s) hors sprint à planifier';
  }

  @override
  String get ticketsChangeStatus => 'Changer le statut';

  @override
  String ticketsCommentAddFailed(String detail) {
    return 'Erreur ajout commentaire: $detail';
  }

  @override
  String get ticketsCommentPosted => 'Commentaire publié';

  @override
  String get ticketsCopyLink => 'Copier le lien';

  @override
  String get ticketsCreateAnother => 'Créer une autre tâche';

  @override
  String get ticketsCreateAnotherNext => 'Créer une autre tâche ensuite';

  @override
  String ticketsCreateFailed(String detail) {
    return 'Erreur lors de la création : $detail';
  }

  @override
  String get ticketsCreateTask => 'Créer la tâche';

  @override
  String get ticketsCreateTicket => 'Créer un ticket';

  @override
  String get ticketsCycleSprint => 'CYCLE / SPRINT';

  @override
  String get ticketsCycles => 'Cycles';

  @override
  String ticketsCyclesOf(String name) {
    return 'Cycles de $name';
  }

  @override
  String get ticketsCyclesSprints => 'Cycles & Sprints';

  @override
  String get ticketsDescriptionHint =>
      'Ajouter une description détaillée (Markdown supporté)...';

  @override
  String get ticketsDoneSubtitle => 'Tickets livrés et validés';

  @override
  String get ticketsEditPriority => 'Modifier la priorité';

  @override
  String get ticketsEditableAnytime => 'Modifiable à tout moment';

  @override
  String get ticketsEnterKey => 'Entrée';

  @override
  String ticketsErrorDetail(String detail) {
    return 'Erreur: $detail';
  }

  @override
  String ticketsFilterAll(int count) {
    return 'Toutes ($count)';
  }

  @override
  String get ticketsFilterByPriority => 'Filtrer par priorité';

  @override
  String ticketsFilterDone(int count) {
    return 'Terminées ($count)';
  }

  @override
  String ticketsFilterInProgress(int count) {
    return 'En cours ($count)';
  }

  @override
  String get ticketsFilterTicketsHint =>
      'Filtrer les tickets (titre, réf, assigné)...';

  @override
  String ticketsFilterTodo(int count) {
    return 'À faire ($count)';
  }

  @override
  String ticketsFilterUrgent(int count) {
    return 'Urgentes ($count)';
  }

  @override
  String ticketsFocusInProgress(int count) {
    return 'FOCUS — VOS TICKETS EN COURS ($count)';
  }

  @override
  String get ticketsFullPortfolio => 'Portefeuille complet';

  @override
  String get ticketsHistoryTab => 'Historique';

  @override
  String ticketsInProgressAttention(int count) {
    return '$count tâche(s) en cours requièrent votre attention.';
  }

  @override
  String get ticketsInProgressSubtitle => 'Tickets activement travaillés';

  @override
  String get ticketsIsolateInProgress => 'Isoler En cours →';

  @override
  String get ticketsKanbanBoard => 'Tableau Kanban';

  @override
  String get ticketsKeepOpenHint => 'Garder la modale ouverte pour enchaîner';

  @override
  String ticketsLoadError(String detail) {
    return 'Erreur de chargement: $detail';
  }

  @override
  String get ticketsLoadTicketFailed => 'Impossible de charger le ticket';

  @override
  String get ticketsManageSprints => 'Gérer les Sprints';

  @override
  String get ticketsMyProjectsSpaces => 'MES PROJETS — ESPACES ENCAPSULÉS';

  @override
  String get ticketsNewTask => 'Nouvelle tâche';

  @override
  String get ticketsNoAttachment => 'Aucune pièce jointe.';

  @override
  String get ticketsNoExchange => 'Aucun échange pour le moment.';

  @override
  String get ticketsNoLabel => 'Aucun label associé';

  @override
  String get ticketsNoSubtask => 'Aucune sous-tâche pour ce ticket.';

  @override
  String get ticketsNoTaskInSection => 'Aucune tâche dans cette section.';

  @override
  String get ticketsNoTaskMatchFilter =>
      'Aucune tâche ne correspond à ce filtre.';

  @override
  String get ticketsNoTicketBacklog => 'Aucun ticket dans le backlog';

  @override
  String get ticketsNoTicketMatchSearch =>
      'Aucun ticket ne correspond à votre recherche.';

  @override
  String get ticketsNoTicketSprint => 'Aucun ticket dans ce sprint';

  @override
  String get ticketsNone => 'Aucune';

  @override
  String ticketsNotFoundRef(String ref) {
    return 'Ticket non trouvé : $ref';
  }

  @override
  String get ticketsNotSet => 'Non définie';

  @override
  String get ticketsNotesHint =>
      'Ajouter des notes, contexte ou critères de validation...';

  @override
  String ticketsOtherAssignedTasks(int count) {
    return 'AUTRES TÂCHES ASSIGNÉES ($count)';
  }

  @override
  String get ticketsOwner => 'Propriétaire';

  @override
  String ticketsPercentDone(int percent) {
    return '$percent% complété';
  }

  @override
  String get ticketsPersonalDashboardBadge => 'TABLEAU DE BORD PERSONNEL';

  @override
  String get ticketsPinToHome => 'Épingler sur l\'accueil / sidebar';

  @override
  String ticketsPlanInSprint(int count) {
    return 'Planifier $count ticket(s) dans un sprint';
  }

  @override
  String ticketsPlannedInSprint(int count, String name) {
    return '$count ticket(s) planifié(s) dans \"$name\".';
  }

  @override
  String get ticketsPriorityAll => 'Priorité : Toutes';

  @override
  String ticketsPrioritySelected(String priority) {
    return 'Priorité : $priority';
  }

  @override
  String get ticketsProjectBacklogTitle => 'Backlog du Projet';

  @override
  String ticketsProjectTileSummary(int tickets, int sprints, String role) {
    return '$tickets tickets • $sprints sprints • $role';
  }

  @override
  String get ticketsQuickAddHint => '+ Ajouter une tâche rapide... (Entrée)';

  @override
  String ticketsQuickAddInSection(String section) {
    return 'Ajouter une tâche rapide dans \"$section\"...';
  }

  @override
  String get ticketsQuickMetadata => 'MÉTADONNÉES RAPIDES';

  @override
  String get ticketsRecentExchanges => 'Échanges récents';

  @override
  String get ticketsRefCopied => 'Référence copiée dans le presse-papier';

  @override
  String get ticketsResetFilters => 'Réinitialiser les filtres';

  @override
  String get ticketsSaveAsViewTitle => 'Enregistrer comme vue sauvegardée';

  @override
  String get ticketsSaveView => 'Sauvegarder la vue';

  @override
  String get ticketsSavedViewActivated => 'Vue sauvegardée activée.';

  @override
  String get ticketsSavedViews => 'Vues enregistrées';

  @override
  String get ticketsSelectProject => 'Sélectionner';

  @override
  String ticketsSelectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String ticketsSprintChangeFailed(String detail) {
    return 'Erreur changement de sprint : $detail';
  }

  @override
  String get ticketsSprintCycle => 'Sprint / Cycle';

  @override
  String get ticketsSprintHeaderDesc =>
      'Liste détaillée des tickets affectés à ce cycle.';

  @override
  String get ticketsSprintListBadge => 'LISTE DU SPRINT';

  @override
  String get ticketsSprintPlanHint =>
      'Planifier, démarrer ou clôturer un sprint';

  @override
  String get ticketsSprintTicketsTitle => 'Tickets du Sprint';

  @override
  String get ticketsSprintTodoSubtitle =>
      'Tickets du sprint en attente de démarrage';

  @override
  String ticketsStatusChangeFailed(String detail) {
    return 'Erreur changement de statut : $detail';
  }

  @override
  String ticketsSubtaskAddFailed(String detail) {
    return 'Erreur ajout sous-tâche: $detail';
  }

  @override
  String ticketsSubtaskUpdateFailed(String detail) {
    return 'Erreur mise à jour sous-tâche: $detail';
  }

  @override
  String get ticketsSubtasks => 'Sous-tâches';

  @override
  String get ticketsSubtasksDeliverables => 'Sous-tâches & Livrables';

  @override
  String get ticketsTaskCreated => 'Tâche créée avec succès';

  @override
  String get ticketsTaskCreatedNext =>
      'Tâche créée ! Vous pouvez en saisir une autre.';

  @override
  String get ticketsTaskTitleActionHint => 'Intitulé de la tâche ou action...';

  @override
  String get ticketsTaskTitleHint => 'Titre de la tâche...';

  @override
  String get ticketsTicketDetailTitle => 'Détail Ticket';

  @override
  String get ticketsTicketLinkCopied => 'Lien du ticket copié';

  @override
  String get ticketsTicketLoadError => 'Erreur chargement ticket';

  @override
  String get ticketsTitleRequired => 'Veuillez saisir un titre.';

  @override
  String get ticketsToday => 'Aujourd\'hui';

  @override
  String get ticketsTodo => 'À faire';

  @override
  String get ticketsTodoBacklog => 'À faire / Backlog';

  @override
  String get ticketsTomorrow => 'Demain';

  @override
  String get ticketsUnassignedClick => 'Non assigné (Cliquer)';

  @override
  String ticketsUpdateFailed(String detail) {
    return 'Erreur de mise à jour : $detail';
  }

  @override
  String get ticketsUrgent => 'Urgentes';

  @override
  String get ticketsViewDescriptionHint => 'Filtre automatique appliqué...';

  @override
  String get ticketsViewDescriptionLabel => 'Description (facultative)';

  @override
  String get ticketsViewNameHint => 'Ex: Tâches Urgentes, Revue Sprint...';

  @override
  String get ticketsViewNameLabel => 'Nom de la vue';

  @override
  String get ticketsViewNameRequired => 'Veuillez saisir un nom pour la vue.';

  @override
  String get ticketsViewSaved => 'Vue sauvegardée avec succès !';

  @override
  String get ticketsViewSprintColumns => 'Voir les colonnes du sprint';

  @override
  String get ticketsYesterday => 'Hier';

  @override
  String get tabCloseTooltip => 'Fermer l\'onglet';

  @override
  String get workspaceWelcomeTitle => 'Bienvenue sur Disciplan';

  @override
  String get workspaceWelcomeHint =>
      'Ouvrez le tableau de bord ou parcourez vos projets pour commencer.';

  @override
  String get workspaceOpenDashboard => 'Ouvrir le tableau de bord';

  @override
  String get workspaceBrowseProjects => 'Parcourir les projets';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeEpic => 'Épopée';

  @override
  String get typeStory => 'Story';

  @override
  String get typeSubtask => 'Sous-tâche';

  @override
  String get typeTask => 'Tâche';

  @override
  String get landingHeroTitle => 'La gestion de projet, claire et rapide.';

  @override
  String get landingHeroSubtitle =>
      'Disciplan réunit vos projets, sprints, tickets et calendriers dans une application auto-hébergeable, accessible depuis le web, le mobile et le desktop.';

  @override
  String get landingCtaLogin => 'S\'authentifier';

  @override
  String get landingCtaSubtitle => 'Connectez-vous pour accéder à vos projets.';

  @override
  String get landingOpenApp => 'Ouvrir l\'application';

  @override
  String get landingOpenAppSubtitle => 'Vous êtes déjà connecté.';

  @override
  String get landingFeatureProjectsTitle => 'Projets & tickets';

  @override
  String get landingFeatureProjectsDescription =>
      'Projets, tickets, sprints et historique complet de chaque modification.';

  @override
  String get landingFeatureKanbanTitle => 'Kanban & cycles';

  @override
  String get landingFeatureKanbanDescription =>
      'Tableaux drag & drop, vues sauvegardées et métriques de cycle.';

  @override
  String get landingFeatureCalendarTitle => 'Calendrier d\'équipe';

  @override
  String get landingFeatureCalendarDescription =>
      'Roadmap mensuelle des sprints et de vos échéances, flux iCal privé.';

  @override
  String get landingFooter =>
      'Auto-hébergé · Une API unique pour le web, le mobile et le desktop.';

  @override
  String get landingBadge => 'Auto-hébergé · Web · Mobile · Desktop';

  @override
  String get landingCtaDiscover => 'Découvrir les fonctionnalités';

  @override
  String get landingFeaturesTitle =>
      'Tout ce qu\'il faut pour piloter vos projets';

  @override
  String get landingFeatureHomelabTitle => 'Auto-hébergé';

  @override
  String get landingFeatureHomelabDescription =>
      'Déployez Disciplan sur votre propre serveur : vos données restent chez vous.';

  @override
  String get setupServerTitle => 'Configuration du serveur';

  @override
  String get setupServerSubtitle =>
      'Pointer l\'application vers un autre serveur API Disciplan. Le build web utilise par défaut sa propre origine.';
}
