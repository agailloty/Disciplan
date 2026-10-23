import 'dart:async';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KanbanState {
  final List<TicketStatusDto> statuses;
  final Map<String, List<TicketDto>> ticketsByStatus;
  final String searchQuery;
  final bool onlyAssignedToMe;
  final CardPriority? selectedPriority;
  final bool isLoading;
  final String? errorMessage;

  const KanbanState({
    this.statuses = const [],
    this.ticketsByStatus = const {},
    this.searchQuery = '',
    this.onlyAssignedToMe = false,
    this.selectedPriority,
    this.isLoading = false,
    this.errorMessage,
  });

  KanbanState copyWith({
    List<TicketStatusDto>? statuses,
    Map<String, List<TicketDto>>? ticketsByStatus,
    String? searchQuery,
    bool? onlyAssignedToMe,
    CardPriority? selectedPriority,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KanbanState(
      statuses: statuses ?? this.statuses,
      ticketsByStatus: ticketsByStatus ?? this.ticketsByStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyAssignedToMe: onlyAssignedToMe ?? this.onlyAssignedToMe,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<TicketDto> getFilteredTicketsForStatus(String statusId, String? currentUserId) {
    final list = ticketsByStatus[statusId] ?? [];
    return list.where((ticket) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = ticket.title.toLowerCase().contains(query);
        final matchesRef = ticket.ticketRef.toLowerCase().contains(query);
        if (!matchesTitle && !matchesRef) return false;
      }

      if (onlyAssignedToMe && currentUserId != null) {
        if (ticket.assigneeId != currentUserId) return false;
      }

      if (selectedPriority != null) {
        if (ticket.priority != selectedPriority) return false;
      }

      return true;
    }).toList();
  }
}

class KanbanNotifier extends AsyncNotifier<KanbanState> {
  final String sprintId;

  KanbanNotifier(this.sprintId);

  @override
  FutureOr<KanbanState> build() async {
    final ticketRepo = ref.watch(ticketRepositoryProvider);
    final currentProject = await ref.watch(currentProjectDetailProvider.future);

    final statuses = (currentProject?.statuses ?? []).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final tickets = await ticketRepo.getBySprint(sprintId);

    final map = <String, List<TicketDto>>{};
    for (final s in statuses) {
      map[s.id] = [];
    }

    for (final t in tickets) {
      final sId = t.status.id;
      if (map.containsKey(sId)) {
        map[sId]!.add(t);
      } else if (statuses.isNotEmpty) {
        map[statuses.first.id]!.add(t);
      }
    }

    return KanbanState(
      statuses: statuses,
      ticketsByStatus: map,
    );
  }

  void setSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(searchQuery: query));
  }

  void toggleOnlyAssignedToMe() {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(onlyAssignedToMe: !current.onlyAssignedToMe),
    );
  }

  void setPriorityFilter(CardPriority? priority) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(selectedPriority: priority));
  }

  Future<void> moveTicket(String ticketId, String targetStatusId) async {
    final current = state.value;
    if (current == null) return;

    // Find source status and ticket
    String? sourceStatusId;
    TicketDto? ticketToMove;

    for (final entry in current.ticketsByStatus.entries) {
      final index = entry.value.indexWhere((t) => t.id == ticketId);
      if (index != -1) {
        sourceStatusId = entry.key;
        ticketToMove = entry.value[index];
        break;
      }
    }

    if (sourceStatusId == null || ticketToMove == null || sourceStatusId == targetStatusId) {
      return;
    }

    final targetStatus = current.statuses.firstWhere(
      (s) => s.id == targetStatusId,
      orElse: () => current.statuses.first,
    );

    // 1. Optimistic Update
    final updatedMap = Map<String, List<TicketDto>>.from(
      current.ticketsByStatus.map((k, v) => MapEntry(k, List<TicketDto>.from(v))),
    );

    updatedMap[sourceStatusId]!.removeWhere((t) => t.id == ticketId);
    final movedTicket = ticketToMove.copyWith(status: targetStatus);
    updatedMap[targetStatusId]!.add(movedTicket);

    state = AsyncValue.data(current.copyWith(ticketsByStatus: updatedMap));

    // 2. Network Call
    try {
      final repo = ref.read(ticketRepositoryProvider);
      await repo.changeStatus(ticketId, targetStatusId);
      ref.invalidate(sprintMetricsProvider(sprintId));
    } catch (e) {
      // 3. Rollback on failure
      state = AsyncValue.data(
        current.copyWith(
          errorMessage: 'Échec du déplacement : $e',
        ),
      );
    }
  }
}

final kanbanStateProvider =
    AsyncNotifierProvider.family<KanbanNotifier, KanbanState, String>(
  KanbanNotifier.new,
);
