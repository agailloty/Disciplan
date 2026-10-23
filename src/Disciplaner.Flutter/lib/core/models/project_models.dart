import 'package:equatable/equatable.dart';
import 'enums.dart';

class TicketStatusDto extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String color;
  final int order;
  final StatusCategory category;

  const TicketStatusDto({
    required this.id,
    required this.projectId,
    required this.name,
    required this.color,
    required this.order,
    required this.category,
  });

  factory TicketStatusDto.fromJson(Map<String, dynamic> json) {
    return TicketStatusDto(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#9CA3AF',
      order: json['order'] as int? ?? 0,
      category: StatusCategory.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'color': color,
        'order': order,
        'category': category.toJson(),
      };

  @override
  List<Object?> get props => [id, projectId, name, color, order, category];
}

class MemberDto extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final MemberRole role;
  final DateTime joinedAt;

  const MemberDto({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: MemberRole.fromJson(json['role']),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'role': role.toJson(),
        'joinedAt': joinedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [userId, displayName, email, role, joinedAt];
}

class ProjectSummaryDto extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String key;
  final int ticketCount;
  final int sprintCount;
  final DateTime createdAt;
  final MemberRole requestingUserRole;
  final bool isOwner;

  const ProjectSummaryDto({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.ticketCount,
    required this.sprintCount,
    required this.createdAt,
    required this.requestingUserRole,
    required this.isOwner,
  });

  factory ProjectSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProjectSummaryDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      key: json['key'] as String? ?? '',
      ticketCount: json['ticketCount'] as int? ?? 0,
      sprintCount: json['sprintCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      requestingUserRole: MemberRole.fromJson(json['requestingUserRole']),
      isOwner: json['isOwner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'key': key,
        'ticketCount': ticketCount,
        'sprintCount': sprintCount,
        'createdAt': createdAt.toIso8601String(),
        'requestingUserRole': requestingUserRole.toJson(),
        'isOwner': isOwner,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        key,
        ticketCount,
        sprintCount,
        createdAt,
        requestingUserRole,
        isOwner,
      ];
}

class ProjectDetailDto extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String key;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketStatusDto> statuses;
  final List<dynamic> sprints;
  final TicketType defaultTicketType;
  final DefaultAssigneePolicy defaultAssigneePolicy;
  final List<MemberDto> members;
  final MemberRole requestingUserRole;

  const ProjectDetailDto({
    required this.id,
    required this.name,
    this.description,
    required this.key,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
    required this.statuses,
    required this.sprints,
    required this.defaultTicketType,
    required this.defaultAssigneePolicy,
    required this.members,
    required this.requestingUserRole,
  });

  factory ProjectDetailDto.fromJson(Map<String, dynamic> json) {
    return ProjectDetailDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      key: json['key'] as String? ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => TicketStatusDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sprints: json['sprints'] as List<dynamic>? ?? [],
      defaultTicketType: TicketType.fromJson(json['defaultTicketType']),
      defaultAssigneePolicy: DefaultAssigneePolicy.fromJson(json['defaultAssigneePolicy']),
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requestingUserRole: MemberRole.fromJson(json['requestingUserRole']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'key': key,
        'ownerId': ownerId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'statuses': statuses.map((e) => e.toJson()).toList(),
        'sprints': sprints,
        'defaultTicketType': defaultTicketType.toJson(),
        'defaultAssigneePolicy': defaultAssigneePolicy.toJson(),
        'members': members.map((e) => e.toJson()).toList(),
        'requestingUserRole': requestingUserRole.toJson(),
      };

  /// Returns all assignable project members (including the owner / current user
  /// if not already present in the backend `members` collection).
  List<MemberDto> assignableMembers({
    String? currentUserId,
    String? currentUserDisplayName,
    String? currentUserEmail,
  }) {
    final result = <MemberDto>[];
    final seenIds = <String>{};

    // Include current user if they have write access and aren't in members yet
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        requestingUserRole != MemberRole.guest &&
        !members.any((m) => m.userId == currentUserId)) {
      seenIds.add(currentUserId);
      result.add(
        MemberDto(
          userId: currentUserId,
          displayName: (currentUserDisplayName != null && currentUserDisplayName.isNotEmpty)
              ? currentUserDisplayName
              : 'Moi',
          email: currentUserEmail ?? '',
          role: requestingUserRole,
          joinedAt: createdAt,
        ),
      );
    }

    for (final m in members) {
      if (m.role == MemberRole.guest) continue;
      if (seenIds.add(m.userId)) {
        result.add(m);
      }
    }

    // Fallback: if ownerId is still not in seenIds and ownerId is non-empty
    if (ownerId.isNotEmpty && !seenIds.contains(ownerId)) {
      result.insert(
        0,
        MemberDto(
          userId: ownerId,
          displayName: (currentUserId == ownerId &&
                  currentUserDisplayName != null &&
                  currentUserDisplayName.isNotEmpty)
              ? currentUserDisplayName
              : 'Propriétaire du projet',
          email: currentUserId == ownerId ? (currentUserEmail ?? '') : '',
          role: MemberRole.admin,
          joinedAt: createdAt,
        ),
      );
    }

    return result;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        key,
        ownerId,
        createdAt,
        updatedAt,
        statuses,
        sprints,
        defaultTicketType,
        defaultAssigneePolicy,
        members,
        requestingUserRole,
      ];
}

class CreateProjectRequest extends Equatable {
  final String name;
  final String? description;
  final String key;

  const CreateProjectRequest({
    required this.name,
    this.description,
    required this.key,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'key': key,
      };

  @override
  List<Object?> get props => [name, description, key];
}

class UpdateProjectRequest extends Equatable {
  final String name;
  final String? description;

  const UpdateProjectRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
      };

  @override
  List<Object?> get props => [name, description];
}

class UpdateProjectDefaultsRequest extends Equatable {
  final TicketType defaultTicketType;
  final DefaultAssigneePolicy defaultAssigneePolicy;

  const UpdateProjectDefaultsRequest({
    required this.defaultTicketType,
    required this.defaultAssigneePolicy,
  });

  Map<String, dynamic> toJson() => {
        'defaultTicketType': defaultTicketType.toJson(),
        'defaultAssigneePolicy': defaultAssigneePolicy.toJson(),
      };

  @override
  List<Object?> get props => [defaultTicketType, defaultAssigneePolicy];
}

class CreateTicketStatusRequest extends Equatable {
  final String name;
  final StatusCategory category;
  final String color;

  const CreateTicketStatusRequest({
    required this.name,
    required this.category,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.toJson(),
        'color': color,
      };

  @override
  List<Object?> get props => [name, category, color];
}

class UpdateTicketStatusRequest extends Equatable {
  final String name;
  final StatusCategory category;
  final String color;

  const UpdateTicketStatusRequest({
    required this.name,
    required this.category,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.toJson(),
        'color': color,
      };

  @override
  List<Object?> get props => [name, category, color];
}

class AddMemberRequest extends Equatable {
  final String userId;
  final MemberRole role;

  const AddMemberRequest({
    required this.userId,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role.toJson(),
      };

  @override
  List<Object?> get props => [userId, role];
}

class UpdateMemberRoleRequest extends Equatable {
  final MemberRole role;

  const UpdateMemberRoleRequest({required this.role});

  Map<String, dynamic> toJson() => {
        'role': role.toJson(),
      };

  @override
  List<Object?> get props => [role];
}
