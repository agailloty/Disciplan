import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import '../data/project_repository.dart';

final projectRepositoryProvider = Provider<IProjectRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  return ProjectRepository(client);
});

class SelectedProjectIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedProjectIdProvider =
    NotifierProvider<SelectedProjectIdNotifier, String?>(SelectedProjectIdNotifier.new);

final projectsListProvider = FutureProvider<List<ProjectSummaryDto>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  final projects = await repo.getAll();

  // Si aucun projet sélectionné et qu'il y a des projets, sélectionne le premier automatiquement
  final current = ref.read(selectedProjectIdProvider);
  if (current == null && projects.isNotEmpty) {
    Future.microtask(() {
      ref.read(selectedProjectIdProvider.notifier).select(projects.first.id);
    });
  }

  return projects;
});

final projectDetailByIdProvider =
    FutureProvider.family<ProjectDetailDto?, String>((ref, projectId) async {
  if (projectId.isEmpty) return null;
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getById(projectId);
});

final currentProjectDetailProvider = FutureProvider<ProjectDetailDto?>((ref) async {
  final selectedId = ref.watch(selectedProjectIdProvider);
  if (selectedId == null) {
    return null;
  }
  return ref.watch(projectDetailByIdProvider(selectedId).future);
});

// Helper pour générer automatiquement une clé de projet (2 à 6 caractères)
String generateProjectKey(String name) {
  if (name.trim().isEmpty) return '';

  final sanitized = name
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]'), 'A')
      .replaceAll(RegExp(r'[ÈÉÊË]'), 'E')
      .replaceAll(RegExp(r'[ÌÍÎÏ]'), 'I')
      .replaceAll(RegExp(r'[ÒÓÔÕÖ]'), 'O')
      .replaceAll(RegExp(r'[ÙÚÛÜ]'), 'U')
      .replaceAll(RegExp(r'[Ç]'), 'C')
      .replaceAll(RegExp(r'[^A-Z0-9\s]'), '');

  final words = sanitized.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  if (words.isEmpty) return 'PRJ';

  if (words.length == 1) {
    final word = words.first;
    return word.length >= 4 ? word.substring(0, 4) : word.padRight(2, 'X');
  }

  // Acronyme des mots
  final initials = words.map((w) => w[0]).join();
  if (initials.length >= 2) {
    return initials.length > 5 ? initials.substring(0, 5) : initials;
  }

  final first = words.first;
  return first.substring(0, first.length.clamp(2, 4));
}
