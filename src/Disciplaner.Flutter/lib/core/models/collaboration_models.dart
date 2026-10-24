import 'package:equatable/equatable.dart';
import 'enums.dart';

class CommentDto extends Equatable {
  final String id;
  final String? cardId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentDto({
    required this.id,
    this.cardId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id']?.toString() ?? '',
      cardId: json['cardId']?.toString(),
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardId': cardId,
        'authorId': authorId,
        'authorName': authorName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, cardId, authorId, authorName, content, createdAt, updatedAt];
}

class CreateCommentRequest extends Equatable {
  final String content;

  const CreateCommentRequest({required this.content});

  Map<String, dynamic> toJson() => {'content': content};

  @override
  List<Object?> get props => [content];
}

class AttachmentDto extends Equatable {
  final String id;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final String uploadedById;
  final String uploadedByName;
  final DateTime uploadedAt;
  final String? ticketId;
  final String? commentId;
  final String? boardId;

  const AttachmentDto({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.uploadedById,
    required this.uploadedByName,
    required this.uploadedAt,
    this.ticketId,
    this.commentId,
    this.boardId,
  });

  factory AttachmentDto.fromJson(Map<String, dynamic> json) {
    return AttachmentDto(
      id: json['id']?.toString() ?? '',
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      uploadedById: json['uploadedById']?.toString() ?? '',
      uploadedByName: json['uploadedByName'] as String? ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'].toString())
          : DateTime.now(),
      ticketId: json['ticketId']?.toString(),
      commentId: json['commentId']?.toString(),
      boardId: json['boardId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
        'uploadedById': uploadedById,
        'uploadedByName': uploadedByName,
        'uploadedAt': uploadedAt.toIso8601String(),
        'ticketId': ticketId,
        'commentId': commentId,
        'boardId': boardId,
      };

  @override
  List<Object?> get props => [
        id,
        fileName,
        contentType,
        sizeBytes,
        uploadedById,
        uploadedByName,
        uploadedAt,
        ticketId,
        commentId,
        boardId,
      ];
}

class SavedViewDto extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isVisibleOnHome;
  final int displayOrder;
  final String? projectId;
  final String? statusId;
  final String? sprintId;
  final TicketType? type;
  final CardPriority? priority;
  final List<StatusCategory> statusCategories;
  final bool onlyAssignedToMe;
  final bool onlyReportedByMe;
  final bool isCollapsedByDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavedViewDto({
    required this.id,
    required this.name,
    this.description,
    required this.isVisibleOnHome,
    required this.displayOrder,
    this.projectId,
    this.statusId,
    this.sprintId,
    this.type,
    this.priority,
    this.statusCategories = const [],
    required this.onlyAssignedToMe,
    required this.onlyReportedByMe,
    required this.isCollapsedByDefault,
    required this.createdAt,
    this.updatedAt,
  });

  factory SavedViewDto.fromJson(Map<String, dynamic> json) {
    return SavedViewDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isVisibleOnHome: json['isVisibleOnHome'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      projectId: json['projectId']?.toString(),
      statusId: json['statusId']?.toString(),
      sprintId: json['sprintId']?.toString(),
      type: json['type'] != null ? TicketType.fromJson(json['type']) : null,
      priority: json['priority'] != null ? CardPriority.fromJson(json['priority']) : null,
      statusCategories: (json['statusCategories'] as List<dynamic>?)
              ?.map((e) => StatusCategory.fromJson(e))
              .toList() ??
          [],
      onlyAssignedToMe: json['onlyAssignedToMe'] as bool? ?? false,
      onlyReportedByMe: json['onlyReportedByMe'] as bool? ?? false,
      isCollapsedByDefault: json['isCollapsedByDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isVisibleOnHome': isVisibleOnHome,
        'displayOrder': displayOrder,
        'projectId': projectId,
        'statusId': statusId,
        'sprintId': sprintId,
        'type': type?.toJson(),
        'priority': priority?.toJson(),
        'statusCategories': statusCategories.map((e) => e.toJson()).toList(),
        'onlyAssignedToMe': onlyAssignedToMe,
        'onlyReportedByMe': onlyReportedByMe,
        'isCollapsedByDefault': isCollapsedByDefault,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isVisibleOnHome,
        displayOrder,
        projectId,
        statusId,
        sprintId,
        type,
        priority,
        statusCategories,
        onlyAssignedToMe,
        onlyReportedByMe,
        isCollapsedByDefault,
        createdAt,
        updatedAt,
      ];
}

class CreateSavedViewRequest extends Equatable {
  final String name;
  final String? description;
  final bool isVisibleOnHome;
  final int displayOrder;
  final String? projectId;
  final String? statusId;
  final String? sprintId;
  final TicketType? type;
  final CardPriority? priority;
  final List<StatusCategory> statusCategories;
  final bool onlyAssignedToMe;
  final bool onlyReportedByMe;
  final bool isCollapsedByDefault;

  const CreateSavedViewRequest({
    required this.name,
    this.description,
    this.isVisibleOnHome = false,
    this.displayOrder = 0,
    this.projectId,
    this.statusId,
    this.sprintId,
    this.type,
    this.priority,
    this.statusCategories = const [],
    this.onlyAssignedToMe = false,
    this.onlyReportedByMe = false,
    this.isCollapsedByDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'isVisibleOnHome': isVisibleOnHome,
        'displayOrder': displayOrder,
        'projectId': projectId,
        'statusId': statusId,
        'sprintId': sprintId,
        'type': type?.toJson(),
        'priority': priority?.toJson(),
        'statusCategories': statusCategories.map((e) => e.toJson()).toList(),
        'onlyAssignedToMe': onlyAssignedToMe,
        'onlyReportedByMe': onlyReportedByMe,
        'isCollapsedByDefault': isCollapsedByDefault,
      };

  @override
  List<Object?> get props => [
        name,
        description,
        isVisibleOnHome,
        displayOrder,
        projectId,
        statusId,
        sprintId,
        type,
        priority,
        statusCategories,
        onlyAssignedToMe,
        onlyReportedByMe,
        isCollapsedByDefault,
      ];
}

class TicketHistoryEntryDto extends Equatable {
  final String id;
  final String kind;
  final String? oldValue;
  final String? newValue;
  final String actorId;
  final String actorName;
  final DateTime occurredAt;

  const TicketHistoryEntryDto({
    required this.id,
    required this.kind,
    this.oldValue,
    this.newValue,
    required this.actorId,
    required this.actorName,
    required this.occurredAt,
  });

  factory TicketHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    return TicketHistoryEntryDto(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      oldValue: json['oldValue'] as String?,
      newValue: json['newValue'] as String?,
      actorId: json['actorId']?.toString() ?? '',
      actorName: json['actorName'] as String? ?? '',
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'oldValue': oldValue,
        'newValue': newValue,
        'actorId': actorId,
        'actorName': actorName,
        'occurredAt': occurredAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, kind, oldValue, newValue, actorId, actorName, occurredAt];
}

class ActivityItemDto extends Equatable {
  final String kind;
  final String summary;
  final String? ticketRef;
  final String? ticketId;
  final DateTime occurredAt;
  final String? attachmentId;

  const ActivityItemDto({
    required this.kind,
    required this.summary,
    this.ticketRef,
    this.ticketId,
    required this.occurredAt,
    this.attachmentId,
  });

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) {
    return ActivityItemDto(
      kind: json['kind'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      ticketRef: json['ticketRef'] as String?,
      ticketId: json['ticketId']?.toString(),
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'].toString())
          : DateTime.now(),
      attachmentId: json['attachmentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'summary': summary,
        'ticketRef': ticketRef,
        'ticketId': ticketId,
        'occurredAt': occurredAt.toIso8601String(),
        'attachmentId': attachmentId,
      };

  @override
  List<Object?> get props => [kind, summary, ticketRef, ticketId, occurredAt, attachmentId];
}

class CalendarTokenDto extends Equatable {
  final String token;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;

  const CalendarTokenDto({
    required this.token,
    required this.createdAt,
    this.lastAccessedAt,
  });

  factory CalendarTokenDto.fromJson(Map<String, dynamic> json) {
    return CalendarTokenDto(
      token: json['token'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'createdAt': createdAt.toIso8601String(),
        'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [token, createdAt, lastAccessedAt];
}

class UserSummaryDto extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? profilePictureUrl;

  const UserSummaryDto({
    required this.id,
    required this.displayName,
    required this.email,
    this.profilePictureUrl,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) {
    return UserSummaryDto(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'profilePictureUrl': profilePictureUrl,
      };

  @override
  List<Object?> get props => [id, displayName, email, profilePictureUrl];
}

class AdminUserDto extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final List<String> roles;

  const AdminUserDto({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.roles,
  });

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'roles': roles,
      };

  @override
  List<Object?> get props => [id, displayName, email, isActive, createdAt, roles];
}

class InvitationDto extends Equatable {
  final String id;
  final String token;
  final String email;
  final String invitedByUserId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  const InvitationDto({
    required this.id,
    required this.token,
    required this.email,
    required this.invitedByUserId,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
  });

  factory InvitationDto.fromJson(Map<String, dynamic> json) {
    return InvitationDto(
      id: json['id']?.toString() ?? '',
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      invitedByUserId: json['invitedByUserId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : DateTime.now().add(const Duration(days: 7)),
      isUsed: json['isUsed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'email': email,
        'invitedByUserId': invitedByUserId,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isUsed': isUsed,
      };

  @override
  List<Object?> get props => [id, token, email, invitedByUserId, createdAt, expiresAt, isUsed];
}
