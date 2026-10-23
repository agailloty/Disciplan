import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'project_models.dart';

class SprintDto extends Equatable {
  final String id;
  final String projectId;
  final String? projectName;
  final String? projectKey;
  final String name;
  final String? goal;
  final SprintStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final int ticketCount;

  const SprintDto({
    required this.id,
    required this.projectId,
    this.projectName,
    this.projectKey,
    required this.name,
    this.goal,
    required this.status,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.ticketCount,
  });

  factory SprintDto.fromJson(Map<String, dynamic> json) {
    return SprintDto(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName'] as String?,
      projectKey: json['projectKey'] as String?,
      name: json['name'] as String? ?? '',
      goal: json['goal'] as String?,
      status: SprintStatus.fromJson(json['status']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      ticketCount: json['ticketCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'projectName': projectName,
        'projectKey': projectKey,
        'name': name,
        'goal': goal,
        'status': status.toJson(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'ticketCount': ticketCount,
      };

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectName,
        projectKey,
        name,
        goal,
        status,
        startDate,
        endDate,
        createdAt,
        ticketCount,
      ];
}

class SprintDetailDto extends Equatable {
  final String id;
  final String projectId;
  final String projectName;
  final String projectKey;
  final String name;
  final String? goal;
  final SprintStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final List<TicketStatusDto> statuses;

  const SprintDetailDto({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.projectKey,
    required this.name,
    this.goal,
    required this.status,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.statuses,
  });

  factory SprintDetailDto.fromJson(Map<String, dynamic> json) {
    return SprintDetailDto(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName'] as String? ?? '',
      projectKey: json['projectKey'] as String? ?? '',
      name: json['name'] as String? ?? '',
      goal: json['goal'] as String?,
      status: SprintStatus.fromJson(json['status']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      statuses: (json['statuses'] as List<dynamic>?)
              ?.map((e) => TicketStatusDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'projectName': projectName,
        'projectKey': projectKey,
        'name': name,
        'goal': goal,
        'status': status.toJson(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'statuses': statuses.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectName,
        projectKey,
        name,
        goal,
        status,
        startDate,
        endDate,
        createdAt,
        statuses,
      ];
}

class CreateSprintRequest extends Equatable {
  final String name;
  final String? goal;

  const CreateSprintRequest({
    required this.name,
    this.goal,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (goal != null) 'goal': goal,
      };

  @override
  List<Object?> get props => [name, goal];
}

class UpdateSprintRequest extends Equatable {
  final String name;
  final String? goal;
  final DateTime? startDate;
  final DateTime? endDate;

  const UpdateSprintRequest({
    required this.name,
    this.goal,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (goal != null) 'goal': goal,
        if (startDate != null) 'startDate': startDate?.toIso8601String(),
        if (endDate != null) 'endDate': endDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [name, goal, startDate, endDate];
}

class StartSprintRequest extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const StartSprintRequest({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  @override
  List<Object?> get props => [startDate, endDate];
}
