// Énumérations métier partagées avec l'API .NET 10 Disciplan.

enum CardPriority {
  low(0),
  medium(1),
  high(2),
  critical(3);

  final int value;
  const CardPriority(this.value);

  static CardPriority fromJson(dynamic json) {
    if (json is int) {
      return CardPriority.values.firstWhere(
        (e) => e.value == json,
        orElse: () => CardPriority.medium,
      );
    }
    if (json is String) {
      final lower = json.toLowerCase();
      if (lower.contains('crit') || lower.contains('urgent')) return CardPriority.critical;
      if (lower.contains('high') || lower.contains('haut')) return CardPriority.high;
      if (lower.contains('low') || lower.contains('bas')) return CardPriority.low;
      return CardPriority.medium;
    }
    return CardPriority.medium;
  }

  int toJson() => value;
}

enum StatusCategory {
  backlog(0),
  inProgress(1),
  done(2);

  final int value;
  const StatusCategory(this.value);

  static StatusCategory fromJson(dynamic json) {
    if (json is int) {
      return StatusCategory.values.firstWhere(
        (e) => e.value == json,
        orElse: () => StatusCategory.backlog,
      );
    }
    if (json is String) {
      final lower = json.toLowerCase();
      if (lower.contains('done') || lower.contains('termin')) return StatusCategory.done;
      if (lower.contains('progress') || lower.contains('cours')) return StatusCategory.inProgress;
      return StatusCategory.backlog;
    }
    return StatusCategory.backlog;
  }

  int toJson() => value;
}

enum SprintStatus {
  planned(0),
  active(1),
  closed(2);

  final int value;
  const SprintStatus(this.value);

  static SprintStatus fromJson(dynamic json) {
    if (json is int) {
      return SprintStatus.values.firstWhere(
        (e) => e.value == json,
        orElse: () => SprintStatus.planned,
      );
    }
    if (json is String) {
      final lower = json.toLowerCase();
      if (lower == 'active' || lower == '1') return SprintStatus.active;
      if (lower == 'closed' || lower == '2') return SprintStatus.closed;
      return SprintStatus.planned;
    }
    return SprintStatus.planned;
  }

  int toJson() => value;
}

enum TicketType {
  story(0),
  bug(1),
  task(2),
  epic(3),
  subtask(4);

  final int value;
  const TicketType(this.value);

  static TicketType fromJson(dynamic json) {
    if (json is int) {
      return TicketType.values.firstWhere(
        (e) => e.value == json,
        orElse: () => TicketType.task,
      );
    }
    if (json is String) {
      final lower = json.toLowerCase();
      if (lower.contains('bug')) return TicketType.bug;
      if (lower.contains('story')) return TicketType.story;
      if (lower.contains('epic')) return TicketType.epic;
      if (lower.contains('sub')) return TicketType.subtask;
      return TicketType.task;
    }
    return TicketType.task;
  }

  int toJson() => value;
}

enum MemberRole {
  guest(0),
  member(1),
  supervisor(2),
  admin(3);

  final int value;
  const MemberRole(this.value);

  static MemberRole fromJson(dynamic json) {
    if (json is int) {
      return MemberRole.values.firstWhere(
        (e) => e.value == json,
        orElse: () => MemberRole.guest,
      );
    }
    if (json is String) {
      final lower = json.toLowerCase();
      if (lower == 'admin' || lower == '3') return MemberRole.admin;
      if (lower == 'supervisor' || lower == '2') return MemberRole.supervisor;
      if (lower == 'member' || lower == '1') return MemberRole.member;
      return MemberRole.guest;
    }
    return MemberRole.guest;
  }

  int toJson() => value;
}

enum DefaultAssigneePolicy {
  none(0),
  creator(1);

  final int value;
  const DefaultAssigneePolicy(this.value);

  static DefaultAssigneePolicy fromJson(dynamic json) {
    if (json is int) {
      return DefaultAssigneePolicy.values.firstWhere(
        (e) => e.value == json,
        orElse: () => DefaultAssigneePolicy.none,
      );
    }
    if (json is String) {
      if (json.toLowerCase() == 'creator') return DefaultAssigneePolicy.creator;
      return DefaultAssigneePolicy.none;
    }
    return DefaultAssigneePolicy.none;
  }

  int toJson() => value;
}
