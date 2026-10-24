import '../../../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../widgets/priority_icon.dart' as prio;
import '../widgets/status_badge.dart';

/// Localized labels for the business enums.
///
/// The enum values themselves stay language-free (shared with the API); the
/// display text is resolved at UI time from the current locale.

extension CardPriorityL10n on CardPriority {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        CardPriority.low => l10n.priorityLow,
        CardPriority.medium => l10n.priorityMedium,
        CardPriority.high => l10n.priorityHigh,
        CardPriority.critical => l10n.priorityCritical,
      };
}

extension StatusCategoryL10n on StatusCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        StatusCategory.backlog => l10n.statuscategoryBacklog,
        StatusCategory.inProgress => l10n.statuscategoryInProgress,
        StatusCategory.done => l10n.statuscategoryDone,
      };
}

extension TicketPriorityL10n on prio.TicketPriority {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        prio.TicketPriority.low => l10n.priorityLow,
        prio.TicketPriority.medium => l10n.priorityMedium,
        prio.TicketPriority.high => l10n.priorityHigh,
        prio.TicketPriority.urgent => l10n.priorityCritical,
      };
}

extension TicketStatusCategoryL10n on TicketStatusCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        TicketStatusCategory.todo => l10n.statuscategoryBacklog,
        TicketStatusCategory.inProgress => l10n.statuscategoryInProgress,
        TicketStatusCategory.done => l10n.statuscategoryDone,
      };
}

extension TicketTypeL10n on TicketType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        TicketType.story => l10n.typeStory,
        TicketType.bug => l10n.typeBug,
        TicketType.task => l10n.typeTask,
        TicketType.epic => l10n.typeEpic,
        TicketType.subtask => l10n.typeSubtask,
      };
}

extension SprintStatusL10n on SprintStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        SprintStatus.planned => l10n.sprintStatusPlanned,
        SprintStatus.active => l10n.sprintStatusActive,
        SprintStatus.closed => l10n.sprintStatusClosed,
      };
}

extension MemberRoleL10n on MemberRole {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MemberRole.guest => l10n.roleGuest,
        MemberRole.member => l10n.roleMember,
        MemberRole.supervisor => l10n.roleSupervisor,
        MemberRole.admin => l10n.roleAdmin,
      };
}
