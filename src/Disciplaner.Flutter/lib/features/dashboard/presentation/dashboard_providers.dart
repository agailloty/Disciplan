import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';

/// Status categories shown in the "My tickets" section of the dashboard.
/// Defaults to To Do + In Progress; persisted in SharedPreferences so the
/// user's configuration survives restarts.
class DashboardStatusFilterNotifier extends Notifier<Set<StatusCategory>> {
  static const String _storageKey = 'dashboard.myTickets.statusCategories';
  static const Set<StatusCategory> _defaultCategories = {
    StatusCategory.backlog,
    StatusCategory.inProgress,
  };

  bool _loaded = false;

  @override
  Set<StatusCategory> build() => Set<StatusCategory>.from(_defaultCategories);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey);
      if (stored == null || stored.isEmpty) return;
      final parsed = stored
          .map((raw) => int.tryParse(raw))
          .whereType<int>()
          .map((value) => StatusCategory.values
              .where((c) => c.value == value)
              .firstOrNull)
          .whereType<StatusCategory>()
          .toSet();
      if (parsed.isNotEmpty) {
        state = parsed;
      }
    } catch (_) {
      // Preferences unavailable: keep the default configuration.
    }
  }

  void toggle(StatusCategory category) {
    final next = Set<StatusCategory>.from(state);
    if (!next.add(category)) {
      // Never leave the filter empty: always keep at least one category.
      if (next.length > 1) next.remove(category);
    }
    state = next;
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _storageKey,
        state.map((c) => c.value.toString()).toList(),
      );
    } catch (_) {
      // Persistence is best-effort.
    }
  }
}

final dashboardStatusFilterProvider =
    NotifierProvider<DashboardStatusFilterNotifier, Set<StatusCategory>>(
  DashboardStatusFilterNotifier.new,
);

/// Tickets assigned to me, restricted to the configured status categories.
final dashboardMyTicketsProvider = Provider<List<TicketDto>>((ref) {
  final tasks = ref.watch(myTasksProvider).asData?.value ?? const [];
  final categories = ref.watch(dashboardStatusFilterProvider);
  return tasks
      .where((t) => categories.contains(t.status.category))
      .toList();
});
