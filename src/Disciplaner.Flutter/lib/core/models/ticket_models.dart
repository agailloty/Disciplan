import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'project_models.dart';

class LabelDto extends Equatable {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  const LabelDto({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  factory LabelDto.fromJson(Map<String, dynamic> json) {
    return LabelDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#E5A800',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, color, createdAt];
}

class TicketDto extends Equatable {
  final String id;
  final String projectId;
  final String projectKey;
  final int ticketNumber;
  final String ticketRef;
  final String title;
  final String? description;
  final TicketType type;
  final CardPriority priority;
  final int? storyPoints;
  final DateTime? dueDate;
  final TicketStatusDto status;
  final String? sprintId;
  final String? sprintName;
  final String? parentTicketId;
  final String? parentTicketRef;
  final String reporterId;
  final String reporterName;
  final String? assigneeId;
  final String? assigneeName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<LabelDto> labels;

  const TicketDto({
    required this.id,
    required this.projectId,
    required this.projectKey,
    required this.ticketNumber,
    required this.ticketRef,
    required this.title,
    this.description,
    required this.type,
    required this.priority,
    this.storyPoints,
    this.dueDate,
    required this.status,
    this.sprintId,
    this.sprintName,
    this.parentTicketId,
    this.parentTicketRef,
    required this.reporterId,
    required this.reporterName,
    this.assigneeId,
    this.assigneeName,
    required this.createdAt,
    this.updatedAt,
    this.labels = const [],
  });

  factory TicketDto.fromJson(Map<String, dynamic> json) {
    return TicketDto(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      projectKey: json['projectKey'] as String? ?? '',
      ticketNumber: json['ticketNumber'] as int? ?? 0,
      ticketRef: json['ticketRef'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: TicketType.fromJson(json['type']),
      priority: CardPriority.fromJson(json['priority']),
      storyPoints: json['storyPoints'] as int?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'].toString()) : null,
      status: json['status'] is Map<String, dynamic>
          ? TicketStatusDto.fromJson(json['status'] as Map<String, dynamic>)
          : TicketStatusDto(
              id: json['statusId']?.toString() ?? '',
              projectId: json['projectId']?.toString() ?? '',
              name: 'In Progress',
              color: '#F59E0B',
              order: 0,
              category: StatusCategory.inProgress,
            ),
      sprintId: json['sprintId']?.toString(),
      sprintName: json['sprintName'] as String?,
      parentTicketId: json['parentTicketId']?.toString(),
      parentTicketRef: json['parentTicketRef'] as String?,
      reporterId: json['reporterId']?.toString() ?? '',
      reporterName: json['reporterName'] as String? ?? '',
      assigneeId: json['assigneeId']?.toString(),
      assigneeName: json['assigneeName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => LabelDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'projectKey': projectKey,
        'ticketNumber': ticketNumber,
        'ticketRef': ticketRef,
        'title': title,
        'description': description,
        'type': type.toJson(),
        'priority': priority.toJson(),
        'storyPoints': storyPoints,
        'dueDate': dueDate?.toIso8601String(),
        'status': status.toJson(),
        'sprintId': sprintId,
        'sprintName': sprintName,
        'parentTicketId': parentTicketId,
        'parentTicketRef': parentTicketRef,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'labels': labels.map((e) => e.toJson()).toList(),
      };

  TicketDto copyWith({
    String? id,
    String? projectId,
    String? projectKey,
    int? ticketNumber,
    String? ticketRef,
    String? title,
    String? description,
    TicketType? type,
    CardPriority? priority,
    int? storyPoints,
    DateTime? dueDate,
    TicketStatusDto? status,
    String? sprintId,
    String? sprintName,
    String? parentTicketId,
    String? parentTicketRef,
    String? reporterId,
    String? reporterName,
    String? assigneeId,
    String? assigneeName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<LabelDto>? labels,
  }) {
    return TicketDto(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectKey: projectKey ?? this.projectKey,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      ticketRef: ticketRef ?? this.ticketRef,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      storyPoints: storyPoints ?? this.storyPoints,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      sprintId: sprintId ?? this.sprintId,
      sprintName: sprintName ?? this.sprintName,
      parentTicketId: parentTicketId ?? this.parentTicketId,
      parentTicketRef: parentTicketRef ?? this.parentTicketRef,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      labels: labels ?? this.labels,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        projectKey,
        ticketNumber,
        ticketRef,
        title,
        description,
        type,
        priority,
        storyPoints,
        dueDate,
        status,
        sprintId,
        sprintName,
        parentTicketId,
        parentTicketRef,
        reporterId,
        reporterName,
        assigneeId,
        assigneeName,
        createdAt,
        updatedAt,
        labels,
      ];
}

class CreateTicketRequest extends Equatable {
  final String title;
  final String? description;
  final TicketType type;
  final CardPriority priority;
  final int? storyPoints;
  final DateTime? dueDate;
  final String? sprintId;
  final String? parentTicketId;
  final String? assigneeId;

  const CreateTicketRequest({
    required this.title,
    this.description,
    required this.type,
    required this.priority,
    this.storyPoints,
    this.dueDate,
    this.sprintId,
    this.parentTicketId,
    this.assigneeId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        'type': type.toJson(),
        'priority': priority.toJson(),
        if (storyPoints != null) 'storyPoints': storyPoints,
        if (dueDate != null) 'dueDate': dueDate?.toIso8601String(),
        if (sprintId != null) 'sprintId': sprintId,
        if (parentTicketId != null) 'parentTicketId': parentTicketId,
        if (assigneeId != null) 'assigneeId': assigneeId,
      };

  @override
  List<Object?> get props => [
        title,
        description,
        type,
        priority,
        storyPoints,
        dueDate,
        sprintId,
        parentTicketId,
        assigneeId,
      ];
}

class UpdateTicketRequest extends Equatable {
  final String title;
  final String? description;
  final TicketType type;
  final CardPriority priority;
  final int? storyPoints;
  final DateTime? dueDate;
  final String? assigneeId;

  const UpdateTicketRequest({
    required this.title,
    this.description,
    required this.type,
    required this.priority,
    this.storyPoints,
    this.dueDate,
    this.assigneeId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type.toJson(),
        'priority': priority.toJson(),
        'storyPoints': storyPoints,
        'dueDate': dueDate?.toIso8601String(),
        'assigneeId': assigneeId,
      };

  @override
  List<Object?> get props => [
        title,
        description,
        type,
        priority,
        storyPoints,
        dueDate,
        assigneeId,
      ];
}

class MoveTicketToSprintRequest extends Equatable {
  final String? sprintId;

  const MoveTicketToSprintRequest({this.sprintId});

  Map<String, dynamic> toJson() => {
        'sprintId': sprintId,
      };

  @override
  List<Object?> get props => [sprintId];
}

class ChangeTicketStatusRequest extends Equatable {
  final String statusId;

  const ChangeTicketStatusRequest({required this.statusId});

  Map<String, dynamic> toJson() => {
        'statusId': statusId,
      };

  @override
  List<Object?> get props => [statusId];
}
