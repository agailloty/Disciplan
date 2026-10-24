import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sprint_repository.dart';

class SprintMetrics {
  final int totalTickets;
  final int closedTickets;
  final double completionPercentage;
  final int totalPoints;
  final int completedPoints;
  final int daysRemaining;
  final List<String> activeMemberNames;

  const SprintMetrics({
    required this.totalTickets,
    required this.closedTickets,
    required this.completionPercentage,
    required this.totalPoints,
    required this.completedPoints,
    required this.daysRemaining,
    required this.activeMemberNames,
  });

  factory SprintMetrics.fromTickets({
    required List<TicketDto> tickets,
    DateTime? endDate,
  }) {
    final total = tickets.length;
    final closed = tickets
        .where((t) => t.status.category == StatusCategory.done)
        .length;
    final percentage = total == 0 ? 0.0 : (closed / total) * 100.0;

    int totalPts = 0;
    int completedPts = 0;
    final members = <String>{};

    for (final t in tickets) {
      final pts = t.storyPoints ?? 0;
      totalPts += pts;
      if (t.status.category == StatusCategory.done) {
        completedPts += pts;
      }
      if (t.assigneeName != null && t.assigneeName!.isNotEmpty) {
        members.add(t.assigneeName!);
      }
    }

    int remaining = 0;
    if (endDate != null) {
      final now = DateTime.now();
      final diff = endDate.difference(now).inDays;
      remaining = diff < 0 ? 0 : diff;
    }

    return SprintMetrics(
      totalTickets: total,
      closedTickets: closed,
      completionPercentage: percentage,
      totalPoints: totalPts,
      completedPoints: completedPts,
      daysRemaining: remaining,
      activeMemberNames: members.toList(),
    );
  }
}

final sprintRepositoryProvider = Provider<SprintRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SprintRepository(dioClient.dio);
});

// Sprints for a given project
final projectSprintsProvider =
    FutureProvider.family.autoDispose<List<SprintDto>, String>((ref, projectId) async {
  final repo = ref.watch(sprintRepositoryProvider);
  return await repo.getByProject(projectId);
});

// Active sprints across the platform
final activeSprintsProvider =
    FutureProvider.autoDispose<List<SprintDto>>((ref) async {
  final repo = ref.watch(sprintRepositoryProvider);
  return await repo.getActive();
});

// Currently selected sprint ID in board / view
class SelectedSprintIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedSprintIdProvider =
    NotifierProvider<SelectedSprintIdNotifier, String?>(
  SelectedSprintIdNotifier.new,
);

// Detail of a specific sprint
final sprintDetailProvider =
    FutureProvider.family.autoDispose<SprintDetailDto, String>((ref, sprintId) async {
  final repo = ref.watch(sprintRepositoryProvider);
  return await repo.getById(sprintId);
});

// Computed metrics for a sprint
final sprintMetricsProvider =
    FutureProvider.family.autoDispose<SprintMetrics, String>((ref, sprintId) async {
  final tickets = await ref.watch(sprintTicketsProvider(sprintId).future);
  final sprintDetail = await ref.watch(sprintDetailProvider(sprintId).future);

  return SprintMetrics.fromTickets(
    tickets: tickets,
    endDate: sprintDetail.endDate,
  );
});
