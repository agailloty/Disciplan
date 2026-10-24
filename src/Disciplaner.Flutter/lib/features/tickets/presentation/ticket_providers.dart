import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/collaboration_models.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/ticket_models.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/saved_view_repository.dart';
import '../data/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TicketRepository(dioClient.dio);
});

final savedViewRepositoryProvider = Provider<SavedViewRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SavedViewRepository(dioClient.dio);
});

// Selected tickets for batch actions
class SelectedTicketIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
    } else {
      state = Set.from(state)..add(id);
    }
  }

  void selectAll(Iterable<String> ids) {
    state = Set.from(ids);
  }

  void clear() {
    state = {};
  }
}

final selectedTicketIdsProvider =
    NotifierProvider<SelectedTicketIdsNotifier, Set<String>>(
  SelectedTicketIdsNotifier.new,
);

// Search Query Filter
class TicketSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final ticketSearchQueryProvider =
    NotifierProvider<TicketSearchQueryNotifier, String>(
  TicketSearchQueryNotifier.new,
);

// Status Category Filter (null = all)
class TicketCategoryFilterNotifier extends Notifier<StatusCategory?> {
  @override
  StatusCategory? build() => null;

  void setCategory(StatusCategory? cat) => state = cat;
}

final ticketCategoryFilterProvider =
    NotifierProvider<TicketCategoryFilterNotifier, StatusCategory?>(
  TicketCategoryFilterNotifier.new,
);

// Priority Filter (null = all)
class TicketPriorityFilterNotifier extends Notifier<CardPriority?> {
  @override
  CardPriority? build() => null;

  void setPriority(CardPriority? prio) => state = prio;
}

final ticketPriorityFilterProvider =
    NotifierProvider<TicketPriorityFilterNotifier, CardPriority?>(
  TicketPriorityFilterNotifier.new,
);

// Active Saved View ID Filter
class SelectedSavedViewIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setViewId(String? id) => state = id;
}

final selectedSavedViewIdProvider =
    NotifierProvider<SelectedSavedViewIdNotifier, String?>(
  SelectedSavedViewIdNotifier.new,
);

// Saved Views list
final savedViewsListProvider =
    FutureProvider.autoDispose<List<SavedViewDto>>((ref) async {
  final repo = ref.watch(savedViewRepositoryProvider);
  return await repo.getAll();
});

// My Tasks AsyncNotifier
class MyTasksNotifier extends AsyncNotifier<List<TicketDto>> {
  @override
  Future<List<TicketDto>> build() async {
    final repo = ref.watch(ticketRepositoryProvider);
    return await repo.getMine();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(ticketRepositoryProvider);
      return await repo.getMine();
    });
  }

  Future<void> changeTicketStatus(String ticketId, String statusId) async {
    final repo = ref.read(ticketRepositoryProvider);
    await repo.changeStatus(ticketId, statusId);
    await refresh();
  }

  Future<void> batchChangeStatus(Set<String> ticketIds, String statusId) async {
    final repo = ref.read(ticketRepositoryProvider);
    for (final id in ticketIds) {
      await repo.changeStatus(id, statusId);
    }
    ref.read(selectedTicketIdsProvider.notifier).clear();
    await refresh();
  }

  Future<void> batchMoveToSprint(Set<String> ticketIds, String? sprintId) async {
    final repo = ref.read(ticketRepositoryProvider);
    for (final id in ticketIds) {
      await repo.moveToSprint(id, sprintId);
    }
    ref.read(selectedTicketIdsProvider.notifier).clear();
    await refresh();
  }

  Future<void> batchDelete(Set<String> ticketIds) async {
    final repo = ref.read(ticketRepositoryProvider);
    for (final id in ticketIds) {
      await repo.deleteTicket(id);
    }
    ref.read(selectedTicketIdsProvider.notifier).clear();
    await refresh();
  }
}

final myTasksProvider =
    AsyncNotifierProvider<MyTasksNotifier, List<TicketDto>>(
  MyTasksNotifier.new,
);

// Project Backlog provider
final projectBacklogProvider =
    FutureProvider.family.autoDispose<List<TicketDto>, String>((ref, projectId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getBacklog(projectId);
});

// Sprint Tickets provider
final sprintTicketsProvider =
    FutureProvider.family.autoDispose<List<TicketDto>, String>((ref, sprintId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getBySprint(sprintId);
});

// Currently selected ticket for Split Inspector / Detail View
class SelectedTicketDetailIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
  void clear() => state = null;
}

final selectedTicketDetailIdProvider =
    NotifierProvider<SelectedTicketDetailIdNotifier, String?>(
  SelectedTicketDetailIdNotifier.new,
);

// Ticket Detail provider
final ticketDetailProvider =
    FutureProvider.family.autoDispose<TicketDto, String>((ref, ticketId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getById(ticketId);
});

// Ticket Comments provider
final ticketCommentsProvider =
    FutureProvider.family.autoDispose<List<CommentDto>, String>((ref, ticketId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getComments(ticketId);
});

// Ticket Attachments provider
final ticketAttachmentsProvider =
    FutureProvider.family.autoDispose<List<AttachmentDto>, String>((ref, ticketId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getAttachments(ticketId);
});

// Ticket History / Audit provider
final ticketHistoryProvider =
    FutureProvider.family.autoDispose<List<TicketHistoryEntryDto>, String>((ref, ticketId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return await repo.getHistory(ticketId);
});

// Ticket Subtasks provider (real child tickets where parentTicketId == parent.id)
final ticketSubtasksProvider = FutureProvider.family
    .autoDispose<List<TicketDto>, TicketDto>((ref, parent) async {
  final backlog =
      await ref.watch(projectBacklogProvider(parent.projectId).future);
  final sprintTickets = parent.sprintId != null
      ? await ref.watch(sprintTicketsProvider(parent.sprintId!).future)
      : const <TicketDto>[];

  final seen = <String>{};
  final subtasks = <TicketDto>[];
  for (final t in [...backlog, ...sprintTickets]) {
    if (t.parentTicketId == parent.id && seen.add(t.id)) {
      subtasks.add(t);
    }
  }
  return subtasks;
});

// Ticket by Ref provider (e.g. "DISC-14" or ID)
final ticketByRefProvider =
    FutureProvider.family.autoDispose<TicketDto, String>((ref, refString) async {
  final repo = ref.watch(ticketRepositoryProvider);
  final parts = refString.split('-');
  if (parts.length >= 2) {
    final key = parts[0];
    final number = int.tryParse(parts[1]) ?? 0;
    return await repo.getByRef(key, number);
  }
  return await repo.getById(refString);
});
