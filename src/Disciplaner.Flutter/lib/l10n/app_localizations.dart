import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @title.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get title;

  /// No description provided for @type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @priority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get priority;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @nodescription.
  ///
  /// In fr, this message translates to:
  /// **'Aucune description.'**
  String get nodescription;

  /// No description provided for @errorDefault.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorDefault;

  /// No description provided for @errorLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données.'**
  String get errorLoad;

  /// No description provided for @errorCreate.
  ///
  /// In fr, this message translates to:
  /// **'La création a échoué.'**
  String get errorCreate;

  /// No description provided for @errorUpdate.
  ///
  /// In fr, this message translates to:
  /// **'La mise à jour a échoué.'**
  String get errorUpdate;

  /// No description provided for @errorDelete.
  ///
  /// In fr, this message translates to:
  /// **'La suppression a échoué.'**
  String get errorDelete;

  /// No description provided for @errorMove.
  ///
  /// In fr, this message translates to:
  /// **'Le déplacement a échoué. Veuillez réessayer.'**
  String get errorMove;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navBoards.
  ///
  /// In fr, this message translates to:
  /// **'Tableaux'**
  String get navBoards;

  /// No description provided for @navProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get navProjects;

  /// No description provided for @navMyTickets.
  ///
  /// In fr, this message translates to:
  /// **'Mes tickets'**
  String get navMyTickets;

  /// No description provided for @navCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get navCalendar;

  /// No description provided for @navLabels.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get navLabels;

  /// No description provided for @navAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @navLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get navLogout;

  /// No description provided for @authSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get authSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSubmit;

  /// No description provided for @authSubmitting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get authSubmitting;

  /// No description provided for @authErrorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects.'**
  String get authErrorInvalid;

  /// No description provided for @boardCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau tableau'**
  String get boardCreateTitle;

  /// No description provided for @boardAddColumn.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une colonne'**
  String get boardAddColumn;

  /// No description provided for @boardDropHere.
  ///
  /// In fr, this message translates to:
  /// **'Déposer ici'**
  String get boardDropHere;

  /// No description provided for @boardEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le tableau'**
  String get boardEditTitle;

  /// No description provided for @boardEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tableau pour l\'instant.'**
  String get boardEmpty;

  /// No description provided for @boardCreateFirst.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon premier tableau'**
  String get boardCreateFirst;

  /// No description provided for @boardDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get boardDescription;

  /// No description provided for @boardDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le tableau'**
  String get boardDeleteTitle;

  /// No description provided for @boardDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ? Toutes ses colonnes et cartes seront perdues.'**
  String boardDeleteConfirm(String name);

  /// No description provided for @boardDeleteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes les colonnes, cartes et données seront supprimées.'**
  String get boardDeleteWarning;

  /// No description provided for @boardSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get boardSettings;

  /// No description provided for @boardGeneralInfo.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get boardGeneralInfo;

  /// No description provided for @boardColumnCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} col.'**
  String boardColumnCount(int count);

  /// No description provided for @boardAddCard.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une carte'**
  String get boardAddCard;

  /// No description provided for @projectCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau projet'**
  String get projectCreateTitle;

  /// No description provided for @projectTicketCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} ticket(s)'**
  String projectTicketCount(int count);

  /// No description provided for @projectSprintCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sprint(s)'**
  String projectSprintCount(int count);

  /// No description provided for @projectEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le projet'**
  String get projectEditTitle;

  /// No description provided for @projectEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet pour l\'instant.'**
  String get projectEmpty;

  /// No description provided for @projectCreateFirst.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon premier projet'**
  String get projectCreateFirst;

  /// No description provided for @projectKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé'**
  String get projectKey;

  /// No description provided for @projectKeyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Clé projet'**
  String get projectKeyLabel;

  /// No description provided for @projectKeyHint.
  ///
  /// In fr, this message translates to:
  /// **'2 à 10 lettres, ex : DISC.'**
  String get projectKeyHint;

  /// No description provided for @projectSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Organise les tickets, le backlog et les sprints.'**
  String get projectSubtitle;

  /// No description provided for @projectBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog'**
  String get projectBacklog;

  /// No description provided for @projectBacklogEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le backlog est vide.'**
  String get projectBacklogEmpty;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le projet'**
  String get projectDeleteTitle;

  /// No description provided for @projectDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » et tous ses tickets ?'**
  String projectDeleteConfirm(String name);

  /// No description provided for @projectDeleteWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Tous les tickets et données seront supprimés.'**
  String get projectDeleteWarning;

  /// No description provided for @projectStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Statuts du projet'**
  String get projectStatuses;

  /// No description provided for @projectSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get projectSettings;

  /// No description provided for @projectDangerZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone dangereuse'**
  String get projectDangerZone;

  /// No description provided for @projectDefaults.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs par défaut des tickets'**
  String get projectDefaults;

  /// No description provided for @projectDefaultsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ces valeurs sont pré-remplies à la création d\'un ticket.'**
  String get projectDefaultsHint;

  /// No description provided for @projectDefaultTicketType.
  ///
  /// In fr, this message translates to:
  /// **'Type par défaut'**
  String get projectDefaultTicketType;

  /// No description provided for @projectDefaultAssignee.
  ///
  /// In fr, this message translates to:
  /// **'Assigné par défaut'**
  String get projectDefaultAssignee;

  /// No description provided for @defaultassigneepolicyNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get defaultassigneepolicyNone;

  /// No description provided for @defaultassigneepolicyCreator.
  ///
  /// In fr, this message translates to:
  /// **'Créateur du ticket'**
  String get defaultassigneepolicyCreator;

  /// No description provided for @projectStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get projectStatsTitle;

  /// No description provided for @projectStatsBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog'**
  String get projectStatsBacklog;

  /// No description provided for @projectStatsBacklogSub.
  ///
  /// In fr, this message translates to:
  /// **'tickets non planifiés'**
  String get projectStatsBacklogSub;

  /// No description provided for @projectStatsSprints.
  ///
  /// In fr, this message translates to:
  /// **'Sprints'**
  String get projectStatsSprints;

  /// No description provided for @projectStatsSprintsSub.
  ///
  /// In fr, this message translates to:
  /// **'itérations créées'**
  String get projectStatsSprintsSub;

  /// No description provided for @projectStatsWorkflow.
  ///
  /// In fr, this message translates to:
  /// **'Workflow'**
  String get projectStatsWorkflow;

  /// No description provided for @projectStatsWorkflowSub.
  ///
  /// In fr, this message translates to:
  /// **'statuts de tickets'**
  String get projectStatsWorkflowSub;

  /// No description provided for @projectStatsNoSprints.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sprint pour ce projet.'**
  String get projectStatsNoSprints;

  /// No description provided for @sprintActive.
  ///
  /// In fr, this message translates to:
  /// **'Sprint actif'**
  String get sprintActive;

  /// No description provided for @sprintPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get sprintPlanning;

  /// No description provided for @sprintStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Statuts'**
  String get sprintStatuses;

  /// No description provided for @sprintStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get sprintStart;

  /// No description provided for @sprintClose.
  ///
  /// In fr, this message translates to:
  /// **'Clore'**
  String get sprintClose;

  /// No description provided for @sprintCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un sprint'**
  String get sprintCreateTitle;

  /// No description provided for @sprintGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get sprintGoal;

  /// No description provided for @sprintNoActive.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sprint actif'**
  String get sprintNoActive;

  /// No description provided for @sprintNoActiveDesc.
  ///
  /// In fr, this message translates to:
  /// **'Démarre un sprint planifié depuis l\'onglet Planning. Un seul sprint peut être actif à la fois.'**
  String get sprintNoActiveDesc;

  /// No description provided for @sprintViewKanban.
  ///
  /// In fr, this message translates to:
  /// **'Kanban'**
  String get sprintViewKanban;

  /// No description provided for @sprintViewList.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get sprintViewList;

  /// No description provided for @sprintViewGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille'**
  String get sprintViewGrid;

  /// No description provided for @sprintSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sélectionnés'**
  String sprintSelectedCount(int count);

  /// No description provided for @sprintTicketHint.
  ///
  /// In fr, this message translates to:
  /// **'Coche des tickets puis crée un sprint.'**
  String get sprintTicketHint;

  /// No description provided for @sprintTicketsMoved.
  ///
  /// In fr, this message translates to:
  /// **'{count} tickets seront déplacés depuis le backlog.'**
  String sprintTicketsMoved(int count);

  /// No description provided for @sprintStartHint.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer ce sprint'**
  String get sprintStartHint;

  /// No description provided for @sprintAlreadyActive.
  ///
  /// In fr, this message translates to:
  /// **'Un sprint est déjà actif'**
  String get sprintAlreadyActive;

  /// No description provided for @sprintAddTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get sprintAddTicket;

  /// No description provided for @sprintAddTicketNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau ticket'**
  String get sprintAddTicketNew;

  /// No description provided for @sprintAddToSprint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au sprint'**
  String get sprintAddToSprint;

  /// No description provided for @sprintNoTickets.
  ///
  /// In fr, this message translates to:
  /// **'Ce sprint ne contient aucun ticket.'**
  String get sprintNoTickets;

  /// No description provided for @sprintColumnEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket'**
  String get sprintColumnEmpty;

  /// No description provided for @sprintAddCard.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get sprintAddCard;

  /// No description provided for @sprintCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer un sprint'**
  String get sprintCreateButton;

  /// No description provided for @sprintMoveToBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog'**
  String get sprintMoveToBacklog;

  /// No description provided for @sprintTicketCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} tickets'**
  String sprintTicketCount(int count);

  /// No description provided for @sprintMySprints.
  ///
  /// In fr, this message translates to:
  /// **'Mes sprints actifs'**
  String get sprintMySprints;

  /// No description provided for @sprintNoneActive.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne participez à aucun sprint actif.'**
  String get sprintNoneActive;

  /// No description provided for @sprintLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sprint'**
  String get sprintLabel;

  /// No description provided for @sprintLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du sprint…'**
  String get sprintLoading;

  /// No description provided for @sprintNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Sprint introuvable.'**
  String get sprintNotFound;

  /// No description provided for @sprintTickets.
  ///
  /// In fr, this message translates to:
  /// **'tickets'**
  String get sprintTickets;

  /// No description provided for @cardCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle carte'**
  String get cardCreateTitle;

  /// No description provided for @ticketCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau ticket'**
  String get ticketCreateTitle;

  /// No description provided for @ticketNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ticket introuvable.'**
  String get ticketNotFound;

  /// No description provided for @ticketOpenPage.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la page'**
  String get ticketOpenPage;

  /// No description provided for @ticketStoryPoints.
  ///
  /// In fr, this message translates to:
  /// **'Story points'**
  String get ticketStoryPoints;

  /// No description provided for @ticketDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get ticketDueDate;

  /// No description provided for @ticketSprint.
  ///
  /// In fr, this message translates to:
  /// **'Sprint'**
  String get ticketSprint;

  /// No description provided for @ticketBacklogOption.
  ///
  /// In fr, this message translates to:
  /// **'— Backlog —'**
  String get ticketBacklogOption;

  /// No description provided for @ticketReporter.
  ///
  /// In fr, this message translates to:
  /// **'Créé par'**
  String get ticketReporter;

  /// No description provided for @ticketAssignee.
  ///
  /// In fr, this message translates to:
  /// **'Assigné à'**
  String get ticketAssignee;

  /// No description provided for @ticketNoAssignee.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné'**
  String get ticketNoAssignee;

  /// No description provided for @ticketComments.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get ticketComments;

  /// No description provided for @ticketCommentAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un commentaire…'**
  String get ticketCommentAdd;

  /// No description provided for @ticketCommentEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get ticketCommentEdit;

  /// No description provided for @ticketCommentDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get ticketCommentDelete;

  /// No description provided for @ticketCommentSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get ticketCommentSave;

  /// No description provided for @ticketNoDescription.
  ///
  /// In fr, this message translates to:
  /// **'Aucune description.'**
  String get ticketNoDescription;

  /// No description provided for @ticketOverdue.
  ///
  /// In fr, this message translates to:
  /// **'en retard'**
  String get ticketOverdue;

  /// No description provided for @ticketDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le ticket'**
  String get ticketDeleteTitle;

  /// No description provided for @ticketCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'le {date}'**
  String ticketCreatedOn(String date);

  /// No description provided for @ticketUpdatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Modifié le {date}'**
  String ticketUpdatedOn(String date);

  /// No description provided for @ticketParent.
  ///
  /// In fr, this message translates to:
  /// **'Parent : {parent}'**
  String ticketParent(String parent);

  /// No description provided for @ticketParentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get ticketParentLabel;

  /// No description provided for @statusCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get statusCategory;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @created.
  ///
  /// In fr, this message translates to:
  /// **'Créé'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In fr, this message translates to:
  /// **'Modifié'**
  String get updated;

  /// No description provided for @statusColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get statusColor;

  /// No description provided for @statusOrderLabel.
  ///
  /// In fr, this message translates to:
  /// **'ordre {order}'**
  String statusOrderLabel(int order);

  /// No description provided for @statusCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau statut'**
  String get statusCreateTitle;

  /// No description provided for @statusEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le statut'**
  String get statusEditTitle;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navMenu.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @pwaUpdateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle version est disponible.'**
  String get pwaUpdateAvailable;

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Disciplan'**
  String get appTitle;

  /// No description provided for @pwaUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get pwaUpdate;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In fr, this message translates to:
  /// **'Le changement de langue recharge l\'application.'**
  String get settingsLanguageHint;

  /// No description provided for @settingsDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage'**
  String get settingsDisplayName;

  /// No description provided for @settingsDisplayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom est affiché aux autres utilisateurs de l\'application.'**
  String get settingsDisplayNameHint;

  /// No description provided for @settingsDisplayNamePlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom d\'affichage'**
  String get settingsDisplayNamePlaceholder;

  /// No description provided for @settingsDisplayNameSaved.
  ///
  /// In fr, this message translates to:
  /// **'Nom mis à jour.'**
  String get settingsDisplayNameSaved;

  /// No description provided for @settingsDisplayNameError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de mettre à jour le nom d\'affichage. Veuillez réessayer.'**
  String get settingsDisplayNameError;

  /// No description provided for @settingsTabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get settingsTabProfile;

  /// No description provided for @settingsTabDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get settingsTabDashboard;

  /// No description provided for @settingsDashboardHint.
  ///
  /// In fr, this message translates to:
  /// **'Ordonnez et affichez les widgets de votre tableau de bord.'**
  String get settingsDashboardHint;

  /// No description provided for @settingsDashboardEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun widget configuré.'**
  String get settingsDashboardEmpty;

  /// No description provided for @settingsDashboardHide.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get settingsDashboardHide;

  /// No description provided for @settingsDashboardShow.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get settingsDashboardShow;

  /// No description provided for @savedviewLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vue'**
  String get savedviewLabel;

  /// No description provided for @savedviewCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vue'**
  String get savedviewCreateTitle;

  /// No description provided for @savedviewEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la vue'**
  String get savedviewEditTitle;

  /// No description provided for @savedviewFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get savedviewFilters;

  /// No description provided for @savedviewAllProjects.
  ///
  /// In fr, this message translates to:
  /// **'Tous les projets'**
  String get savedviewAllProjects;

  /// No description provided for @savedviewAllTypes.
  ///
  /// In fr, this message translates to:
  /// **'Tous les types'**
  String get savedviewAllTypes;

  /// No description provided for @savedviewAllPriorities.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les priorités'**
  String get savedviewAllPriorities;

  /// No description provided for @savedviewStatusCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie de statut'**
  String get savedviewStatusCategory;

  /// No description provided for @savedviewAllCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les catégories'**
  String get savedviewAllCategories;

  /// No description provided for @savedviewOnlyAssignedToMe.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement assignés à moi'**
  String get savedviewOnlyAssignedToMe;

  /// No description provided for @savedviewOnlyReportedByMe.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement créés par moi'**
  String get savedviewOnlyReportedByMe;

  /// No description provided for @savedviewCollapsedByDefault.
  ///
  /// In fr, this message translates to:
  /// **'Réduit par défaut sur le tableau de bord'**
  String get savedviewCollapsedByDefault;

  /// No description provided for @savedviewNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis.'**
  String get savedviewNameRequired;

  /// No description provided for @ticketHistory.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get ticketHistory;

  /// No description provided for @ticketHistoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité enregistrée.'**
  String get ticketHistoryEmpty;

  /// No description provided for @historyCreated.
  ///
  /// In fr, this message translates to:
  /// **'a créé ce ticket'**
  String get historyCreated;

  /// No description provided for @historyTitleChanged.
  ///
  /// In fr, this message translates to:
  /// **'a modifié le titre'**
  String get historyTitleChanged;

  /// No description provided for @historyDescriptionChanged.
  ///
  /// In fr, this message translates to:
  /// **'a modifié la description'**
  String get historyDescriptionChanged;

  /// No description provided for @historyStatusChanged.
  ///
  /// In fr, this message translates to:
  /// **'a changé le statut'**
  String get historyStatusChanged;

  /// No description provided for @historyTypeChanged.
  ///
  /// In fr, this message translates to:
  /// **'a changé le type'**
  String get historyTypeChanged;

  /// No description provided for @historyPriorityChanged.
  ///
  /// In fr, this message translates to:
  /// **'a changé la priorité'**
  String get historyPriorityChanged;

  /// No description provided for @historyAssigneeChanged.
  ///
  /// In fr, this message translates to:
  /// **'a réassigné le ticket'**
  String get historyAssigneeChanged;

  /// No description provided for @historySprintChanged.
  ///
  /// In fr, this message translates to:
  /// **'a changé le sprint'**
  String get historySprintChanged;

  /// No description provided for @historyStoryPointsChanged.
  ///
  /// In fr, this message translates to:
  /// **'a modifié les points'**
  String get historyStoryPointsChanged;

  /// No description provided for @historyDueDateChanged.
  ///
  /// In fr, this message translates to:
  /// **'a modifié l\'échéance'**
  String get historyDueDateChanged;

  /// No description provided for @historyCommentAdded.
  ///
  /// In fr, this message translates to:
  /// **'a ajouté un commentaire'**
  String get historyCommentAdded;

  /// No description provided for @historyCommentDeleted.
  ///
  /// In fr, this message translates to:
  /// **'a supprimé un commentaire'**
  String get historyCommentDeleted;

  /// No description provided for @historyAttachmentAdded.
  ///
  /// In fr, this message translates to:
  /// **'a joint une pièce jointe'**
  String get historyAttachmentAdded;

  /// No description provided for @colCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle colonne'**
  String get colCreateTitle;

  /// No description provided for @colEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer la colonne'**
  String get colEditTitle;

  /// No description provided for @colDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la colonne'**
  String get colDeleteTitle;

  /// No description provided for @colDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » et toutes ses cartes ?'**
  String colDeleteConfirm(String name);

  /// No description provided for @colRef.
  ///
  /// In fr, this message translates to:
  /// **'Réf.'**
  String get colRef;

  /// No description provided for @colTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get colTitle;

  /// No description provided for @colPriority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get colPriority;

  /// No description provided for @colStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get colStatus;

  /// No description provided for @colSprint.
  ///
  /// In fr, this message translates to:
  /// **'Sprint'**
  String get colSprint;

  /// No description provided for @colDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get colDueDate;

  /// No description provided for @colProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet'**
  String get colProject;

  /// No description provided for @colDueDateOptional.
  ///
  /// In fr, this message translates to:
  /// **'Due date (optional)'**
  String get colDueDateOptional;

  /// No description provided for @homeWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name} 👋'**
  String homeWelcome(String name);

  /// No description provided for @homeMyTickets.
  ///
  /// In fr, this message translates to:
  /// **'Mes tickets'**
  String get homeMyTickets;

  /// No description provided for @homeActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get homeActivity;

  /// No description provided for @homeNoTickets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket assigné.'**
  String get homeNoTickets;

  /// No description provided for @homeNoActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité récente.'**
  String get homeNoActivity;

  /// No description provided for @homeViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous'**
  String get homeViewAll;

  /// No description provided for @homeActivityCreated.
  ///
  /// In fr, this message translates to:
  /// **'Ticket créé'**
  String get homeActivityCreated;

  /// No description provided for @homeActivityUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Ticket modifié'**
  String get homeActivityUpdated;

  /// No description provided for @homeActivityCommented.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire ajouté'**
  String get homeActivityCommented;

  /// No description provided for @homeActivityAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Pièce jointe ajoutée'**
  String get homeActivityAttachment;

  /// No description provided for @homeConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Configurer'**
  String get homeConfigure;

  /// No description provided for @homeNoDashboardWidgets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun widget visible.'**
  String get homeNoDashboardWidgets;

  /// No description provided for @homeConfigureDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Configurer le tableau de bord'**
  String get homeConfigureDashboard;

  /// No description provided for @homeNoViewTickets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket pour cette vue.'**
  String get homeNoViewTickets;

  /// No description provided for @myticketsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes tickets'**
  String get myticketsTitle;

  /// No description provided for @myticketsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket assigné.'**
  String get myticketsEmpty;

  /// No description provided for @statuscategoryBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog'**
  String get statuscategoryBacklog;

  /// No description provided for @statuscategoryInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statuscategoryInProgress;

  /// No description provided for @statuscategoryDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get statuscategoryDone;

  /// No description provided for @adminUsersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des utilisateurs'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersHeading.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get adminUsersHeading;

  /// No description provided for @adminUsersPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Administration des comptes. À implémenter.'**
  String get adminUsersPlaceholder;

  /// No description provided for @adminUsersInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get adminUsersInvite;

  /// No description provided for @adminUsersCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer un utilisateur'**
  String get adminUsersCreate;

  /// No description provided for @adminUsersHeadingCount.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs ({count})'**
  String adminUsersHeadingCount(int count);

  /// No description provided for @adminUsersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur.'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get adminUsersCreatedOn;

  /// No description provided for @adminUsersDeactivate.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get adminUsersDeactivate;

  /// No description provided for @adminUsersActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get adminUsersActivate;

  /// No description provided for @adminUsersPromoteAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Promouvoir Admin'**
  String get adminUsersPromoteAdmin;

  /// No description provided for @adminUsersDemoteUser.
  ///
  /// In fr, this message translates to:
  /// **'Rétrograder en User'**
  String get adminUsersDemoteUser;

  /// No description provided for @adminUsersCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un utilisateur'**
  String get adminUsersCreateTitle;

  /// No description provided for @adminUsersDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage'**
  String get adminUsersDisplayName;

  /// No description provided for @adminUsersRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get adminUsersRole;

  /// No description provided for @adminUsersRoleUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get adminUsersRoleUser;

  /// No description provided for @adminUsersRoleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get adminUsersRoleAdmin;

  /// No description provided for @adminInvitationsHeading.
  ///
  /// In fr, this message translates to:
  /// **'Invitations actives ({count})'**
  String adminInvitationsHeading(int count);

  /// No description provided for @adminInvitationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune invitation en attente.'**
  String get adminInvitationsEmpty;

  /// No description provided for @adminInviteOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien ouvert'**
  String get adminInviteOpenLink;

  /// No description provided for @adminInviteExpiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le'**
  String get adminInviteExpiresOn;

  /// No description provided for @adminInviteCopyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get adminInviteCopyLink;

  /// No description provided for @adminInviteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un utilisateur'**
  String get adminInviteTitle;

  /// No description provided for @adminInviteDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un lien d\'invitation sera généré. Partagez-le avec la personne à inviter. Le lien expire après 7 jours.'**
  String get adminInviteDescription;

  /// No description provided for @adminInviteEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email (optionnel)'**
  String get adminInviteEmailLabel;

  /// No description provided for @adminInviteEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Si renseigné, l\'invitation sera limitée à cette adresse.'**
  String get adminInviteEmailHint;

  /// No description provided for @adminInviteGenerate.
  ///
  /// In fr, this message translates to:
  /// **'Générer le lien'**
  String get adminInviteGenerate;

  /// No description provided for @notfoundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Page introuvable'**
  String get notfoundTitle;

  /// No description provided for @notfoundMessage.
  ///
  /// In fr, this message translates to:
  /// **'Désolé, le contenu que vous recherchez n\'existe pas.'**
  String get notfoundMessage;

  /// No description provided for @timeJustNow.
  ///
  /// In fr, this message translates to:
  /// **'à l’instant'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} min'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} h'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} j'**
  String timeDaysAgo(int count);

  /// No description provided for @labelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get labelTitle;

  /// No description provided for @labelCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} étiquette(s)'**
  String labelCount(int count);

  /// No description provided for @labelCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle étiquette'**
  String get labelCreateTitle;

  /// No description provided for @labelEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'étiquette'**
  String get labelEditTitle;

  /// No description provided for @labelDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'étiquette'**
  String get labelDeleteTitle;

  /// No description provided for @labelDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ? L\'étiquette sera retirée de tous les tickets et boards.'**
  String labelDeleteConfirm(String name);

  /// No description provided for @labelEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune étiquette. Créez-en une pour organiser vos tickets et boards.'**
  String get labelEmpty;

  /// No description provided for @labelCreateFirst.
  ///
  /// In fr, this message translates to:
  /// **'Créer une étiquette'**
  String get labelCreateFirst;

  /// No description provided for @labelName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get labelName;

  /// No description provided for @labelColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get labelColor;

  /// No description provided for @labelPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get labelPreview;

  /// No description provided for @labelField.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes'**
  String get labelField;

  /// No description provided for @labelNoItems.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket ni board avec cette étiquette pour le moment.'**
  String get labelNoItems;

  /// No description provided for @labelItemCount.
  ///
  /// In fr, this message translates to:
  /// **'{tickets} ticket(s) · {boards} board(s)'**
  String labelItemCount(int tickets, int boards);

  /// No description provided for @membersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get membersTitle;

  /// No description provided for @membersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get membersAdd;

  /// No description provided for @membersNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre pour le moment.'**
  String get membersNone;

  /// No description provided for @membersSelectUser.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un utilisateur'**
  String get membersSelectUser;

  /// No description provided for @membersRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get membersRole;

  /// No description provided for @membersChangeRole.
  ///
  /// In fr, this message translates to:
  /// **'Changer le rôle'**
  String get membersChangeRole;

  /// No description provided for @membersRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le membre'**
  String get membersRemove;

  /// No description provided for @membersRemoveConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} de cette ressource ?'**
  String membersRemoveConfirm(String name);

  /// No description provided for @homeActiveSprints.
  ///
  /// In fr, this message translates to:
  /// **'Sprints actifs'**
  String get homeActiveSprints;

  /// No description provided for @homeOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get homeOverdue;

  /// No description provided for @homeInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get homeInProgress;

  /// No description provided for @setupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration initiale'**
  String get setupSubtitle;

  /// No description provided for @setupNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte n\'existe encore. Créez le premier compte administrateur.'**
  String get setupNoAccount;

  /// No description provided for @setupPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères, avec majuscule, minuscule et chiffre.'**
  String get setupPasswordHint;

  /// No description provided for @setupCreating.
  ///
  /// In fr, this message translates to:
  /// **'Création en cours…'**
  String get setupCreating;

  /// No description provided for @setupCreateAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte administrateur'**
  String get setupCreateAdmin;

  /// No description provided for @invitationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre compte'**
  String get invitationSubtitle;

  /// No description provided for @invitationInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Invitation invalide ou expirée'**
  String get invitationInvalid;

  /// No description provided for @invitationInvalidDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ce lien d\'invitation n\'est plus valide.'**
  String get invitationInvalidDesc;

  /// No description provided for @invitationBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get invitationBackToLogin;

  /// No description provided for @invitationValid.
  ///
  /// In fr, this message translates to:
  /// **'Invitation valide. Renseignez vos informations pour créer votre compte.'**
  String get invitationValid;

  /// No description provided for @invitationCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get invitationCreateAccount;

  /// No description provided for @settingsTabAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsTabAppearance;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeCustom.
  ///
  /// In fr, this message translates to:
  /// **'Thème personnalisé'**
  String get settingsThemeCustom;

  /// No description provided for @settingsThemeActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get settingsThemeActive;

  /// No description provided for @settingsThemeActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get settingsThemeActivate;

  /// No description provided for @settingsStatsShow.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les statistiques rapides'**
  String get settingsStatsShow;

  /// No description provided for @settingsStatsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Tickets assignés, sprints actifs, retards et tickets en cours.'**
  String get settingsStatsDescription;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeToDark.
  ///
  /// In fr, this message translates to:
  /// **'Passer en mode sombre'**
  String get settingsThemeToDark;

  /// No description provided for @settingsThemeToLight.
  ///
  /// In fr, this message translates to:
  /// **'Passer en mode clair'**
  String get settingsThemeToLight;

  /// No description provided for @cardCreatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Créée le'**
  String get cardCreatedOn;

  /// No description provided for @cardUpdatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Modifiée le'**
  String get cardUpdatedOn;

  /// No description provided for @cardCreatedBy.
  ///
  /// In fr, this message translates to:
  /// **'Créé par :'**
  String get cardCreatedBy;

  /// No description provided for @cardAssignedTo.
  ///
  /// In fr, this message translates to:
  /// **'Assigné à :'**
  String get cardAssignedTo;

  /// No description provided for @cardNoComments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commentaire pour l\'instant.'**
  String get cardNoComments;

  /// No description provided for @cardEdited.
  ///
  /// In fr, this message translates to:
  /// **'(modifié)'**
  String get cardEdited;

  /// No description provided for @cardCommentSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get cardCommentSend;

  /// No description provided for @cardEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la carte'**
  String get cardEditTitle;

  /// No description provided for @cardDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la carte'**
  String get cardDeleteTitle;

  /// No description provided for @cardDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer \"{name}\" ?'**
  String cardDeleteConfirm(String name);

  /// No description provided for @cardCommentPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un commentaire…'**
  String get cardCommentPlaceholder;

  /// No description provided for @cardNoDescription.
  ///
  /// In fr, this message translates to:
  /// **'Aucune description.'**
  String get cardNoDescription;

  /// No description provided for @cardOverdue.
  ///
  /// In fr, this message translates to:
  /// **'— en retard'**
  String get cardOverdue;

  /// No description provided for @labelpickerRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get labelpickerRemove;

  /// No description provided for @labelpickerFilter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer…'**
  String get labelpickerFilter;

  /// No description provided for @labelpickerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune étiquette trouvée.'**
  String get labelpickerEmpty;

  /// No description provided for @labelTickets.
  ///
  /// In fr, this message translates to:
  /// **'Tickets'**
  String get labelTickets;

  /// No description provided for @adminActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get adminActivate;

  /// No description provided for @adminPromoteAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Promouvoir Admin'**
  String get adminPromoteAdmin;

  /// No description provided for @attachmentSectionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pièces jointes'**
  String get attachmentSectionLabel;

  /// No description provided for @attachmentAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get attachmentAdd;

  /// No description provided for @attachmentAddFiles.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des fichiers'**
  String get attachmentAddFiles;

  /// No description provided for @attachmentAttach.
  ///
  /// In fr, this message translates to:
  /// **'Joindre'**
  String get attachmentAttach;

  /// No description provided for @attachmentAttachFiles.
  ///
  /// In fr, this message translates to:
  /// **'Joindre des fichiers'**
  String get attachmentAttachFiles;

  /// No description provided for @attachmentUploading.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get attachmentUploading;

  /// No description provided for @attachmentEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce jointe — cliquez sur Ajouter pour en joindre'**
  String get attachmentEmpty;

  /// No description provided for @attachmentPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get attachmentPreview;

  /// No description provided for @attachmentOpenInTab.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans un onglet'**
  String get attachmentOpenInTab;

  /// No description provided for @attachmentOpenInNewTab.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans un nouvel onglet'**
  String get attachmentOpenInNewTab;

  /// No description provided for @attachmentNewTab.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel onglet'**
  String get attachmentNewTab;

  /// No description provided for @attachmentDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get attachmentDownload;

  /// No description provided for @attachmentDownloadFile.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le fichier'**
  String get attachmentDownloadFile;

  /// No description provided for @attachmentNoPreview.
  ///
  /// In fr, this message translates to:
  /// **'L\'aperçu n\'est pas disponible pour ce type de fichier.'**
  String get attachmentNoPreview;

  /// No description provided for @attachmentLoadingPreview.
  ///
  /// In fr, this message translates to:
  /// **'Chargement en cours…'**
  String get attachmentLoadingPreview;

  /// No description provided for @attachmentRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get attachmentRetry;

  /// No description provided for @attachmentErrorUpload.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi : {error}'**
  String attachmentErrorUpload(String error);

  /// No description provided for @attachmentErrorDownload.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du téléchargement : {error}'**
  String attachmentErrorDownload(String error);

  /// No description provided for @attachmentErrorOpen.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'ouverture : {error}'**
  String attachmentErrorOpen(String error);

  /// No description provided for @attachmentErrorDelete.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression : {error}'**
  String attachmentErrorDelete(String error);

  /// No description provided for @attachmentErrorLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le fichier : {error}'**
  String attachmentErrorLoad(String error);

  /// No description provided for @ticketCommentSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Commenter'**
  String get ticketCommentSubmit;

  /// No description provided for @authHeadline.
  ///
  /// In fr, this message translates to:
  /// **'De l’idée à l’accomplissement.'**
  String get authHeadline;

  /// No description provided for @authIntroduction.
  ///
  /// In fr, this message translates to:
  /// **'Un espace pour organiser vos projets, faire avancer vos équipes et vous concentrer sur l’essentiel.'**
  String get authIntroduction;

  /// No description provided for @authDisplayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Marie Curie'**
  String get authDisplayNameHint;

  /// No description provided for @authEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'vous@exemple.com'**
  String get authEmailHint;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get authHaveAccount;

  /// No description provided for @authHomelabServer.
  ///
  /// In fr, this message translates to:
  /// **'Serveur Homelab'**
  String get authHomelabServer;

  /// No description provided for @authInvitationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre inscription via votre jeton d\'invitation.'**
  String get authInvitationSubtitle;

  /// No description provided for @authInvitationTokenHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. inv_8f93ab...'**
  String get authInvitationTokenHint;

  /// No description provided for @authInvitationTokenLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'invitation'**
  String get authInvitationTokenLabel;

  /// No description provided for @authJoinTeam.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre une Équipe'**
  String get authJoinTeam;

  /// No description provided for @authLoginTagline.
  ///
  /// In fr, this message translates to:
  /// **'Pilotez vos sprints et tickets en haute vélocité.'**
  String get authLoginTagline;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à Disciplan'**
  String get authLoginTitle;

  /// No description provided for @authReceivedInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez reçu une invitation ?'**
  String get authReceivedInvitation;

  /// No description provided for @authServerTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get authServerTest;

  /// No description provided for @authServerTestFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de connexion au serveur Homelab.'**
  String get authServerTestFailed;

  /// No description provided for @authServerTestSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion établie avec succès.'**
  String get authServerTestSuccess;

  /// No description provided for @authSetupDisplayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Alexandre Gailloty'**
  String get authSetupDisplayNameHint;

  /// No description provided for @authSetupFillAllFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs.'**
  String get authSetupFillAllFields;

  /// No description provided for @authSetupIntro.
  ///
  /// In fr, this message translates to:
  /// **'Initialisez votre instance Homelab en créant le compte administrateur racine.'**
  String get authSetupIntro;

  /// No description provided for @authSetupPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe (min. 8 caractères)'**
  String get authSetupPasswordLabel;

  /// No description provided for @authSetupPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit comporter au moins 8 caractères.'**
  String get authSetupPasswordTooShort;

  /// No description provided for @authSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Premier Démarrage'**
  String get authSetupTitle;

  /// No description provided for @authValidateInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'invitation'**
  String get authValidateInvitation;

  /// No description provided for @calCopyIcalUrl.
  ///
  /// In fr, this message translates to:
  /// **'Copier l\'URL iCal'**
  String get calCopyIcalUrl;

  /// No description provided for @calFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get calFilterAll;

  /// No description provided for @calFilterSprints.
  ///
  /// In fr, this message translates to:
  /// **'Sprints'**
  String get calFilterSprints;

  /// No description provided for @calGenerateToken.
  ///
  /// In fr, this message translates to:
  /// **'Générer le jeton'**
  String get calGenerateToken;

  /// No description provided for @calIcalNoFeed.
  ///
  /// In fr, this message translates to:
  /// **'Aucun flux actif. Générez votre jeton privé pour synchroniser votre calendrier.'**
  String get calIcalNoFeed;

  /// No description provided for @calIcalSyncTitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation iCal / Agenda externe'**
  String get calIcalSyncTitle;

  /// No description provided for @calIcalUrlCopied.
  ///
  /// In fr, this message translates to:
  /// **'URL du flux iCal copiée'**
  String get calIcalUrlCopied;

  /// No description provided for @calNoMilestones.
  ///
  /// In fr, this message translates to:
  /// **'Aucun jalon ou ticket daté pour ce filtre.'**
  String get calNoMilestones;

  /// No description provided for @calRegenerateToken.
  ///
  /// In fr, this message translates to:
  /// **'Régénérer le jeton'**
  String get calRegenerateToken;

  /// No description provided for @calSprintMilestone.
  ///
  /// In fr, this message translates to:
  /// **'Jalon de cycle'**
  String get calSprintMilestone;

  /// No description provided for @calTeamCalendarSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Jalons de sprint, échéances de tickets et synchronisation iCal'**
  String get calTeamCalendarSubtitle;

  /// No description provided for @calTeamCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier d\'Équipe'**
  String get calTeamCalendarTitle;

  /// No description provided for @calTokenError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur token: {error}'**
  String calTokenError(String error);

  /// No description provided for @cmdCategoryActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get cmdCategoryActions;

  /// No description provided for @cmdCategoryNavigation.
  ///
  /// In fr, this message translates to:
  /// **'Navigation'**
  String get cmdCategoryNavigation;

  /// No description provided for @cmdCategoryTickets.
  ///
  /// In fr, this message translates to:
  /// **'Tickets'**
  String get cmdCategoryTickets;

  /// No description provided for @cmdCreateTask.
  ///
  /// In fr, this message translates to:
  /// **'Créer une tâche'**
  String get cmdCreateTask;

  /// No description provided for @cmdEscapeKey.
  ///
  /// In fr, this message translates to:
  /// **'Échap'**
  String get cmdEscapeKey;

  /// No description provided for @cmdFooterBrand.
  ///
  /// In fr, this message translates to:
  /// **'Disciplan Neo-Linear'**
  String get cmdFooterBrand;

  /// No description provided for @cmdNavCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier d\'Équipe'**
  String get cmdNavCalendar;

  /// No description provided for @cmdNavCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles & Sprints'**
  String get cmdNavCycles;

  /// No description provided for @cmdNavSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres & Administration'**
  String get cmdNavSettings;

  /// No description provided for @cmdNavSprintKanban.
  ///
  /// In fr, this message translates to:
  /// **'Tableau Kanban du Sprint'**
  String get cmdNavSprintKanban;

  /// No description provided for @cmdNavigate.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer'**
  String get cmdNavigate;

  /// No description provided for @cmdNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat correspondant à “{query}”'**
  String cmdNoResults(String query);

  /// No description provided for @cmdOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get cmdOpen;

  /// No description provided for @cmdSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un ticket, une action ou naviguer...'**
  String get cmdSearchHint;

  /// No description provided for @errorBadRequest.
  ///
  /// In fr, this message translates to:
  /// **'Requête invalide.'**
  String get errorBadRequest;

  /// No description provided for @errorConflict.
  ///
  /// In fr, this message translates to:
  /// **'Un conflit est survenu (élément déjà existant ou modifié).'**
  String get errorConflict;

  /// No description provided for @errorForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé pour cette opération.'**
  String get errorForbidden;

  /// No description provided for @errorGenericNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur réseau est survenue.'**
  String get errorGenericNetwork;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion et l\'URL du serveur.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ressource introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur interne est survenue sur le serveur.'**
  String get errorServer;

  /// No description provided for @errorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides ou session expirée.'**
  String get errorUnauthorized;

  /// No description provided for @kanbanBoardLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement du tableau: {error}'**
  String kanbanBoardLoadError(String error);

  /// No description provided for @kanbanDropTicketHere.
  ///
  /// In fr, this message translates to:
  /// **'Glisser une tâche ici'**
  String get kanbanDropTicketHere;

  /// No description provided for @kanbanDueToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get kanbanDueToday;

  /// No description provided for @kanbanDueTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get kanbanDueTomorrow;

  /// No description provided for @kanbanDueYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get kanbanDueYesterday;

  /// No description provided for @kanbanErrorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String kanbanErrorWithDetail(String error);

  /// No description provided for @kanbanFilterCardsHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer les cartes...'**
  String get kanbanFilterCardsHint;

  /// No description provided for @kanbanHideMetrics.
  ///
  /// In fr, this message translates to:
  /// **'Masquer en-tête'**
  String get kanbanHideMetrics;

  /// No description provided for @kanbanMoveToStatus.
  ///
  /// In fr, this message translates to:
  /// **'Déplacer vers...'**
  String get kanbanMoveToStatus;

  /// No description provided for @kanbanNoStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Aucun statut défini pour ce projet.'**
  String get kanbanNoStatuses;

  /// No description provided for @kanbanNoStatusesAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun statut disponible.'**
  String get kanbanNoStatusesAvailable;

  /// No description provided for @kanbanNoTicketsInStatus.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche dans \"{status}\"'**
  String kanbanNoTicketsInStatus(String status);

  /// No description provided for @kanbanOpenSprintBoard.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le Kanban de \"{name}\"'**
  String kanbanOpenSprintBoard(String name);

  /// No description provided for @kanbanPriorityHighFilter.
  ///
  /// In fr, this message translates to:
  /// **'Priorité Haute'**
  String get kanbanPriorityHighFilter;

  /// No description provided for @kanbanSelectProject.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un projet pour afficher son tableau Kanban.'**
  String get kanbanSelectProject;

  /// No description provided for @kanbanShowMetrics.
  ///
  /// In fr, this message translates to:
  /// **'Afficher métriques'**
  String get kanbanShowMetrics;

  /// No description provided for @kanbanStartNamed.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer \"{name}\"'**
  String kanbanStartNamed(String name);

  /// No description provided for @kanbanSwitchSprintTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Changer de sprint affiché'**
  String get kanbanSwitchSprintTooltip;

  /// No description provided for @kanbanViewBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Voir le Backlog'**
  String get kanbanViewBacklog;

  /// No description provided for @priorityCritical.
  ///
  /// In fr, this message translates to:
  /// **'Urgente'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In fr, this message translates to:
  /// **'Haute'**
  String get priorityHigh;

  /// No description provided for @priorityLow.
  ///
  /// In fr, this message translates to:
  /// **'Basse'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get priorityMedium;

  /// No description provided for @projActiveProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets actifs'**
  String get projActiveProjects;

  /// No description provided for @projActiveSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace actif : {key} — {name}'**
  String projActiveSpace(String key, String name);

  /// No description provided for @projActiveSpaceBadge.
  ///
  /// In fr, this message translates to:
  /// **'Espace actif'**
  String get projActiveSpaceBadge;

  /// No description provided for @projAllMyProjects.
  ///
  /// In fr, this message translates to:
  /// **'Tous mes projets'**
  String get projAllMyProjects;

  /// No description provided for @projCardDescriptionFallback.
  ///
  /// In fr, this message translates to:
  /// **'Espace projet encapsulé — cliquez pour accéder à ses tickets et cycles.'**
  String get projCardDescriptionFallback;

  /// No description provided for @projCreateNew.
  ///
  /// In fr, this message translates to:
  /// **'Créer un projet'**
  String get projCreateNew;

  /// No description provided for @projCreateSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le projet'**
  String get projCreateSubmit;

  /// No description provided for @projCreateSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Configurez un espace de travail collaboratif pour aligner vos sprints et tickets.'**
  String get projCreateSubtitle;

  /// No description provided for @projCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles'**
  String get projCycles;

  /// No description provided for @projDashboardGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard Général'**
  String get projDashboardGeneral;

  /// No description provided for @projDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Résumez les objectifs stratégiques et le périmètre...'**
  String get projDescriptionHint;

  /// No description provided for @projDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description & vision'**
  String get projDescriptionLabel;

  /// No description provided for @projEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier projet pour organiser vos tickets et sprints.'**
  String get projEmptyHint;

  /// No description provided for @projExplorerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez ou créez un projet pour afficher sa vue liste et son backlog.'**
  String get projExplorerSubtitle;

  /// No description provided for @projExplorerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur de Projets'**
  String get projExplorerTitle;

  /// No description provided for @projFilterMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre d\'équipe'**
  String get projFilterMember;

  /// No description provided for @projInitiationAgile.
  ///
  /// In fr, this message translates to:
  /// **'Initiation agile'**
  String get projInitiationAgile;

  /// No description provided for @projKeyAuto.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get projKeyAuto;

  /// No description provided for @projLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String projLoadError(String error);

  /// No description provided for @projMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre du projet'**
  String get projMember;

  /// No description provided for @projNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex. Campagne de Marque 2025'**
  String get projNameHint;

  /// No description provided for @projNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du projet *'**
  String get projNameLabel;

  /// No description provided for @projNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir le nom du projet.'**
  String get projNameRequired;

  /// No description provided for @projNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet ne correspond à ce filtre.'**
  String get projNoMatch;

  /// No description provided for @projOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get projOwner;

  /// No description provided for @projPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille de projets'**
  String get projPortfolio;

  /// No description provided for @projSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un projet (nom, clé)...'**
  String get projSearchHint;

  /// No description provided for @projSelectSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un projet pour encapsuler votre espace de travail ou accédez directement à son Backlog, Kanban ou Cycles.'**
  String get projSelectSubtitle;

  /// No description provided for @projSprintsCycles.
  ///
  /// In fr, this message translates to:
  /// **'Sprints & Cycles'**
  String get projSprintsCycles;

  /// No description provided for @projTotalTickets.
  ///
  /// In fr, this message translates to:
  /// **'Tickets cumulés'**
  String get projTotalTickets;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleGuest.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get roleGuest;

  /// No description provided for @roleMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get roleMember;

  /// No description provided for @roleSupervisor.
  ///
  /// In fr, this message translates to:
  /// **'Superviseur'**
  String get roleSupervisor;

  /// No description provided for @settingsActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get settingsActive;

  /// No description provided for @settingsAdminInvitationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Générez des liens d\'invitation à usage unique pour intégrer de nouveaux membres'**
  String get settingsAdminInvitationsSubtitle;

  /// No description provided for @settingsAdminInvitationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration — Invitations (7 jours)'**
  String get settingsAdminInvitationsTitle;

  /// No description provided for @settingsAdminUsersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer, désactiver ou changer les rôles des utilisateurs de l\'instance'**
  String get settingsAdminUsersSubtitle;

  /// No description provided for @settingsAdminUsersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration — Gestion des Comptes'**
  String get settingsAdminUsersTitle;

  /// No description provided for @settingsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get settingsAll;

  /// No description provided for @settingsApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get settingsApply;

  /// No description provided for @settingsCopyToken.
  ///
  /// In fr, this message translates to:
  /// **'Copier le jeton'**
  String get settingsCopyToken;

  /// No description provided for @settingsDefaultUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get settingsDefaultUser;

  /// No description provided for @settingsGenerateInviteLink.
  ///
  /// In fr, this message translates to:
  /// **'Générer un lien (7j)'**
  String get settingsGenerateInviteLink;

  /// No description provided for @settingsHeaderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Préférences utilisateur, configuration Homelab et gestion des accès'**
  String get settingsHeaderSubtitle;

  /// No description provided for @settingsInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get settingsInactive;

  /// No description provided for @settingsInvitationsError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement invitations: {error}'**
  String settingsInvitationsError(String error);

  /// No description provided for @settingsInviteEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'adresse@entreprise.com'**
  String get settingsInviteEmailHint;

  /// No description provided for @settingsInviteEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir une adresse email valide.'**
  String get settingsInviteEmailInvalid;

  /// No description provided for @settingsInviteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création de l\'invitation : {error}'**
  String settingsInviteError(String error);

  /// No description provided for @settingsInviteExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expirée'**
  String get settingsInviteExpired;

  /// No description provided for @settingsInviteGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Invitation générée pour {email} !'**
  String settingsInviteGenerated(String email);

  /// No description provided for @settingsInviteLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'invitation copié dans le presse-papiers'**
  String get settingsInviteLinkCopied;

  /// No description provided for @settingsInviteUsed.
  ///
  /// In fr, this message translates to:
  /// **'Déjà utilisée'**
  String get settingsInviteUsed;

  /// No description provided for @settingsInviteValid.
  ///
  /// In fr, this message translates to:
  /// **'Valide'**
  String get settingsInviteValid;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFr;

  /// No description provided for @settingsNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get settingsNotConnected;

  /// No description provided for @settingsPendingInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations en attente ou récentes'**
  String get settingsPendingInvitations;

  /// No description provided for @settingsPin.
  ///
  /// In fr, this message translates to:
  /// **'Épingler'**
  String get settingsPin;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos informations de compte Disciplan'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil & Compte'**
  String get settingsProfileTitle;

  /// No description provided for @settingsSavedViewSummary.
  ///
  /// In fr, this message translates to:
  /// **'Projet: {project} • Type: {type}'**
  String settingsSavedViewSummary(String project, String type);

  /// No description provided for @settingsSavedViewsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vue sauvegardée pour le moment. Vous pouvez en créer depuis la Vue Liste.'**
  String get settingsSavedViewsEmpty;

  /// No description provided for @settingsSavedViewsError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les vues : {error}'**
  String settingsSavedViewsError(String error);

  /// No description provided for @settingsSavedViewsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos filtres et vues personnalisées épinglées à la barre latérale'**
  String get settingsSavedViewsSubtitle;

  /// No description provided for @settingsSavedViewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vues Sauvegardées'**
  String get settingsSavedViewsTitle;

  /// No description provided for @settingsScaleComfort.
  ///
  /// In fr, this message translates to:
  /// **'Confort (110%)'**
  String get settingsScaleComfort;

  /// No description provided for @settingsScaleCompact.
  ///
  /// In fr, this message translates to:
  /// **'Compact (90%)'**
  String get settingsScaleCompact;

  /// No description provided for @settingsScaleDecrease.
  ///
  /// In fr, this message translates to:
  /// **'Réduire (-5%)'**
  String get settingsScaleDecrease;

  /// No description provided for @settingsScaleFactor.
  ///
  /// In fr, this message translates to:
  /// **'Facteur de mise à l\'échelle'**
  String get settingsScaleFactor;

  /// No description provided for @settingsScaleHint.
  ///
  /// In fr, this message translates to:
  /// **'Astuce : vous pouvez saisir n\'importe quel pourcentage entre 50% et 200%, ou ajuster le facteur depuis la barre supérieure.'**
  String get settingsScaleHint;

  /// No description provided for @settingsScaleIncrease.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter (+5%)'**
  String get settingsScaleIncrease;

  /// No description provided for @settingsScaleLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grand écran (120%)'**
  String get settingsScaleLarge;

  /// No description provided for @settingsScaleReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser (100%)'**
  String get settingsScaleReset;

  /// No description provided for @settingsScaleStandard.
  ///
  /// In fr, this message translates to:
  /// **'Standard (100%)'**
  String get settingsScaleStandard;

  /// No description provided for @settingsScalingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Adaptez la taille des polices et des éléments visuels à la résolution de votre écran'**
  String get settingsScalingSubtitle;

  /// No description provided for @settingsScalingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Affichage & Mise à l\'échelle (UI Scaling)'**
  String get settingsScalingTitle;

  /// No description provided for @settingsServerHint.
  ///
  /// In fr, this message translates to:
  /// **'Les requêtes HTTP et l\'abonnement iCal s\'appuient sur cette URL de base.'**
  String get settingsServerHint;

  /// No description provided for @settingsServerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de votre instance Disciplan sur le réseau local ou distant'**
  String get settingsServerSubtitle;

  /// No description provided for @settingsServerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Serveur Homelab'**
  String get settingsServerTitle;

  /// No description provided for @settingsServerUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de contacter le serveur'**
  String get settingsServerUnreachable;

  /// No description provided for @settingsServerUrlUpdated.
  ///
  /// In fr, this message translates to:
  /// **'URL du serveur Homelab mise à jour'**
  String get settingsServerUrlUpdated;

  /// No description provided for @settingsSessionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecte ce poste de votre instance Disciplan'**
  String get settingsSessionSubtitle;

  /// No description provided for @settingsSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Session active'**
  String get settingsSessionTitle;

  /// No description provided for @settingsTokenCopied.
  ///
  /// In fr, this message translates to:
  /// **'Jeton d\'invitation copié'**
  String get settingsTokenCopied;

  /// No description provided for @settingsUnpin.
  ///
  /// In fr, this message translates to:
  /// **'Détacher'**
  String get settingsUnpin;

  /// No description provided for @settingsUpdateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour : {error}'**
  String settingsUpdateError(String error);

  /// No description provided for @settingsUsersError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement utilisateurs: {error}'**
  String settingsUsersError(String error);

  /// No description provided for @settingsYou.
  ///
  /// In fr, this message translates to:
  /// **'(vous)'**
  String get settingsYou;

  /// No description provided for @shellActiveSprintName.
  ///
  /// In fr, this message translates to:
  /// **'Sprint actif : {name}'**
  String shellActiveSprintName(String name);

  /// No description provided for @shellActivityError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String shellActivityError(String error);

  /// No description provided for @shellAllProjects.
  ///
  /// In fr, this message translates to:
  /// **'Tous mes Projets'**
  String get shellAllProjects;

  /// No description provided for @shellApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get shellApply;

  /// No description provided for @shellChangeProject.
  ///
  /// In fr, this message translates to:
  /// **'Changer de projet'**
  String get shellChangeProject;

  /// No description provided for @shellCollapseSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Replier la barre latérale (⌘B)'**
  String get shellCollapseSidebar;

  /// No description provided for @shellCrumbBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog du Projet'**
  String get shellCrumbBacklog;

  /// No description provided for @shellCrumbBacklogList.
  ///
  /// In fr, this message translates to:
  /// **'Backlog & Vue Liste'**
  String get shellCrumbBacklogList;

  /// No description provided for @shellCrumbCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles & Sprints'**
  String get shellCrumbCycles;

  /// No description provided for @shellCrumbMyTasks.
  ///
  /// In fr, this message translates to:
  /// **'Mon Dashboard & Tâches'**
  String get shellCrumbMyTasks;

  /// No description provided for @shellCrumbWorkspace.
  ///
  /// In fr, this message translates to:
  /// **'Espace'**
  String get shellCrumbWorkspace;

  /// No description provided for @shellDisplaySize.
  ///
  /// In fr, this message translates to:
  /// **'Taille d\'affichage ({percent}%)'**
  String shellDisplaySize(int percent);

  /// No description provided for @shellMobileCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles'**
  String get shellMobileCycles;

  /// No description provided for @shellMobileDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard'**
  String get shellMobileDashboard;

  /// No description provided for @shellMobileProjects.
  ///
  /// In fr, this message translates to:
  /// **'Mes Projets'**
  String get shellMobileProjects;

  /// No description provided for @shellMobileTasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches'**
  String get shellMobileTasks;

  /// No description provided for @shellNewTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get shellNewTask;

  /// No description provided for @shellPersonalSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace personnel'**
  String get shellPersonalSpace;

  /// No description provided for @shellProjectPlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan du projet'**
  String get shellProjectPlan;

  /// No description provided for @shellProjectViews.
  ///
  /// In fr, this message translates to:
  /// **'Vues du projet'**
  String get shellProjectViews;

  /// No description provided for @shellScaleComfort.
  ///
  /// In fr, this message translates to:
  /// **'Confort (110%)'**
  String get shellScaleComfort;

  /// No description provided for @shellScaleCompact.
  ///
  /// In fr, this message translates to:
  /// **'Compact (90%)'**
  String get shellScaleCompact;

  /// No description provided for @shellScaleCustom.
  ///
  /// In fr, this message translates to:
  /// **'Facteur personnalisé ({percent}%)...'**
  String shellScaleCustom(int percent);

  /// No description provided for @shellScaleCustomHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un facteur entre 50% et 200% (ou utilisez les préréglages 90%, 100%, 110%, 120%).'**
  String get shellScaleCustomHint;

  /// No description provided for @shellScaleCustomTitle.
  ///
  /// In fr, this message translates to:
  /// **'Facteur de mise à l\'échelle personnalisé'**
  String get shellScaleCustomTitle;

  /// No description provided for @shellScaleLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grand écran (120%)'**
  String get shellScaleLarge;

  /// No description provided for @shellScaleReset.
  ///
  /// In fr, this message translates to:
  /// **'100% (Défaut)'**
  String get shellScaleReset;

  /// No description provided for @shellScaleStandard.
  ///
  /// In fr, this message translates to:
  /// **'Standard (100%)'**
  String get shellScaleStandard;

  /// No description provided for @shellSearchPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une tâche, aller au Kanban, Backlog...'**
  String get shellSearchPlaceholder;

  /// No description provided for @shellSelectProject.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un projet'**
  String get shellSelectProject;

  /// No description provided for @shellSidebarAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get shellSidebarAdmin;

  /// No description provided for @shellSidebarCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier & Jalons'**
  String get shellSidebarCalendar;

  /// No description provided for @shellSidebarCalendarSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Échéances & flux iCal'**
  String get shellSidebarCalendarSubtitle;

  /// No description provided for @shellSidebarCurrentSprints.
  ///
  /// In fr, this message translates to:
  /// **'Sprints en cours'**
  String get shellSidebarCurrentSprints;

  /// No description provided for @shellSidebarCyclesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Cycles, vélocité & roadmap'**
  String get shellSidebarCyclesSubtitle;

  /// No description provided for @shellSidebarKanban.
  ///
  /// In fr, this message translates to:
  /// **'Tableau Kanban'**
  String get shellSidebarKanban;

  /// No description provided for @shellSidebarListSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Backlog & tickets du projet'**
  String get shellSidebarListSubtitle;

  /// No description provided for @shellSidebarListView.
  ///
  /// In fr, this message translates to:
  /// **'Vue Liste'**
  String get shellSidebarListView;

  /// No description provided for @shellSidebarMyTasks.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard & Mes Tâches'**
  String get shellSidebarMyTasks;

  /// No description provided for @shellSidebarMyTasksSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue globale & tickets assignés'**
  String get shellSidebarMyTasksSubtitle;

  /// No description provided for @shellSidebarPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning & Cycles'**
  String get shellSidebarPlanning;

  /// No description provided for @shellSidebarPortfolioSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille & espaces projets'**
  String get shellSidebarPortfolioSubtitle;

  /// No description provided for @shellSidebarTeamSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres d\'équipe'**
  String get shellSidebarTeamSettings;

  /// No description provided for @shellSprintCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Capacité Sprint'**
  String get shellSprintCapacity;

  /// No description provided for @shellSprintNoneActive.
  ///
  /// In fr, this message translates to:
  /// **'Aucun actif'**
  String get shellSprintNoneActive;

  /// No description provided for @shellSprintProgress.
  ///
  /// In fr, this message translates to:
  /// **'Avancement Sprint'**
  String get shellSprintProgress;

  /// No description provided for @shellSwitchProject.
  ///
  /// In fr, this message translates to:
  /// **'Changer de projet actif'**
  String get shellSwitchProject;

  /// No description provided for @shellToggleSidebar.
  ///
  /// In fr, this message translates to:
  /// **'Basculer la barre latérale (⌘B)'**
  String get shellToggleSidebar;

  /// No description provided for @shellTooltipBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Backlog & Tickets du projet'**
  String get shellTooltipBacklog;

  /// No description provided for @shellTooltipCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier d\'équipe'**
  String get shellTooltipCalendar;

  /// No description provided for @shellTooltipCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles & Feuille de route'**
  String get shellTooltipCycles;

  /// No description provided for @shellTooltipKanban.
  ///
  /// In fr, this message translates to:
  /// **'Tableau Kanban des Sprints'**
  String get shellTooltipKanban;

  /// No description provided for @shellTooltipMyTasks.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord & Mes Tâches'**
  String get shellTooltipMyTasks;

  /// No description provided for @shellTooltipSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche globale (⌘K)'**
  String get shellTooltipSearch;

  /// No description provided for @shellTooltipSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres (⌘,)'**
  String get shellTooltipSettings;

  /// No description provided for @sprintBacklogTicketsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets du Backlog à inclure'**
  String get sprintBacklogTicketsTitle;

  /// No description provided for @sprintCadenceFlash.
  ///
  /// In fr, this message translates to:
  /// **'Flash (7j)'**
  String get sprintCadenceFlash;

  /// No description provided for @sprintCadenceOneMonth.
  ///
  /// In fr, this message translates to:
  /// **'1 mois'**
  String get sprintCadenceOneMonth;

  /// No description provided for @sprintCadenceOneWeek.
  ///
  /// In fr, this message translates to:
  /// **'1 sem.'**
  String get sprintCadenceOneWeek;

  /// No description provided for @sprintCadenceOptimal.
  ///
  /// In fr, this message translates to:
  /// **'Optimal (14j)'**
  String get sprintCadenceOptimal;

  /// No description provided for @sprintCadenceProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet (30j)'**
  String get sprintCadenceProject;

  /// No description provided for @sprintCadenceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rythme & Fréquence'**
  String get sprintCadenceTitle;

  /// No description provided for @sprintCadenceTwoWeeks.
  ///
  /// In fr, this message translates to:
  /// **'2 sem.'**
  String get sprintCadenceTwoWeeks;

  /// No description provided for @sprintCadenceWeeks.
  ///
  /// In fr, this message translates to:
  /// **'{weeks} semaine(s) ({days}j)'**
  String sprintCadenceWeeks(int weeks, int days);

  /// No description provided for @sprintClosedCyclesSection.
  ///
  /// In fr, this message translates to:
  /// **'Cycles clôturés & historique'**
  String get sprintClosedCyclesSection;

  /// No description provided for @sprintClosedTicketsProgress.
  ///
  /// In fr, this message translates to:
  /// **'{closed}/{total} terminées'**
  String sprintClosedTicketsProgress(int closed, int total);

  /// No description provided for @sprintContributorsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} contributeurs'**
  String sprintContributorsCount(int count);

  /// No description provided for @sprintCreateCycle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un cycle'**
  String get sprintCreateCycle;

  /// No description provided for @sprintCreateModalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer et planifier un cycle'**
  String get sprintCreateModalTitle;

  /// No description provided for @sprintCreatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Sprint créé avec succès !'**
  String get sprintCreatedSuccess;

  /// No description provided for @sprintCyclesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Planification temporelle et métriques de vélocité du projet {name}.'**
  String sprintCyclesSubtitle(String name);

  /// No description provided for @sprintCyclesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cycles & Sprints'**
  String get sprintCyclesTitle;

  /// No description provided for @sprintDatesNotDefined.
  ///
  /// In fr, this message translates to:
  /// **'Dates non définies'**
  String get sprintDatesNotDefined;

  /// No description provided for @sprintDatesUndefined.
  ///
  /// In fr, this message translates to:
  /// **'Dates indéfinies'**
  String get sprintDatesUndefined;

  /// No description provided for @sprintDaysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'J-{count} restants'**
  String sprintDaysRemaining(int count);

  /// No description provided for @sprintDaysRemainingBadge.
  ///
  /// In fr, this message translates to:
  /// **'J-{count}'**
  String sprintDaysRemainingBadge(int count);

  /// No description provided for @sprintDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Sprint {month} — Optimisations & Livrables'**
  String sprintDefaultName(int month);

  /// No description provided for @sprintEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get sprintEndDate;

  /// No description provided for @sprintFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer le sprint'**
  String get sprintFinish;

  /// No description provided for @sprintGoalHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Finaliser la refonte graphique et valider la campagne de marque...'**
  String get sprintGoalHint;

  /// No description provided for @sprintGoalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Objectif principal du cycle (Sprint Goal)'**
  String get sprintGoalLabel;

  /// No description provided for @sprintLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement: {error}'**
  String sprintLoadError(String error);

  /// No description provided for @sprintNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Sprint 5 — Production & Lancement'**
  String get sprintNameHint;

  /// No description provided for @sprintNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du cycle / sprint'**
  String get sprintNameLabel;

  /// No description provided for @sprintNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un nom de sprint.'**
  String get sprintNameRequired;

  /// No description provided for @sprintNewTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get sprintNewTask;

  /// No description provided for @sprintNoActiveCycleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Démarrez un cycle planifié, prévisualisez son Kanban ou créez un nouveau sprint.'**
  String get sprintNoActiveCycleDesc;

  /// No description provided for @sprintNoBacklogTickets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket disponible dans le backlog.'**
  String get sprintNoBacklogTickets;

  /// No description provided for @sprintNoClosedCycles.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cycle clôturé.'**
  String get sprintNoClosedCycles;

  /// No description provided for @sprintNoPlannedCycles.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cycle planifié pour le moment.'**
  String get sprintNoPlannedCycles;

  /// No description provided for @sprintPercentCompleted.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% complété'**
  String sprintPercentCompleted(int percent);

  /// No description provided for @sprintPlannedCyclesSection.
  ///
  /// In fr, this message translates to:
  /// **'Cycles planifiés'**
  String get sprintPlannedCyclesSection;

  /// No description provided for @sprintPointsShort.
  ///
  /// In fr, this message translates to:
  /// **'{points} pts'**
  String sprintPointsShort(int points);

  /// No description provided for @sprintRemainingTickets.
  ///
  /// In fr, this message translates to:
  /// **'{count} restantes'**
  String sprintRemainingTickets(int count);

  /// No description provided for @sprintRemainingTicketsSub.
  ///
  /// In fr, this message translates to:
  /// **'en cours / à faire'**
  String get sprintRemainingTicketsSub;

  /// No description provided for @sprintSelectProject.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un projet pour afficher ses cycles.'**
  String get sprintSelectProject;

  /// No description provided for @sprintSelectedTicketsSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count} tâche(s) · {points} pts'**
  String sprintSelectedTicketsSummary(int count, int points);

  /// No description provided for @sprintStartCycle.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer le cycle'**
  String get sprintStartCycle;

  /// No description provided for @sprintStartDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get sprintStartDate;

  /// No description provided for @sprintStartImmediately.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer immédiatement ce sprint'**
  String get sprintStartImmediately;

  /// No description provided for @sprintStartImmediatelyHint.
  ///
  /// In fr, this message translates to:
  /// **'Le sprint passera au statut Actif dès sa création.'**
  String get sprintStartImmediatelyHint;

  /// No description provided for @sprintStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get sprintStatusActive;

  /// No description provided for @sprintStatusClosed.
  ///
  /// In fr, this message translates to:
  /// **'Clos'**
  String get sprintStatusClosed;

  /// No description provided for @sprintStatusPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Planifié'**
  String get sprintStatusPlanned;

  /// No description provided for @sprintSuggested.
  ///
  /// In fr, this message translates to:
  /// **'Suggéré :'**
  String get sprintSuggested;

  /// No description provided for @sprintSuggestion1.
  ///
  /// In fr, this message translates to:
  /// **'Déploiement Capsule Q3'**
  String get sprintSuggestion1;

  /// No description provided for @sprintSuggestion2.
  ///
  /// In fr, this message translates to:
  /// **'Optimisations & Recette'**
  String get sprintSuggestion2;

  /// No description provided for @sprintTaskCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} tâche(s)'**
  String sprintTaskCount(int count);

  /// No description provided for @sprintTeamBurndown.
  ///
  /// In fr, this message translates to:
  /// **'Burn-down d\'équipe'**
  String get sprintTeamBurndown;

  /// No description provided for @ticketsActiveCycle.
  ///
  /// In fr, this message translates to:
  /// **'Cycle actif'**
  String get ticketsActiveCycle;

  /// No description provided for @ticketsActiveSprintName.
  ///
  /// In fr, this message translates to:
  /// **'Sprint actif : {name}'**
  String ticketsActiveSprintName(String name);

  /// No description provided for @ticketsAddFirstQuickTask.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre première tâche rapide ci-dessous.'**
  String get ticketsAddFirstQuickTask;

  /// No description provided for @ticketsAddNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note...'**
  String get ticketsAddNoteHint;

  /// No description provided for @ticketsAddSubtaskHint.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter une sous-tâche...'**
  String get ticketsAddSubtaskHint;

  /// No description provided for @ticketsAssign.
  ///
  /// In fr, this message translates to:
  /// **'Assigner'**
  String get ticketsAssign;

  /// No description provided for @ticketsAssignMember.
  ///
  /// In fr, this message translates to:
  /// **'Assigner à un membre du projet'**
  String get ticketsAssignMember;

  /// No description provided for @ticketsAssignSelectionToSprint.
  ///
  /// In fr, this message translates to:
  /// **'Affecter la sélection à un sprint'**
  String get ticketsAssignSelectionToSprint;

  /// No description provided for @ticketsAssignTo.
  ///
  /// In fr, this message translates to:
  /// **'Assigner à'**
  String get ticketsAssignTo;

  /// No description provided for @ticketsAssignToSprint.
  ///
  /// In fr, this message translates to:
  /// **'Affecter à un sprint'**
  String get ticketsAssignToSprint;

  /// No description provided for @ticketsAssignToSprintFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'affectation au sprint : {detail}'**
  String ticketsAssignToSprintFailed(String detail);

  /// No description provided for @ticketsAssignedLabel.
  ///
  /// In fr, this message translates to:
  /// **'ASSIGNÉ'**
  String get ticketsAssignedLabel;

  /// No description provided for @ticketsAssigneeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Assigné'**
  String get ticketsAssigneeLabel;

  /// No description provided for @ticketsBacklogHeaderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Tickets hors sprint en attente de planification. Affectez-les à un sprint ou modifiez leur priorité.'**
  String get ticketsBacklogHeaderDesc;

  /// No description provided for @ticketsBacklogListView.
  ///
  /// In fr, this message translates to:
  /// **'Backlog & Vue Liste'**
  String get ticketsBacklogListView;

  /// No description provided for @ticketsBacklogNoSprint.
  ///
  /// In fr, this message translates to:
  /// **'Backlog (sans sprint)'**
  String get ticketsBacklogNoSprint;

  /// No description provided for @ticketsBacklogPrioritize.
  ///
  /// In fr, this message translates to:
  /// **'Lister et prioriser le backlog'**
  String get ticketsBacklogPrioritize;

  /// No description provided for @ticketsBacklogProjectBadge.
  ///
  /// In fr, this message translates to:
  /// **'BACKLOG DU PROJET'**
  String get ticketsBacklogProjectBadge;

  /// No description provided for @ticketsBacklogScopeChip.
  ///
  /// In fr, this message translates to:
  /// **'Backlog (Hors sprint)'**
  String get ticketsBacklogScopeChip;

  /// No description provided for @ticketsBacklogSectionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets du backlog prêts à être planifiés ou démarrés'**
  String get ticketsBacklogSectionSubtitle;

  /// No description provided for @ticketsBacklogToPlan.
  ///
  /// In fr, this message translates to:
  /// **'{count} ticket(s) hors sprint à planifier'**
  String ticketsBacklogToPlan(int count);

  /// No description provided for @ticketsChangeStatus.
  ///
  /// In fr, this message translates to:
  /// **'Changer le statut'**
  String get ticketsChangeStatus;

  /// No description provided for @ticketsCommentAddFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur ajout commentaire: {detail}'**
  String ticketsCommentAddFailed(String detail);

  /// No description provided for @ticketsCommentPosted.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire publié'**
  String get ticketsCommentPosted;

  /// No description provided for @ticketsCopyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get ticketsCopyLink;

  /// No description provided for @ticketsCreateAnother.
  ///
  /// In fr, this message translates to:
  /// **'Créer une autre tâche'**
  String get ticketsCreateAnother;

  /// No description provided for @ticketsCreateAnotherNext.
  ///
  /// In fr, this message translates to:
  /// **'Créer une autre tâche ensuite'**
  String get ticketsCreateAnotherNext;

  /// No description provided for @ticketsCreateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création : {detail}'**
  String ticketsCreateFailed(String detail);

  /// No description provided for @ticketsCreateTask.
  ///
  /// In fr, this message translates to:
  /// **'Créer la tâche'**
  String get ticketsCreateTask;

  /// No description provided for @ticketsCreateTicket.
  ///
  /// In fr, this message translates to:
  /// **'Créer un ticket'**
  String get ticketsCreateTicket;

  /// No description provided for @ticketsCycleSprint.
  ///
  /// In fr, this message translates to:
  /// **'CYCLE / SPRINT'**
  String get ticketsCycleSprint;

  /// No description provided for @ticketsCycles.
  ///
  /// In fr, this message translates to:
  /// **'Cycles'**
  String get ticketsCycles;

  /// No description provided for @ticketsCyclesOf.
  ///
  /// In fr, this message translates to:
  /// **'Cycles de {name}'**
  String ticketsCyclesOf(String name);

  /// No description provided for @ticketsCyclesSprints.
  ///
  /// In fr, this message translates to:
  /// **'Cycles & Sprints'**
  String get ticketsCyclesSprints;

  /// No description provided for @ticketsDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une description détaillée (Markdown supporté)...'**
  String get ticketsDescriptionHint;

  /// No description provided for @ticketsDoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets livrés et validés'**
  String get ticketsDoneSubtitle;

  /// No description provided for @ticketsEditPriority.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la priorité'**
  String get ticketsEditPriority;

  /// No description provided for @ticketsEditableAnytime.
  ///
  /// In fr, this message translates to:
  /// **'Modifiable à tout moment'**
  String get ticketsEditableAnytime;

  /// No description provided for @ticketsEnterKey.
  ///
  /// In fr, this message translates to:
  /// **'Entrée'**
  String get ticketsEnterKey;

  /// No description provided for @ticketsErrorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {detail}'**
  String ticketsErrorDetail(String detail);

  /// No description provided for @ticketsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes ({count})'**
  String ticketsFilterAll(int count);

  /// No description provided for @ticketsFilterByPriority.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par priorité'**
  String get ticketsFilterByPriority;

  /// No description provided for @ticketsFilterDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminées ({count})'**
  String ticketsFilterDone(int count);

  /// No description provided for @ticketsFilterInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours ({count})'**
  String ticketsFilterInProgress(int count);

  /// No description provided for @ticketsFilterTicketsHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer les tickets (titre, réf, assigné)...'**
  String get ticketsFilterTicketsHint;

  /// No description provided for @ticketsFilterTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire ({count})'**
  String ticketsFilterTodo(int count);

  /// No description provided for @ticketsFilterUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgentes ({count})'**
  String ticketsFilterUrgent(int count);

  /// No description provided for @ticketsFocusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'FOCUS — VOS TICKETS EN COURS ({count})'**
  String ticketsFocusInProgress(int count);

  /// No description provided for @ticketsFullPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille complet'**
  String get ticketsFullPortfolio;

  /// No description provided for @ticketsHistoryTab.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get ticketsHistoryTab;

  /// No description provided for @ticketsInProgressAttention.
  ///
  /// In fr, this message translates to:
  /// **'{count} tâche(s) en cours requièrent votre attention.'**
  String ticketsInProgressAttention(int count);

  /// No description provided for @ticketsInProgressSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets activement travaillés'**
  String get ticketsInProgressSubtitle;

  /// No description provided for @ticketsIsolateInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Isoler En cours →'**
  String get ticketsIsolateInProgress;

  /// No description provided for @ticketsKanbanBoard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau Kanban'**
  String get ticketsKanbanBoard;

  /// No description provided for @ticketsKeepOpenHint.
  ///
  /// In fr, this message translates to:
  /// **'Garder la modale ouverte pour enchaîner'**
  String get ticketsKeepOpenHint;

  /// No description provided for @ticketsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement: {detail}'**
  String ticketsLoadError(String detail);

  /// No description provided for @ticketsLoadTicketFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le ticket'**
  String get ticketsLoadTicketFailed;

  /// No description provided for @ticketsManageSprints.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les Sprints'**
  String get ticketsManageSprints;

  /// No description provided for @ticketsMyProjectsSpaces.
  ///
  /// In fr, this message translates to:
  /// **'MES PROJETS — ESPACES ENCAPSULÉS'**
  String get ticketsMyProjectsSpaces;

  /// No description provided for @ticketsNewTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get ticketsNewTask;

  /// No description provided for @ticketsNoAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce jointe.'**
  String get ticketsNoAttachment;

  /// No description provided for @ticketsNoExchange.
  ///
  /// In fr, this message translates to:
  /// **'Aucun échange pour le moment.'**
  String get ticketsNoExchange;

  /// No description provided for @ticketsNoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Aucun label associé'**
  String get ticketsNoLabel;

  /// No description provided for @ticketsNoSubtask.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sous-tâche pour ce ticket.'**
  String get ticketsNoSubtask;

  /// No description provided for @ticketsNoTaskInSection.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche dans cette section.'**
  String get ticketsNoTaskInSection;

  /// No description provided for @ticketsNoTaskMatchFilter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche ne correspond à ce filtre.'**
  String get ticketsNoTaskMatchFilter;

  /// No description provided for @ticketsNoTicketBacklog.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket dans le backlog'**
  String get ticketsNoTicketBacklog;

  /// No description provided for @ticketsNoTicketMatchSearch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket ne correspond à votre recherche.'**
  String get ticketsNoTicketMatchSearch;

  /// No description provided for @ticketsNoTicketSprint.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ticket dans ce sprint'**
  String get ticketsNoTicketSprint;

  /// No description provided for @ticketsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get ticketsNone;

  /// No description provided for @ticketsNotFoundRef.
  ///
  /// In fr, this message translates to:
  /// **'Ticket non trouvé : {ref}'**
  String ticketsNotFoundRef(String ref);

  /// No description provided for @ticketsNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Non définie'**
  String get ticketsNotSet;

  /// No description provided for @ticketsNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des notes, contexte ou critères de validation...'**
  String get ticketsNotesHint;

  /// No description provided for @ticketsOtherAssignedTasks.
  ///
  /// In fr, this message translates to:
  /// **'AUTRES TÂCHES ASSIGNÉES ({count})'**
  String ticketsOtherAssignedTasks(int count);

  /// No description provided for @ticketsOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get ticketsOwner;

  /// No description provided for @ticketsPercentDone.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% complété'**
  String ticketsPercentDone(int percent);

  /// No description provided for @ticketsPersonalDashboardBadge.
  ///
  /// In fr, this message translates to:
  /// **'TABLEAU DE BORD PERSONNEL'**
  String get ticketsPersonalDashboardBadge;

  /// No description provided for @ticketsPinToHome.
  ///
  /// In fr, this message translates to:
  /// **'Épingler sur l\'accueil / sidebar'**
  String get ticketsPinToHome;

  /// No description provided for @ticketsPlanInSprint.
  ///
  /// In fr, this message translates to:
  /// **'Planifier {count} ticket(s) dans un sprint'**
  String ticketsPlanInSprint(int count);

  /// No description provided for @ticketsPlannedInSprint.
  ///
  /// In fr, this message translates to:
  /// **'{count} ticket(s) planifié(s) dans \"{name}\".'**
  String ticketsPlannedInSprint(int count, String name);

  /// No description provided for @ticketsPriorityAll.
  ///
  /// In fr, this message translates to:
  /// **'Priorité : Toutes'**
  String get ticketsPriorityAll;

  /// No description provided for @ticketsPrioritySelected.
  ///
  /// In fr, this message translates to:
  /// **'Priorité : {priority}'**
  String ticketsPrioritySelected(String priority);

  /// No description provided for @ticketsProjectBacklogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Backlog du Projet'**
  String get ticketsProjectBacklogTitle;

  /// No description provided for @ticketsProjectTileSummary.
  ///
  /// In fr, this message translates to:
  /// **'{tickets} tickets • {sprints} sprints • {role}'**
  String ticketsProjectTileSummary(int tickets, int sprints, String role);

  /// No description provided for @ticketsQuickAddHint.
  ///
  /// In fr, this message translates to:
  /// **'+ Ajouter une tâche rapide... (Entrée)'**
  String get ticketsQuickAddHint;

  /// No description provided for @ticketsQuickAddInSection.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une tâche rapide dans \"{section}\"...'**
  String ticketsQuickAddInSection(String section);

  /// No description provided for @ticketsQuickMetadata.
  ///
  /// In fr, this message translates to:
  /// **'MÉTADONNÉES RAPIDES'**
  String get ticketsQuickMetadata;

  /// No description provided for @ticketsRecentExchanges.
  ///
  /// In fr, this message translates to:
  /// **'Échanges récents'**
  String get ticketsRecentExchanges;

  /// No description provided for @ticketsRefCopied.
  ///
  /// In fr, this message translates to:
  /// **'Référence copiée dans le presse-papier'**
  String get ticketsRefCopied;

  /// No description provided for @ticketsResetFilters.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get ticketsResetFilters;

  /// No description provided for @ticketsSaveAsViewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer comme vue sauvegardée'**
  String get ticketsSaveAsViewTitle;

  /// No description provided for @ticketsSaveView.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder la vue'**
  String get ticketsSaveView;

  /// No description provided for @ticketsSavedViewActivated.
  ///
  /// In fr, this message translates to:
  /// **'Vue sauvegardée activée.'**
  String get ticketsSavedViewActivated;

  /// No description provided for @ticketsSavedViews.
  ///
  /// In fr, this message translates to:
  /// **'Vues enregistrées'**
  String get ticketsSavedViews;

  /// No description provided for @ticketsSelectProject.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get ticketsSelectProject;

  /// No description provided for @ticketsSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} sélectionné(s)'**
  String ticketsSelectedCount(int count);

  /// No description provided for @ticketsSprintChangeFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur changement de sprint : {detail}'**
  String ticketsSprintChangeFailed(String detail);

  /// No description provided for @ticketsSprintCycle.
  ///
  /// In fr, this message translates to:
  /// **'Sprint / Cycle'**
  String get ticketsSprintCycle;

  /// No description provided for @ticketsSprintHeaderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Liste détaillée des tickets affectés à ce cycle.'**
  String get ticketsSprintHeaderDesc;

  /// No description provided for @ticketsSprintListBadge.
  ///
  /// In fr, this message translates to:
  /// **'LISTE DU SPRINT'**
  String get ticketsSprintListBadge;

  /// No description provided for @ticketsSprintPlanHint.
  ///
  /// In fr, this message translates to:
  /// **'Planifier, démarrer ou clôturer un sprint'**
  String get ticketsSprintPlanHint;

  /// No description provided for @ticketsSprintTicketsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets du Sprint'**
  String get ticketsSprintTicketsTitle;

  /// No description provided for @ticketsSprintTodoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Tickets du sprint en attente de démarrage'**
  String get ticketsSprintTodoSubtitle;

  /// No description provided for @ticketsStatusChangeFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur changement de statut : {detail}'**
  String ticketsStatusChangeFailed(String detail);

  /// No description provided for @ticketsSubtaskAddFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur ajout sous-tâche: {detail}'**
  String ticketsSubtaskAddFailed(String detail);

  /// No description provided for @ticketsSubtaskUpdateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur mise à jour sous-tâche: {detail}'**
  String ticketsSubtaskUpdateFailed(String detail);

  /// No description provided for @ticketsSubtasks.
  ///
  /// In fr, this message translates to:
  /// **'Sous-tâches'**
  String get ticketsSubtasks;

  /// No description provided for @ticketsSubtasksDeliverables.
  ///
  /// In fr, this message translates to:
  /// **'Sous-tâches & Livrables'**
  String get ticketsSubtasksDeliverables;

  /// No description provided for @ticketsTaskCreated.
  ///
  /// In fr, this message translates to:
  /// **'Tâche créée avec succès'**
  String get ticketsTaskCreated;

  /// No description provided for @ticketsTaskCreatedNext.
  ///
  /// In fr, this message translates to:
  /// **'Tâche créée ! Vous pouvez en saisir une autre.'**
  String get ticketsTaskCreatedNext;

  /// No description provided for @ticketsTaskTitleActionHint.
  ///
  /// In fr, this message translates to:
  /// **'Intitulé de la tâche ou action...'**
  String get ticketsTaskTitleActionHint;

  /// No description provided for @ticketsTaskTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre de la tâche...'**
  String get ticketsTaskTitleHint;

  /// No description provided for @ticketsTicketDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail Ticket'**
  String get ticketsTicketDetailTitle;

  /// No description provided for @ticketsTicketLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien du ticket copié'**
  String get ticketsTicketLinkCopied;

  /// No description provided for @ticketsTicketLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement ticket'**
  String get ticketsTicketLoadError;

  /// No description provided for @ticketsTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un titre.'**
  String get ticketsTitleRequired;

  /// No description provided for @ticketsToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get ticketsToday;

  /// No description provided for @ticketsTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get ticketsTodo;

  /// No description provided for @ticketsTodoBacklog.
  ///
  /// In fr, this message translates to:
  /// **'À faire / Backlog'**
  String get ticketsTodoBacklog;

  /// No description provided for @ticketsTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get ticketsTomorrow;

  /// No description provided for @ticketsUnassignedClick.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné (Cliquer)'**
  String get ticketsUnassignedClick;

  /// No description provided for @ticketsUpdateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de mise à jour : {detail}'**
  String ticketsUpdateFailed(String detail);

  /// No description provided for @ticketsUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgentes'**
  String get ticketsUrgent;

  /// No description provided for @ticketsViewDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtre automatique appliqué...'**
  String get ticketsViewDescriptionHint;

  /// No description provided for @ticketsViewDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description (facultative)'**
  String get ticketsViewDescriptionLabel;

  /// No description provided for @ticketsViewNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Tâches Urgentes, Revue Sprint...'**
  String get ticketsViewNameHint;

  /// No description provided for @ticketsViewNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la vue'**
  String get ticketsViewNameLabel;

  /// No description provided for @ticketsViewNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un nom pour la vue.'**
  String get ticketsViewNameRequired;

  /// No description provided for @ticketsViewSaved.
  ///
  /// In fr, this message translates to:
  /// **'Vue sauvegardée avec succès !'**
  String get ticketsViewSaved;

  /// No description provided for @ticketsViewSprintColumns.
  ///
  /// In fr, this message translates to:
  /// **'Voir les colonnes du sprint'**
  String get ticketsViewSprintColumns;

  /// No description provided for @ticketsYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get ticketsYesterday;

  /// No description provided for @typeBug.
  ///
  /// In fr, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeEpic.
  ///
  /// In fr, this message translates to:
  /// **'Épopée'**
  String get typeEpic;

  /// No description provided for @typeStory.
  ///
  /// In fr, this message translates to:
  /// **'Story'**
  String get typeStory;

  /// No description provided for @typeSubtask.
  ///
  /// In fr, this message translates to:
  /// **'Sous-tâche'**
  String get typeSubtask;

  /// No description provided for @typeTask.
  ///
  /// In fr, this message translates to:
  /// **'Tâche'**
  String get typeTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
