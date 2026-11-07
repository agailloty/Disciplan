// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get title => 'Title';

  @override
  String get type => 'Type';

  @override
  String get priority => 'Priority';

  @override
  String get loading => 'Loading…';

  @override
  String get nodescription => 'No description.';

  @override
  String get errorDefault => 'An error occurred. Please try again.';

  @override
  String get errorLoad => 'Failed to load data.';

  @override
  String get errorCreate => 'Creation failed.';

  @override
  String get errorUpdate => 'Update failed.';

  @override
  String get errorDelete => 'Deletion failed.';

  @override
  String get errorMove => 'Move failed. Please try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navBoards => 'Boards';

  @override
  String get navProjects => 'Projects';

  @override
  String get navMyTickets => 'My tickets';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navLabels => 'Labels';

  @override
  String get navAdmin => 'Admin';

  @override
  String get navLogout => 'Sign out';

  @override
  String get authSubtitle => 'Sign in to continue';

  @override
  String get authEmail => 'Email address';

  @override
  String get authPassword => 'Password';

  @override
  String get authSubmit => 'Sign in';

  @override
  String get authSubmitting => 'Signing in…';

  @override
  String get authErrorInvalid => 'Invalid credentials.';

  @override
  String dashboardGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle =>
      'An overview of your projects and your assigned tickets';

  @override
  String get dashboardProjectsSection => 'Your projects';

  @override
  String get dashboardNoProjects =>
      'No project yet. Create one to get started.';

  @override
  String get dashboardOpenProject => 'Open';

  @override
  String get dashboardMyTicketsSection => 'My tickets';

  @override
  String get dashboardStatusFilterTooltip => 'Displayed statuses';

  @override
  String get dashboardTicketStatusOverview => 'Tickets overview';

  @override
  String get dashboardNoTickets => 'No ticket matches the selected statuses.';

  @override
  String get boardCreateTitle => 'New board';

  @override
  String get boardAddColumn => 'Add a column';

  @override
  String get boardDropHere => 'Drop here';

  @override
  String get boardEditTitle => 'Edit board';

  @override
  String get boardEmpty => 'No boards yet.';

  @override
  String get boardCreateFirst => 'Create my first board';

  @override
  String get boardDescription => 'Description (optional)';

  @override
  String get boardDeleteTitle => 'Delete board';

  @override
  String boardDeleteConfirm(String name) {
    return 'Delete \"$name\"? All columns and cards will be lost.';
  }

  @override
  String get boardDeleteWarning =>
      'This action is irreversible. All columns, cards, and data will be deleted.';

  @override
  String get boardSettings => 'Settings';

  @override
  String get boardGeneralInfo => 'General';

  @override
  String boardColumnCount(int count) {
    return '$count col.';
  }

  @override
  String get boardAddCard => 'Add a card';

  @override
  String get projectCreateTitle => 'New project';

  @override
  String projectTicketCount(int count) {
    return '$count ticket(s)';
  }

  @override
  String projectSprintCount(int count) {
    return '$count sprint(s)';
  }

  @override
  String get projectEditTitle => 'Edit project';

  @override
  String get projectEmpty => 'No projects yet.';

  @override
  String get projectCreateFirst => 'Create my first project';

  @override
  String get projectKey => 'Key';

  @override
  String get projectKeyLabel => 'Project key';

  @override
  String get projectKeyHint => '2–10 letters, e.g. DISC.';

  @override
  String get projectSubtitle => 'Organise tickets, backlog and sprints.';

  @override
  String get projectBacklog => 'Backlog';

  @override
  String get projectBacklogEmpty => 'The backlog is empty.';

  @override
  String get projectDeleteTitle => 'Delete project';

  @override
  String projectDeleteConfirm(String name) {
    return 'Delete \"$name\" and all its tickets?';
  }

  @override
  String get projectDeleteWarning =>
      'This action is irreversible. All tickets and data will be deleted.';

  @override
  String get projectStatuses => 'Project statuses';

  @override
  String get projectSettings => 'Settings';

  @override
  String get projectDangerZone => 'Danger zone';

  @override
  String get projectDefaults => 'Ticket defaults';

  @override
  String get projectDefaultsHint =>
      'These values are pre-filled when creating a ticket.';

  @override
  String get projectDefaultTicketType => 'Default type';

  @override
  String get projectDefaultAssignee => 'Default assignee';

  @override
  String get defaultassigneepolicyNone => 'None';

  @override
  String get defaultassigneepolicyCreator => 'Ticket creator';

  @override
  String get projectStatsTitle => 'Statistics';

  @override
  String get projectStatsBacklog => 'Backlog';

  @override
  String get projectStatsBacklogSub => 'unplanned tickets';

  @override
  String get projectStatsSprints => 'Sprints';

  @override
  String get projectStatsSprintsSub => 'iterations created';

  @override
  String get projectStatsWorkflow => 'Workflow';

  @override
  String get projectStatsWorkflowSub => 'ticket statuses';

  @override
  String get projectStatsNoSprints => 'No sprints in this project.';

  @override
  String get sprintActive => 'Active sprint';

  @override
  String get sprintPlanning => 'Planning';

  @override
  String get sprintStatuses => 'Statuses';

  @override
  String get sprintStart => 'Start';

  @override
  String get sprintClose => 'Close';

  @override
  String get sprintCreateTitle => 'Create sprint';

  @override
  String get sprintGoal => 'Goal';

  @override
  String get sprintNoActive => 'No active sprint';

  @override
  String get sprintNoActiveDesc =>
      'Start a planned sprint from the Planning tab. Only one sprint can be active at a time.';

  @override
  String get sprintViewKanban => 'Kanban';

  @override
  String get sprintViewList => 'List';

  @override
  String get sprintViewGrid => 'Grid';

  @override
  String sprintSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get sprintTicketHint => 'Check tickets then create a sprint.';

  @override
  String sprintTicketsMoved(int count) {
    return '$count tickets will be moved from the backlog.';
  }

  @override
  String get sprintStartHint => 'Start this sprint';

  @override
  String get sprintAlreadyActive => 'A sprint is already active';

  @override
  String get sprintAddTicket => 'Ticket';

  @override
  String get sprintAddTicketNew => 'New ticket';

  @override
  String get sprintAddToSprint => 'Add to sprint';

  @override
  String get sprintNoTickets => 'This sprint has no tickets.';

  @override
  String get sprintColumnEmpty => 'No tickets';

  @override
  String get sprintAddCard => 'Add';

  @override
  String get sprintCreateButton => 'Create sprint';

  @override
  String get sprintMoveToBacklog => 'Backlog';

  @override
  String sprintTicketCount(int count) {
    return '$count tickets';
  }

  @override
  String get sprintMySprints => 'My active sprints';

  @override
  String get sprintNoneActive =>
      'You are not participating in any active sprint.';

  @override
  String get sprintLabel => 'Sprint';

  @override
  String get sprintLoading => 'Loading sprint…';

  @override
  String get sprintNotFound => 'Sprint not found.';

  @override
  String get sprintTickets => 'tickets';

  @override
  String get cardCreateTitle => 'New card';

  @override
  String get ticketCreateTitle => 'New ticket';

  @override
  String get ticketNotFound => 'Ticket not found.';

  @override
  String get ticketOpenPage => 'Open page';

  @override
  String get ticketStoryPoints => 'Story points';

  @override
  String get ticketDueDate => 'Due date';

  @override
  String get ticketSprint => 'Sprint';

  @override
  String get ticketBacklogOption => '— Backlog —';

  @override
  String get ticketReporter => 'Created by';

  @override
  String get ticketAssignee => 'Assigned to';

  @override
  String get ticketNoAssignee => 'Unassigned';

  @override
  String get ticketComments => 'Comments';

  @override
  String get ticketCommentAdd => 'Add a comment…';

  @override
  String get ticketCommentEdit => 'Edit';

  @override
  String get ticketCommentDelete => 'Delete';

  @override
  String get ticketCommentSave => 'Save';

  @override
  String get ticketNoDescription => 'No description.';

  @override
  String get ticketOverdue => 'overdue';

  @override
  String get ticketDeleteTitle => 'Delete ticket';

  @override
  String ticketCreatedOn(String date) {
    return 'on $date';
  }

  @override
  String ticketUpdatedOn(String date) {
    return 'Updated on $date';
  }

  @override
  String ticketParent(String parent) {
    return 'Parent: $parent';
  }

  @override
  String get ticketParentLabel => 'Parent';

  @override
  String get statusCategory => 'Category';

  @override
  String get status => 'Status';

  @override
  String get created => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get statusColor => 'Color';

  @override
  String statusOrderLabel(int order) {
    return 'order $order';
  }

  @override
  String get statusCreateTitle => 'New status';

  @override
  String get statusEditTitle => 'Edit status';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMenu => 'Menu';

  @override
  String get pwaUpdateAvailable => 'A new version is available.';

  @override
  String get appTitle => 'Disciplan';

  @override
  String get pwaUpdate => 'Update';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Application language';

  @override
  String get settingsLanguageHint =>
      'Changing the language will reload the application.';

  @override
  String get settingsDisplayName => 'Display name';

  @override
  String get settingsDisplayNameHint =>
      'This name is displayed to other users across the application.';

  @override
  String get settingsDisplayNamePlaceholder => 'Your display name';

  @override
  String get settingsDisplayNameSaved => 'Name updated.';

  @override
  String get settingsDisplayNameError =>
      'Failed to update display name. Please try again.';

  @override
  String get settingsTabProfile => 'Profile';

  @override
  String get settingsTabDashboard => 'Dashboard';

  @override
  String get settingsDashboardHint =>
      'Reorder and toggle the visibility of your dashboard widgets.';

  @override
  String get settingsDashboardEmpty => 'No widgets configured.';

  @override
  String get settingsDashboardHide => 'Hide';

  @override
  String get settingsDashboardShow => 'Show';

  @override
  String get savedviewLabel => 'View';

  @override
  String get savedviewCreateTitle => 'New view';

  @override
  String get savedviewEditTitle => 'Edit view';

  @override
  String get savedviewFilters => 'Filters';

  @override
  String get savedviewAllProjects => 'All projects';

  @override
  String get savedviewAllTypes => 'All types';

  @override
  String get savedviewAllPriorities => 'All priorities';

  @override
  String get savedviewStatusCategory => 'Status category';

  @override
  String get savedviewAllCategories => 'All categories';

  @override
  String get savedviewOnlyAssignedToMe => 'Only assigned to me';

  @override
  String get savedviewOnlyReportedByMe => 'Only reported by me';

  @override
  String get savedviewCollapsedByDefault => 'Collapsed by default on dashboard';

  @override
  String get savedviewNameRequired => 'Name is required.';

  @override
  String get ticketHistory => 'Activity';

  @override
  String get ticketHistoryEmpty => 'No activity recorded yet.';

  @override
  String get historyCreated => 'created this ticket';

  @override
  String get historyTitleChanged => 'updated the title';

  @override
  String get historyDescriptionChanged => 'updated the description';

  @override
  String get historyStatusChanged => 'changed the status';

  @override
  String get historyTypeChanged => 'changed the type';

  @override
  String get historyPriorityChanged => 'changed the priority';

  @override
  String get historyAssigneeChanged => 'reassigned the ticket';

  @override
  String get historySprintChanged => 'changed the sprint';

  @override
  String get historyStoryPointsChanged => 'updated the story points';

  @override
  String get historyDueDateChanged => 'updated the due date';

  @override
  String get historyCommentAdded => 'added a comment';

  @override
  String get historyCommentDeleted => 'deleted a comment';

  @override
  String get historyAttachmentAdded => 'added an attachment';

  @override
  String get colCreateTitle => 'New column';

  @override
  String get colEditTitle => 'Rename column';

  @override
  String get colDeleteTitle => 'Delete column';

  @override
  String colDeleteConfirm(String name) {
    return 'Delete \"$name\" and all its cards?';
  }

  @override
  String get colRef => 'Ref.';

  @override
  String get colTitle => 'Title';

  @override
  String get colPriority => 'Priority';

  @override
  String get colStatus => 'Status';

  @override
  String get colSprint => 'Sprint';

  @override
  String get colDueDate => 'Due date';

  @override
  String get colProject => 'Project';

  @override
  String get colDueDateOptional => 'Due date (optional)';

  @override
  String homeWelcome(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get homeMyTickets => 'My tickets';

  @override
  String get homeActivity => 'Recent activity';

  @override
  String get homeNoTickets => 'No tickets assigned.';

  @override
  String get homeNoActivity => 'No recent activity.';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeActivityCreated => 'Ticket created';

  @override
  String get homeActivityUpdated => 'Ticket updated';

  @override
  String get homeActivityCommented => 'Comment added';

  @override
  String get homeActivityAttachment => 'Attachment added';

  @override
  String get homeConfigure => 'Configure';

  @override
  String get homeNoDashboardWidgets => 'No visible widgets.';

  @override
  String get homeConfigureDashboard => 'Configure dashboard';

  @override
  String get homeNoViewTickets => 'No tickets for this view.';

  @override
  String get myticketsTitle => 'My tickets';

  @override
  String get myticketsEmpty => 'No tickets assigned.';

  @override
  String get statuscategoryBacklog => 'Backlog';

  @override
  String get statuscategoryInProgress => 'In Progress';

  @override
  String get statuscategoryDone => 'Done';

  @override
  String get adminUsersTitle => 'User management';

  @override
  String get adminUsersHeading => 'Users';

  @override
  String get adminUsersPlaceholder => 'Account management. To be implemented.';

  @override
  String get adminUsersInvite => 'Invite';

  @override
  String get adminUsersCreate => 'Create user';

  @override
  String adminUsersHeadingCount(int count) {
    return 'Users ($count)';
  }

  @override
  String get adminUsersEmpty => 'No users yet.';

  @override
  String get adminUsersCreatedOn => 'Created on';

  @override
  String get adminUsersDeactivate => 'Deactivate';

  @override
  String get adminUsersActivate => 'Activate';

  @override
  String get adminUsersPromoteAdmin => 'Promote to Admin';

  @override
  String get adminUsersDemoteUser => 'Demote to User';

  @override
  String get adminUsersCreateTitle => 'Create user';

  @override
  String get adminUsersDisplayName => 'Display name';

  @override
  String get adminUsersRole => 'Role';

  @override
  String get adminUsersRoleUser => 'User';

  @override
  String get adminUsersRoleAdmin => 'Admin';

  @override
  String adminInvitationsHeading(int count) {
    return 'Active invitations ($count)';
  }

  @override
  String get adminInvitationsEmpty => 'No pending invitations.';

  @override
  String get adminInviteOpenLink => 'Open link';

  @override
  String get adminInviteExpiresOn => 'Expires on';

  @override
  String get adminInviteCopyLink => 'Copy link';

  @override
  String get adminInviteTitle => 'Invite a user';

  @override
  String get adminInviteDescription =>
      'An invitation link will be generated. Share it with the person you want to invite. The link expires after 7 days.';

  @override
  String get adminInviteEmailLabel => 'Email (optional)';

  @override
  String get adminInviteEmailHint =>
      'If provided, the invitation will be limited to this address.';

  @override
  String get adminInviteGenerate => 'Generate link';

  @override
  String get notfoundTitle => 'Not found';

  @override
  String get notfoundMessage =>
      'Sorry, the content you are looking for does not exist.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get labelTitle => 'Labels';

  @override
  String labelCount(int count) {
    return '$count label(s)';
  }

  @override
  String get labelCreateTitle => 'New label';

  @override
  String get labelEditTitle => 'Edit label';

  @override
  String get labelDeleteTitle => 'Delete label';

  @override
  String labelDeleteConfirm(String name) {
    return 'Delete «$name»? The label will be removed from all tickets and boards.';
  }

  @override
  String get labelEmpty =>
      'No labels yet. Create one to organize your tickets and boards.';

  @override
  String get labelCreateFirst => 'Create a label';

  @override
  String get labelName => 'Name';

  @override
  String get labelColor => 'Color';

  @override
  String get labelPreview => 'Preview';

  @override
  String get labelField => 'Labels';

  @override
  String get labelNoItems => 'No tickets or boards with this label yet.';

  @override
  String labelItemCount(int tickets, int boards) {
    return '$tickets ticket(s) · $boards board(s)';
  }

  @override
  String get membersTitle => 'Members';

  @override
  String get membersAdd => 'Add member';

  @override
  String get membersNone => 'No members yet.';

  @override
  String get membersSelectUser => 'Select a user';

  @override
  String get membersRole => 'Role';

  @override
  String get membersChangeRole => 'Change role';

  @override
  String get membersRemove => 'Remove member';

  @override
  String membersRemoveConfirm(String name) {
    return 'Remove $name from this resource?';
  }

  @override
  String get homeActiveSprints => 'Active sprints';

  @override
  String get homeOverdue => 'Overdue';

  @override
  String get homeInProgress => 'In progress';

  @override
  String get setupSubtitle => 'Initial setup';

  @override
  String get setupNoAccount =>
      'No account exists yet. Create the first admin account.';

  @override
  String get setupPasswordHint =>
      'At least 8 characters, with uppercase, lowercase and a number.';

  @override
  String get setupCreating => 'Creating…';

  @override
  String get setupCreateAdmin => 'Create admin account';

  @override
  String get invitationSubtitle => 'Create your account';

  @override
  String get invitationInvalid => 'Invalid or expired invitation';

  @override
  String get invitationInvalidDesc =>
      'This invitation link is no longer valid.';

  @override
  String get invitationBackToLogin => 'Back to sign in';

  @override
  String get invitationValid =>
      'Valid invitation. Fill in your details to create your account.';

  @override
  String get invitationCreateAccount => 'Create my account';

  @override
  String get settingsTabAppearance => 'Appearance';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeCustom => 'Custom theme';

  @override
  String get settingsThemeActive => 'Active';

  @override
  String get settingsThemeActivate => 'Enable';

  @override
  String get settingsStatsShow => 'Show quick stats';

  @override
  String get settingsStatsDescription =>
      'Assigned tickets, active sprints, overdue and in-progress.';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeToDark => 'Switch to dark mode';

  @override
  String get settingsThemeToLight => 'Switch to light mode';

  @override
  String get cardCreatedOn => 'Created on';

  @override
  String get cardUpdatedOn => 'Updated on';

  @override
  String get cardCreatedBy => 'Created by:';

  @override
  String get cardAssignedTo => 'Assigned to:';

  @override
  String get cardNoComments => 'No comments yet.';

  @override
  String get cardEdited => '(edited)';

  @override
  String get cardCommentSend => 'Send';

  @override
  String get cardEditTitle => 'Edit card';

  @override
  String get cardDeleteTitle => 'Delete card';

  @override
  String cardDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get cardCommentPlaceholder => 'Add a comment…';

  @override
  String get cardNoDescription => 'No description.';

  @override
  String get cardOverdue => '— overdue';

  @override
  String get labelpickerRemove => 'Remove';

  @override
  String get labelpickerFilter => 'Filter…';

  @override
  String get labelpickerEmpty => 'No labels found.';

  @override
  String get labelTickets => 'Tickets';

  @override
  String get adminActivate => 'Activate';

  @override
  String get adminPromoteAdmin => 'Promote to Admin';

  @override
  String get attachmentSectionLabel => 'Attachments';

  @override
  String get attachmentAdd => 'Add';

  @override
  String get attachmentAddFiles => 'Add files';

  @override
  String get attachmentAttach => 'Attach';

  @override
  String get attachmentAttachFiles => 'Attach files';

  @override
  String get attachmentUploading => 'Uploading…';

  @override
  String get attachmentEmpty => 'No attachments — click Add to attach files';

  @override
  String get attachmentPreview => 'Preview';

  @override
  String get attachmentOpenInTab => 'Open in tab';

  @override
  String get attachmentOpenInNewTab => 'Open in new tab';

  @override
  String get attachmentNewTab => 'New tab';

  @override
  String get attachmentDownload => 'Download';

  @override
  String get attachmentDownloadFile => 'Download file';

  @override
  String get attachmentNoPreview => 'Preview not available for this file type.';

  @override
  String get attachmentLoadingPreview => 'Loading…';

  @override
  String get attachmentRetry => 'Retry';

  @override
  String attachmentErrorUpload(String error) {
    return 'Upload error: $error';
  }

  @override
  String attachmentErrorDownload(String error) {
    return 'Download error: $error';
  }

  @override
  String attachmentErrorOpen(String error) {
    return 'Error opening file: $error';
  }

  @override
  String attachmentErrorDelete(String error) {
    return 'Delete error: $error';
  }

  @override
  String attachmentErrorLoad(String error) {
    return 'Failed to load file: $error';
  }

  @override
  String get ticketCommentSubmit => 'Comment';

  @override
  String get authHeadline => 'From an idea to a job well done.';

  @override
  String get authIntroduction =>
      'A space to organize your projects, move your team forward and focus on what matters.';

  @override
  String get authDisplayNameHint => 'e.g. Marie Curie';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authHomelabServer => 'Homelab server';

  @override
  String get authInvitationSubtitle =>
      'Complete your registration with your invitation token.';

  @override
  String get authInvitationTokenHint => 'e.g. inv_8f93ab...';

  @override
  String get authInvitationTokenLabel => 'Invitation token';

  @override
  String get authJoinTeam => 'Join a team';

  @override
  String get authLoginTagline =>
      'Drive your sprints and tickets at high velocity.';

  @override
  String get authLoginTitle => 'Sign in to Disciplan';

  @override
  String get authReceivedInvitation => 'Received an invitation?';

  @override
  String get authServerTest => 'Test';

  @override
  String get authServerTestFailed => 'Failed to connect to the Homelab server.';

  @override
  String get authServerTestSuccess => 'Connection established successfully.';

  @override
  String get authSetupDisplayNameHint => 'e.g. Alexandre Gailloty';

  @override
  String get authSetupFillAllFields => 'Please fill in all fields.';

  @override
  String get authSetupIntro =>
      'Initialize your Homelab instance by creating the root administrator account.';

  @override
  String get authSetupPasswordLabel => 'Password (min. 8 characters)';

  @override
  String get authSetupPasswordTooShort =>
      'The password must be at least 8 characters long.';

  @override
  String get authSetupTitle => 'First launch';

  @override
  String get authValidateInvitation => 'Accept invitation';

  @override
  String get calCopyIcalUrl => 'Copy iCal URL';

  @override
  String get calFilterAll => 'View all';

  @override
  String get calFilterSprints => 'Sprints';

  @override
  String get calGenerateToken => 'Generate token';

  @override
  String get calIcalNoFeed =>
      'No active feed. Generate your private token to sync your calendar.';

  @override
  String get calIcalSyncTitle => 'iCal / external calendar sync';

  @override
  String get calIcalUrlCopied => 'iCal feed URL copied';

  @override
  String get calNoMilestones =>
      'No milestones or dated tickets for this filter.';

  @override
  String get calRegenerateToken => 'Regenerate token';

  @override
  String get calSprintMilestone => 'Cycle milestone';

  @override
  String get calTeamCalendarSubtitle =>
      'Sprint milestones, ticket due dates and iCal sync';

  @override
  String get calTeamCalendarTitle => 'Team Calendar';

  @override
  String calTokenError(String error) {
    return 'Token error: $error';
  }

  @override
  String get cmdCategoryActions => 'Quick actions';

  @override
  String get cmdCategoryNavigation => 'Navigation';

  @override
  String get cmdCategoryTickets => 'Tickets';

  @override
  String get cmdCreateTask => 'Create a task';

  @override
  String get cmdEscapeKey => 'Esc';

  @override
  String get cmdFooterBrand => 'Disciplan Neo-Linear';

  @override
  String get cmdNavCalendar => 'Team calendar';

  @override
  String get cmdNavCycles => 'Cycles & Sprints';

  @override
  String get cmdNavSettings => 'Settings & Administration';

  @override
  String get cmdNavSprintKanban => 'Sprint Kanban board';

  @override
  String get cmdNavigate => 'Navigate';

  @override
  String cmdNoResults(String query) {
    return 'No results matching “$query”';
  }

  @override
  String get cmdOpen => 'Open';

  @override
  String get cmdSearchHint => 'Search for a ticket, an action, or navigate...';

  @override
  String get errorBadRequest => 'Invalid request.';

  @override
  String get errorConflict =>
      'A conflict occurred (item already exists or was modified).';

  @override
  String get errorForbidden => 'Access denied for this operation.';

  @override
  String get errorGenericNetwork => 'A network error occurred.';

  @override
  String get errorNetwork =>
      'Unable to reach the server. Check your connection and the server URL.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorServer => 'An internal error occurred on the server.';

  @override
  String get errorUnauthorized => 'Invalid credentials or expired session.';

  @override
  String kanbanBoardLoadError(String error) {
    return 'Failed to load the board: $error';
  }

  @override
  String get kanbanDropTicketHere => 'Drag a task here';

  @override
  String get kanbanDueToday => 'Today';

  @override
  String get kanbanDueTomorrow => 'Tomorrow';

  @override
  String get kanbanDueYesterday => 'Yesterday';

  @override
  String kanbanErrorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get kanbanFilterCardsHint => 'Filter cards...';

  @override
  String get kanbanHideMetrics => 'Hide header';

  @override
  String get kanbanMoveToStatus => 'Move to...';

  @override
  String get kanbanNoStatuses => 'No statuses defined for this project.';

  @override
  String get kanbanNoStatusesAvailable => 'No statuses available.';

  @override
  String kanbanNoTicketsInStatus(String status) {
    return 'No tasks in \"$status\"';
  }

  @override
  String kanbanOpenSprintBoard(String name) {
    return 'Open the Kanban of \"$name\"';
  }

  @override
  String get kanbanPriorityHighFilter => 'High priority';

  @override
  String get kanbanSelectProject =>
      'Select a project to display its Kanban board.';

  @override
  String get kanbanShowMetrics => 'Show metrics';

  @override
  String kanbanStartNamed(String name) {
    return 'Start \"$name\"';
  }

  @override
  String get kanbanSwitchSprintTooltip => 'Switch the displayed sprint';

  @override
  String get kanbanViewBacklog => 'View backlog';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get projActiveProjects => 'Active projects';

  @override
  String projActiveSpace(String key, String name) {
    return 'Active space: $key — $name';
  }

  @override
  String get projActiveSpaceBadge => 'Active space';

  @override
  String get projAllMyProjects => 'All my projects';

  @override
  String get projCardDescriptionFallback =>
      'Encapsulated project space — click to access its tickets and cycles.';

  @override
  String get projCreateNew => 'Create a project';

  @override
  String get projCreateSubmit => 'Create project';

  @override
  String get projCreateSubtitle =>
      'Set up a collaborative workspace to align your sprints and tickets.';

  @override
  String get projCycles => 'Cycles';

  @override
  String get projDashboardGeneral => 'General dashboard';

  @override
  String get projDescriptionHint =>
      'Summarize the strategic goals and scope...';

  @override
  String get projDescriptionLabel => 'Description & vision';

  @override
  String get projEmptyHint =>
      'Create your first project to organize your tickets and sprints.';

  @override
  String get projExplorerSubtitle =>
      'Select or create a project to display its list view and backlog.';

  @override
  String get projExplorerTitle => 'Project Explorer';

  @override
  String get projFilterMember => 'Team member';

  @override
  String get projInitiationAgile => 'Agile initiation';

  @override
  String get projKeyAuto => 'Auto';

  @override
  String projLoadError(String error) {
    return 'Error: $error';
  }

  @override
  String get projMember => 'Project member';

  @override
  String get projNameHint => 'e.g. Brand Campaign 2025';

  @override
  String get projNameLabel => 'Project name *';

  @override
  String get projNameRequired => 'Please enter the project name.';

  @override
  String get projNoMatch => 'No project matches this filter.';

  @override
  String get projOwner => 'Owner';

  @override
  String get projPortfolio => 'Project portfolio';

  @override
  String get projSearchHint => 'Search for a project (name, key)...';

  @override
  String get projSelectSubtitle =>
      'Select a project to encapsulate your workspace, or jump straight to its Backlog, Kanban or Cycles.';

  @override
  String get projSprintsCycles => 'Sprints & Cycles';

  @override
  String get projTotalTickets => 'Total tickets';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleGuest => 'Guest';

  @override
  String get roleMember => 'Member';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get settingsActive => 'Active';

  @override
  String get settingsAdminInvitationsSubtitle =>
      'Generate single-use invitation links to onboard new members';

  @override
  String get settingsAdminInvitationsTitle =>
      'Administration — Invitations (7 days)';

  @override
  String get settingsAdminUsersSubtitle =>
      'Activate, deactivate or change the roles of the instance users';

  @override
  String get settingsAdminUsersTitle => 'Administration — Account Management';

  @override
  String get settingsAll => 'All';

  @override
  String get settingsApply => 'Apply';

  @override
  String get settingsCopyToken => 'Copy token';

  @override
  String get settingsDefaultUser => 'User';

  @override
  String get settingsGenerateInviteLink => 'Generate a link (7d)';

  @override
  String get settingsHeaderSubtitle =>
      'User preferences, Homelab configuration and access management';

  @override
  String get settingsInactive => 'Inactive';

  @override
  String settingsInvitationsError(String error) {
    return 'Error loading invitations: $error';
  }

  @override
  String get settingsInviteEmailHint => 'name@company.com';

  @override
  String get settingsInviteEmailInvalid =>
      'Please enter a valid email address.';

  @override
  String settingsInviteError(String error) {
    return 'Error while creating the invitation: $error';
  }

  @override
  String get settingsInviteExpired => 'Expired';

  @override
  String settingsInviteGenerated(String email) {
    return 'Invitation generated for $email!';
  }

  @override
  String get settingsInviteLinkCopied =>
      'Invitation link copied to the clipboard';

  @override
  String get settingsInviteUsed => 'Already used';

  @override
  String get settingsInviteValid => 'Valid';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsNotConnected => 'Not signed in';

  @override
  String get settingsPendingInvitations => 'Pending or recent invitations';

  @override
  String get settingsPin => 'Pin';

  @override
  String get settingsProfileSubtitle =>
      'Manage your Disciplan account information';

  @override
  String get settingsProfileTitle => 'Profile & Account';

  @override
  String settingsSavedViewSummary(String project, String type) {
    return 'Project: $project • Type: $type';
  }

  @override
  String get settingsSavedViewsEmpty =>
      'No saved views yet. You can create one from the List View.';

  @override
  String settingsSavedViewsError(String error) {
    return 'Unable to load views: $error';
  }

  @override
  String get settingsSavedViewsSubtitle =>
      'Manage your filters and custom views pinned to the sidebar';

  @override
  String get settingsSavedViewsTitle => 'Saved Views';

  @override
  String get settingsScaleComfort => 'Comfortable (110%)';

  @override
  String get settingsScaleCompact => 'Compact (90%)';

  @override
  String get settingsScaleDecrease => 'Decrease (-5%)';

  @override
  String get settingsScaleFactor => 'Scale factor';

  @override
  String get settingsScaleHint =>
      'Tip: you can enter any percentage between 50% and 200%, or adjust the scale factor from the top bar.';

  @override
  String get settingsScaleIncrease => 'Increase (+5%)';

  @override
  String get settingsScaleLarge => 'Large screen (120%)';

  @override
  String get settingsScaleReset => 'Reset (100%)';

  @override
  String get settingsScaleStandard => 'Standard (100%)';

  @override
  String get settingsScalingSubtitle =>
      'Adjust the size of fonts and visual elements to your screen resolution';

  @override
  String get settingsScalingTitle => 'Display & Scaling (UI Scaling)';

  @override
  String get settingsServerHint =>
      'HTTP requests and the iCal subscription rely on this base URL.';

  @override
  String get settingsServerSubtitle =>
      'Address of your Disciplan instance on the local or remote network';

  @override
  String get settingsServerTitle => 'Homelab server';

  @override
  String get settingsServerUnreachable => 'Unable to reach the server';

  @override
  String get settingsServerUrlUpdated => 'Homelab server URL updated';

  @override
  String get settingsSessionSubtitle =>
      'Signs this device out of your Disciplan instance';

  @override
  String get settingsSessionTitle => 'Active session';

  @override
  String get settingsTokenCopied => 'Invitation token copied';

  @override
  String get settingsUnpin => 'Unpin';

  @override
  String settingsUpdateError(String error) {
    return 'Error while updating: $error';
  }

  @override
  String settingsUsersError(String error) {
    return 'Error loading users: $error';
  }

  @override
  String get settingsYou => '(you)';

  @override
  String shellActiveSprintName(String name) {
    return 'Active sprint: $name';
  }

  @override
  String shellActivityError(String error) {
    return 'Error: $error';
  }

  @override
  String get shellAllProjects => 'All my projects';

  @override
  String get shellApply => 'Apply';

  @override
  String get shellChangeProject => 'Change project';

  @override
  String get shellCollapseSidebar => 'Collapse the sidebar (⌘B)';

  @override
  String get shellCrumbBacklog => 'Project backlog';

  @override
  String get shellCrumbBacklogList => 'Backlog & List view';

  @override
  String get shellCrumbCycles => 'Cycles & Sprints';

  @override
  String get shellCrumbMyTasks => 'My dashboard & tasks';

  @override
  String get shellCrumbWorkspace => 'Workspace';

  @override
  String shellDisplaySize(int percent) {
    return 'Display size ($percent%)';
  }

  @override
  String get shellMobileCycles => 'Cycles';

  @override
  String get shellMobileBacklog => 'Backlog';

  @override
  String get shellMobileDashboard => 'Dashboard';

  @override
  String get shellMobileProjects => 'My projects';

  @override
  String get shellMobileTasks => 'Tasks';

  @override
  String get shellNewTask => 'New task';

  @override
  String get shellPersonalSpace => 'Personal space';

  @override
  String get shellSidebarDashboardSubtitle => 'Projects and my tickets';

  @override
  String get shellTooltipDashboard => 'Dashboard';

  @override
  String get shellProjectPlan => 'Project plan';

  @override
  String get shellProjectViews => 'Project views';

  @override
  String get shellScaleComfort => 'Comfort (110%)';

  @override
  String get shellScaleCompact => 'Compact (90%)';

  @override
  String shellScaleCustom(int percent) {
    return 'Custom factor ($percent%)...';
  }

  @override
  String get shellScaleCustomHint =>
      'Choose a factor between 50% and 200% (or use the 90%, 100%, 110%, 120% presets).';

  @override
  String get shellScaleCustomTitle => 'Custom scale factor';

  @override
  String get shellScaleLarge => 'Large screen (120%)';

  @override
  String get shellScaleReset => '100% (Default)';

  @override
  String get shellScaleStandard => 'Standard (100%)';

  @override
  String get shellSearchPlaceholder =>
      'Search for a task, go to Kanban, Backlog...';

  @override
  String get shellSelectProject => 'Select a project';

  @override
  String get shellSidebarAdmin => 'Administration';

  @override
  String get shellSidebarCalendar => 'Calendar & milestones';

  @override
  String get shellSidebarCalendarSubtitle => 'Deadlines & iCal feeds';

  @override
  String get shellSidebarCurrentSprints => 'Current sprints';

  @override
  String get shellSidebarCyclesSubtitle => 'Cycles, velocity & roadmap';

  @override
  String get shellSidebarKanban => 'Kanban board';

  @override
  String get shellSidebarListSubtitle => 'Backlog & project tickets';

  @override
  String get shellSidebarListView => 'List view';

  @override
  String get shellSidebarMyTasks => 'Dashboard & My Tasks';

  @override
  String get shellSidebarMyTasksSubtitle => 'Global view & assigned tickets';

  @override
  String get shellSidebarPlanning => 'Planning & Cycles';

  @override
  String get shellSidebarPortfolioSubtitle => 'Portfolio & project spaces';

  @override
  String get shellSidebarTeamSettings => 'Team settings';

  @override
  String get shellSprintCapacity => 'Sprint capacity';

  @override
  String get shellSprintNoneActive => 'None active';

  @override
  String get shellSprintProgress => 'Sprint progress';

  @override
  String get shellSwitchProject => 'Switch active project';

  @override
  String get shellToggleSidebar => 'Toggle the sidebar (⌘B)';

  @override
  String get shellTooltipBacklog => 'Backlog & project tickets';

  @override
  String get shellTooltipCalendar => 'Team calendar';

  @override
  String get shellTooltipCycles => 'Cycles & roadmap';

  @override
  String get shellTooltipKanban => 'Sprints Kanban board';

  @override
  String get shellTooltipMyTasks => 'Dashboard & My Tasks';

  @override
  String get shellTooltipSearch => 'Global search (⌘K)';

  @override
  String get shellTooltipSettings => 'Settings (⌘,)';

  @override
  String get sprintBacklogTicketsTitle => 'Backlog tickets to include';

  @override
  String get sprintCadenceFlash => 'Flash (7d)';

  @override
  String get sprintCadenceOneMonth => '1 mo.';

  @override
  String get sprintCadenceOneWeek => '1 wk.';

  @override
  String get sprintCadenceOptimal => 'Optimal (14d)';

  @override
  String get sprintCadenceProject => 'Project (30d)';

  @override
  String get sprintCadenceTitle => 'Cadence & Frequency';

  @override
  String get sprintCadenceTwoWeeks => '2 wk.';

  @override
  String sprintCadenceWeeks(int weeks, int days) {
    return '$weeks week(s) (${days}d)';
  }

  @override
  String get sprintClosedCyclesSection => 'Closed cycles & history';

  @override
  String sprintClosedTicketsProgress(int closed, int total) {
    return '$closed/$total done';
  }

  @override
  String sprintContributorsCount(int count) {
    return '$count contributors';
  }

  @override
  String get sprintCreateCycle => 'Create a cycle';

  @override
  String get sprintCreateModalTitle => 'Create and schedule a cycle';

  @override
  String get sprintCreatedSuccess => 'Sprint created successfully!';

  @override
  String sprintCyclesSubtitle(String name) {
    return 'Time planning and velocity metrics for project $name.';
  }

  @override
  String get sprintCyclesTitle => 'Cycles & Sprints';

  @override
  String get sprintDatesNotDefined => 'Dates not defined';

  @override
  String get sprintDatesUndefined => 'Undefined dates';

  @override
  String sprintDaysRemaining(int count) {
    return 'D-$count remaining';
  }

  @override
  String sprintDaysRemainingBadge(int count) {
    return 'D-$count';
  }

  @override
  String sprintAutoName(int number) {
    return 'Sprint $number';
  }

  @override
  String get sprintEndDate => 'End date';

  @override
  String get sprintFinish => 'Finish the sprint';

  @override
  String get sprintGoalHint =>
      'e.g. Finalize the graphic redesign and validate the brand campaign...';

  @override
  String get sprintGoalLabel => 'Main cycle objective (Sprint Goal)';

  @override
  String sprintLoadError(String error) {
    return 'Loading error: $error';
  }

  @override
  String get sprintNameHint => 'e.g. Sprint 5 — Production & Launch';

  @override
  String get sprintNameLabel => 'Cycle / sprint name';

  @override
  String get sprintNameRequired => 'Please enter a sprint name.';

  @override
  String get sprintNewTask => 'New task';

  @override
  String get sprintNoActiveCycleDesc =>
      'Start a planned cycle, preview its Kanban, or create a new sprint.';

  @override
  String get sprintNoBacklogTickets => 'No tickets available in the backlog.';

  @override
  String get sprintNoClosedCycles => 'No closed cycles.';

  @override
  String get sprintNoPlannedCycles => 'No planned cycles yet.';

  @override
  String sprintPercentCompleted(int percent) {
    return '$percent% complete';
  }

  @override
  String get sprintPlannedCyclesSection => 'Planned cycles';

  @override
  String sprintPointsShort(int points) {
    return '$points pts';
  }

  @override
  String sprintRemainingTickets(int count) {
    return '$count remaining';
  }

  @override
  String get sprintRemainingTicketsSub => 'in progress / to do';

  @override
  String get sprintSelectProject => 'Select a project to view its cycles.';

  @override
  String sprintSelectedTicketsSummary(int count, int points) {
    return '$count task(s) · $points pts';
  }

  @override
  String get sprintStartCycle => 'Start the cycle';

  @override
  String get sprintStartDate => 'Start date';

  @override
  String get sprintStartImmediately => 'Start this sprint immediately';

  @override
  String get sprintStartImmediatelyHint =>
      'The sprint will become Active as soon as it is created.';

  @override
  String get sprintStatusActive => 'Active';

  @override
  String get sprintStatusClosed => 'Closed';

  @override
  String get sprintStatusPlanned => 'Planned';

  @override
  String get sprintSuggested => 'Suggested:';

  @override
  String get sprintSuggestion1 => 'Capsule Q3 Deployment';

  @override
  String get sprintSuggestion2 => 'Optimizations & QA';

  @override
  String sprintTaskCount(int count) {
    return '$count task(s)';
  }

  @override
  String get sprintTeamBurndown => 'Team burn-down';

  @override
  String get ticketsActiveCycle => 'Active cycle';

  @override
  String ticketsActiveSprintName(String name) {
    return 'Active sprint: $name';
  }

  @override
  String get ticketsAddFirstQuickTask => 'Add your first quick task below.';

  @override
  String get ticketsAddNoteHint => 'Add a note...';

  @override
  String get ticketsAddSubtaskHint => '+ Add a subtask...';

  @override
  String get ticketsAssign => 'Assign';

  @override
  String get ticketsAssignMember => 'Assign to a project member';

  @override
  String get ticketsAssignSelectionToSprint => 'Assign selection to a sprint';

  @override
  String get ticketsAssignTo => 'Assign to';

  @override
  String get ticketsAssignToSprint => 'Assign to a sprint';

  @override
  String ticketsAssignToSprintFailed(String detail) {
    return 'Error while assigning to sprint: $detail';
  }

  @override
  String get ticketsAssignedLabel => 'ASSIGNED';

  @override
  String get ticketsAssigneeLabel => 'Assignee';

  @override
  String get ticketsBacklogHeaderDesc =>
      'Tickets outside a sprint awaiting planning. Assign them to a sprint or change their priority.';

  @override
  String get ticketsBacklogListView => 'Backlog & List view';

  @override
  String get ticketsBacklogNoSprint => 'Backlog (no sprint)';

  @override
  String get ticketsBacklogPrioritize => 'List and prioritize the backlog';

  @override
  String get ticketsBacklogProjectBadge => 'PROJECT BACKLOG';

  @override
  String get ticketsBacklogScopeChip => 'Backlog (no sprint)';

  @override
  String get ticketsBacklogSectionSubtitle =>
      'Backlog tickets ready to be planned or started';

  @override
  String ticketsBacklogToPlan(int count) {
    return '$count ticket(s) outside a sprint to plan';
  }

  @override
  String get ticketsChangeStatus => 'Change status';

  @override
  String ticketsCommentAddFailed(String detail) {
    return 'Error adding comment: $detail';
  }

  @override
  String get ticketsCommentPosted => 'Comment posted';

  @override
  String get ticketsCopyLink => 'Copy link';

  @override
  String get ticketsCreateAnother => 'Create another task';

  @override
  String get ticketsCreateAnotherNext => 'Create another task next';

  @override
  String ticketsCreateFailed(String detail) {
    return 'Error while creating: $detail';
  }

  @override
  String get ticketsCreateTask => 'Create task';

  @override
  String get ticketsCreateTicket => 'Create a ticket';

  @override
  String get ticketsCycleSprint => 'CYCLE / SPRINT';

  @override
  String get ticketsCycles => 'Cycles';

  @override
  String ticketsCyclesOf(String name) {
    return 'Cycles of $name';
  }

  @override
  String get ticketsCyclesSprints => 'Cycles & Sprints';

  @override
  String get ticketsDescriptionHint =>
      'Add a detailed description (Markdown supported)...';

  @override
  String get ticketsDoneSubtitle => 'Tickets delivered and validated';

  @override
  String get ticketsEditPriority => 'Edit priority';

  @override
  String get ticketsEditableAnytime => 'Editable at any time';

  @override
  String get ticketsEnterKey => 'Enter';

  @override
  String ticketsErrorDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String ticketsFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String get ticketsFilterByPriority => 'Filter by priority';

  @override
  String ticketsFilterDone(int count) {
    return 'Done ($count)';
  }

  @override
  String ticketsFilterInProgress(int count) {
    return 'In progress ($count)';
  }

  @override
  String get ticketsFilterTicketsHint =>
      'Filter tickets (title, ref, assignee)...';

  @override
  String ticketsFilterTodo(int count) {
    return 'To do ($count)';
  }

  @override
  String ticketsFilterUrgent(int count) {
    return 'Urgent ($count)';
  }

  @override
  String ticketsFocusInProgress(int count) {
    return 'FOCUS — YOUR TICKETS IN PROGRESS ($count)';
  }

  @override
  String get ticketsFullPortfolio => 'Full portfolio';

  @override
  String get ticketsHistoryTab => 'History';

  @override
  String ticketsInProgressAttention(int count) {
    return '$count task(s) in progress require your attention.';
  }

  @override
  String get ticketsInProgressSubtitle => 'Tickets actively being worked on';

  @override
  String get ticketsIsolateInProgress => 'Isolate In progress →';

  @override
  String get ticketsKanbanBoard => 'Kanban board';

  @override
  String get ticketsKeepOpenHint => 'Keep the modal open to continue';

  @override
  String ticketsLoadError(String detail) {
    return 'Loading error: $detail';
  }

  @override
  String get ticketsLoadTicketFailed => 'Unable to load the ticket';

  @override
  String get ticketsManageSprints => 'Manage sprints';

  @override
  String get ticketsMyProjectsSpaces => 'MY PROJECTS — ENCAPSULATED SPACES';

  @override
  String get ticketsNewTask => 'New task';

  @override
  String get ticketsNoAttachment => 'No attachment.';

  @override
  String get ticketsNoExchange => 'No discussion for now.';

  @override
  String get ticketsNoLabel => 'No label attached';

  @override
  String get ticketsNoSubtask => 'No subtask for this ticket.';

  @override
  String get ticketsNoTaskInSection => 'No task in this section.';

  @override
  String get ticketsNoTaskMatchFilter => 'No task matches this filter.';

  @override
  String get ticketsNoTicketBacklog => 'No tickets in the backlog';

  @override
  String get ticketsNoTicketMatchSearch => 'No ticket matches your search.';

  @override
  String get ticketsNoTicketSprint => 'No tickets in this sprint';

  @override
  String get ticketsNone => 'None';

  @override
  String ticketsNotFoundRef(String ref) {
    return 'Ticket not found: $ref';
  }

  @override
  String get ticketsNotSet => 'Not set';

  @override
  String get ticketsNotesHint => 'Add notes, context or acceptance criteria...';

  @override
  String ticketsOtherAssignedTasks(int count) {
    return 'OTHER ASSIGNED TASKS ($count)';
  }

  @override
  String get ticketsOwner => 'Owner';

  @override
  String ticketsPercentDone(int percent) {
    return '$percent% completed';
  }

  @override
  String get ticketsPersonalDashboardBadge => 'PERSONAL DASHBOARD';

  @override
  String get ticketsPinToHome => 'Pin to home / sidebar';

  @override
  String ticketsPlanInSprint(int count) {
    return 'Plan $count ticket(s) into a sprint';
  }

  @override
  String ticketsPlannedInSprint(int count, String name) {
    return '$count ticket(s) planned in \"$name\".';
  }

  @override
  String get ticketsPriorityAll => 'Priority: All';

  @override
  String ticketsPrioritySelected(String priority) {
    return 'Priority: $priority';
  }

  @override
  String get ticketsProjectBacklogTitle => 'Project backlog';

  @override
  String ticketsProjectTileSummary(int tickets, int sprints, String role) {
    return '$tickets tickets • $sprints sprints • $role';
  }

  @override
  String get ticketsQuickAddHint => '+ Add a quick task... (Enter)';

  @override
  String ticketsQuickAddInSection(String section) {
    return 'Add a quick task in \"$section\"...';
  }

  @override
  String get ticketsQuickMetadata => 'QUICK METADATA';

  @override
  String get ticketsRecentExchanges => 'Recent discussions';

  @override
  String get ticketsRefCopied => 'Reference copied to clipboard';

  @override
  String get ticketsResetFilters => 'Reset filters';

  @override
  String get ticketsSaveAsViewTitle => 'Save as saved view';

  @override
  String get ticketsSaveView => 'Save view';

  @override
  String get ticketsSavedViewActivated => 'Saved view activated.';

  @override
  String get ticketsSavedViews => 'Saved views';

  @override
  String get ticketsSelectProject => 'Select';

  @override
  String ticketsSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String ticketsSprintChangeFailed(String detail) {
    return 'Sprint change error: $detail';
  }

  @override
  String get ticketsSprintCycle => 'Sprint / Cycle';

  @override
  String get ticketsSprintHeaderDesc =>
      'Detailed list of tickets assigned to this cycle.';

  @override
  String get ticketsSprintListBadge => 'SPRINT LIST';

  @override
  String get ticketsSprintPlanHint => 'Plan, start or close a sprint';

  @override
  String get ticketsSprintTicketsTitle => 'Sprint tickets';

  @override
  String get ticketsSprintTodoSubtitle => 'Sprint tickets waiting to start';

  @override
  String ticketsStatusChangeFailed(String detail) {
    return 'Status change error: $detail';
  }

  @override
  String ticketsSubtaskAddFailed(String detail) {
    return 'Error adding subtask: $detail';
  }

  @override
  String ticketsSubtaskUpdateFailed(String detail) {
    return 'Error updating subtask: $detail';
  }

  @override
  String get ticketsSubtasks => 'Subtasks';

  @override
  String get ticketsSubtasksDeliverables => 'Subtasks & deliverables';

  @override
  String get ticketsTaskCreated => 'Task created successfully';

  @override
  String get ticketsTaskCreatedNext =>
      'Task created! You can enter another one.';

  @override
  String get ticketsTaskTitleActionHint => 'Task title or action...';

  @override
  String get ticketsTaskTitleHint => 'Task title...';

  @override
  String get ticketsTicketDetailTitle => 'Ticket detail';

  @override
  String get ticketsTicketLinkCopied => 'Ticket link copied';

  @override
  String get ticketsTicketLoadError => 'Ticket loading error';

  @override
  String get ticketsTitleRequired => 'Please enter a title.';

  @override
  String get ticketsToday => 'Today';

  @override
  String get ticketsTodo => 'To do';

  @override
  String get ticketsTodoBacklog => 'To do / Backlog';

  @override
  String get ticketsTomorrow => 'Tomorrow';

  @override
  String get ticketsUnassignedClick => 'Unassigned (click)';

  @override
  String ticketsUpdateFailed(String detail) {
    return 'Update error: $detail';
  }

  @override
  String get ticketsUrgent => 'Urgent';

  @override
  String get ticketsViewDescriptionHint => 'Automatic filter applied...';

  @override
  String get ticketsViewDescriptionLabel => 'Description (optional)';

  @override
  String get ticketsViewNameHint => 'e.g. Urgent tasks, sprint review...';

  @override
  String get ticketsViewNameLabel => 'View name';

  @override
  String get ticketsViewNameRequired => 'Please enter a name for the view.';

  @override
  String get ticketsViewSaved => 'View saved successfully!';

  @override
  String get ticketsViewSprintColumns => 'View the sprint columns';

  @override
  String get ticketsYesterday => 'Yesterday';

  @override
  String get tabCloseTooltip => 'Close tab';

  @override
  String get workspaceWelcomeTitle => 'Welcome to Disciplan';

  @override
  String get workspaceWelcomeHint =>
      'Open the dashboard or browse your projects to get started.';

  @override
  String get workspaceOpenDashboard => 'Open the dashboard';

  @override
  String get workspaceBrowseProjects => 'Browse projects';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeEpic => 'Epic';

  @override
  String get typeStory => 'Story';

  @override
  String get typeSubtask => 'Subtask';

  @override
  String get typeTask => 'Task';

  @override
  String get landingHeroTitle => 'Project management, clear and fast.';

  @override
  String get landingHeroSubtitle =>
      'Disciplan brings your projects, sprints, tickets and calendars together in a self-hostable app, available on web, mobile and desktop.';

  @override
  String get landingCtaLogin => 'Sign in';

  @override
  String get landingCtaSubtitle => 'Log in to access your projects.';

  @override
  String get landingOpenApp => 'Open the app';

  @override
  String get landingOpenAppSubtitle => 'You are already signed in.';

  @override
  String get landingFeatureProjectsTitle => 'Projects & tickets';

  @override
  String get landingFeatureProjectsDescription =>
      'Projects, tickets, sprints and a complete history of every change.';

  @override
  String get landingFeatureKanbanTitle => 'Kanban & cycles';

  @override
  String get landingFeatureKanbanDescription =>
      'Drag & drop boards, saved views and cycle metrics.';

  @override
  String get landingFeatureCalendarTitle => 'Team calendar';

  @override
  String get landingFeatureCalendarDescription =>
      'Monthly sprint roadmap and deadlines, with a private iCal feed.';

  @override
  String get landingFooter =>
      'Self-hosted · One single API for web, mobile and desktop.';

  @override
  String get landingBadge => 'Self-hosted · Web · Mobile · Desktop';

  @override
  String get landingCtaDiscover => 'Explore the features';

  @override
  String get landingFeaturesTitle => 'Everything you need to run your projects';

  @override
  String get landingFeatureHomelabTitle => 'Self-hosted';

  @override
  String get landingFeatureHomelabDescription =>
      'Deploy Disciplan on your own server: your data stays with you.';

  @override
  String get setupServerTitle => 'Server configuration';

  @override
  String get setupServerSubtitle =>
      'Point the app to another Disciplan API server. The web build uses its own origin by default.';

  @override
  String get settingsMcpTokensTitle => 'MCP tokens';

  @override
  String get settingsMcpTokensSubtitle =>
      'Personal access tokens for MCP clients (Mistral, ChatGPT, Claude Desktop, Cursor).';

  @override
  String get settingsMcpTokensEmpty =>
      'No token yet. Create one to connect an AI assistant to Disciplaner.';

  @override
  String get settingsMcpTokensCreate => 'Create a token';

  @override
  String get settingsMcpTokensCreateTitle => 'New MCP token';

  @override
  String get settingsMcpTokensNameLabel => 'Token name';

  @override
  String get settingsMcpTokensNameHint => 'e.g. Claude Desktop';

  @override
  String get settingsMcpTokensScopeLabel => 'Scope';

  @override
  String get settingsMcpTokensScopeRead => 'Read only';

  @override
  String get settingsMcpTokensScopeReadWrite => 'Read + write';

  @override
  String get settingsMcpTokensScopeHelp =>
      'Lets the assistant create and update tickets, sprints and comments.';

  @override
  String get settingsMcpTokenRevoke => 'Revoke';

  @override
  String get settingsMcpTokenRevoked => 'Revoked';

  @override
  String settingsMcpTokenNeverUsed(String created) {
    return 'Created on $created · never used';
  }

  @override
  String settingsMcpTokenLastUsed(String created, String lastUsed) {
    return 'Created on $created · last used on $lastUsed';
  }

  @override
  String get settingsMcpTokenCreatedTitle => 'Token created';

  @override
  String get settingsMcpTokenCreatedWarning =>
      'Copy this token now: it will never be shown again.';

  @override
  String get settingsMcpTokenCopy => 'Copy';

  @override
  String get settingsMcpTokenCopied => 'Token copied';

  @override
  String get settingsMcpTokenDone => 'Done';

  @override
  String get settingsMcpTokenRevokeConfirmTitle => 'Revoke this token?';

  @override
  String settingsMcpTokenRevokeConfirm(String name) {
    return 'Token \"$name\" will stop working immediately. This cannot be undone.';
  }
}
