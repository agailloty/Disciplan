import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/create_sprint_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'desktop_sprint_kanban_view.dart';
import 'mobile_sprint_kanban_view.dart';

class KanbanAdaptiveScreen extends ConsumerStatefulWidget {
  const KanbanAdaptiveScreen({super.key});

  @override
  ConsumerState<KanbanAdaptiveScreen> createState() => _KanbanAdaptiveScreenState();
}

class _KanbanAdaptiveScreenState extends ConsumerState<KanbanAdaptiveScreen> {
  String? _selectedSprintId;

  @override
  Widget build(BuildContext context) {
    final currentProject = ref.watch(currentProjectDetailProvider).value;

    if (currentProject == null) {
      return const Scaffold(
        backgroundColor: NeoColors.surfaceContainerLowest,
        body: Center(
          child: Text('Sélectionnez un projet pour afficher son tableau Kanban.'),
        ),
      );
    }

    final sprintsAsync = ref.watch(projectSprintsProvider(currentProject.id));

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: sprintsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeoColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Erreur: $err'),
        ),
        data: (sprints) {
          final activeSprint = sprints
              .where((s) => s.status == SprintStatus.active)
              .firstOrNull;
          final plannedSprint = sprints
              .where((s) => s.status == SprintStatus.planned)
              .firstOrNull;

          // Resolve which sprint to display if user selected one explicitly
          final selectedSprint = _selectedSprintId != null
              ? sprints.where((s) => s.id == _selectedSprintId).firstOrNull
              : activeSprint;

          if (selectedSprint == null) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(NeoSpacing.spaceLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NeoColors.kineticAmber.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.view_kanban_outlined,
                          size: 40,
                          color: NeoColors.secondary,
                        ),
                      ),
                      const SizedBox(height: NeoSpacing.spaceMd),
                      Text('Aucun cycle actif', style: NeoTypography.headlineMd),
                      const SizedBox(height: NeoSpacing.spaceSm),
                      Text(
                        'Démarrez un cycle planifié, prévisualisez son Kanban ou créez un nouveau sprint.',
                        textAlign: TextAlign.center,
                        style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                      ),
                      const SizedBox(height: NeoSpacing.spaceLg),
                      if (plannedSprint != null) ...[
                        Wrap(
                          spacing: NeoSpacing.spaceSm,
                          runSpacing: NeoSpacing.spaceSm,
                          alignment: WrapAlignment.center,
                          children: [
                            NeoButton(
                              label: 'Démarrer "${plannedSprint.name}"',
                              onPressed: () async {
                                final now = DateTime.now();
                                await ref.read(sprintRepositoryProvider).start(
                                      plannedSprint.id,
                                      StartSprintRequest(
                                        startDate: plannedSprint.startDate ?? now,
                                        endDate: plannedSprint.endDate ??
                                            now.add(const Duration(days: 14)),
                                      ),
                                    );
                                ref.invalidate(projectSprintsProvider(currentProject.id));
                              },
                            ),
                            NeoButton(
                              label: 'Ouvrir le Kanban de "${plannedSprint.name}"',
                              variant: NeoButtonVariant.secondary,
                              onPressed: () {
                                setState(() => _selectedSprintId = plannedSprint.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: NeoSpacing.spaceSm),
                      ],
                      Wrap(
                        spacing: NeoSpacing.spaceSm,
                        runSpacing: NeoSpacing.spaceSm,
                        alignment: WrapAlignment.center,
                        children: [
                          NeoButton(
                            label: 'Créer un nouveau sprint',
                            variant: NeoButtonVariant.secondary,
                            onPressed: () {
                              CreateSprintModal.show(context, projectId: currentProject.id);
                            },
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/backlog'),
                            icon: const Icon(Icons.inbox_outlined, size: 16),
                            label: const Text('Voir le Backlog'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < NeoSpacing.mobileBreakpoint) {
                return MobileSprintKanbanView(sprint: selectedSprint);
              }
              return DesktopSprintKanbanView(
                sprint: selectedSprint,
                availableSprints: sprints,
                onSelectSprint: (sprint) {
                  setState(() => _selectedSprintId = sprint.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
