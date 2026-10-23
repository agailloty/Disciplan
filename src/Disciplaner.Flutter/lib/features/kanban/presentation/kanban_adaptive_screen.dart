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
import 'desktop_sprint_kanban_view.dart';
import 'mobile_sprint_kanban_view.dart';

class KanbanAdaptiveScreen extends ConsumerWidget {
  const KanbanAdaptiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          if (activeSprint == null) {
            final plannedSprint = sprints
                .where((s) => s.status == SprintStatus.planned)
                .firstOrNull;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.view_kanban_outlined,
                    size: 48,
                    color: NeoColors.muted,
                  ),
                  const SizedBox(height: NeoSpacing.spaceMd),
                  Text('Aucun cycle actif', style: NeoTypography.headlineMd),
                  const SizedBox(height: NeoSpacing.spaceSm),
                  Text(
                    'Démarrez un cycle planifié ou créez un nouveau sprint pour afficher le Kanban.',
                    style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                  ),
                  const SizedBox(height: NeoSpacing.spaceLg),
                  if (plannedSprint != null) ...[
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
                    const SizedBox(height: NeoSpacing.spaceSm),
                  ],
                  NeoButton(
                    label: 'Créer un nouveau sprint',
                    variant: NeoButtonVariant.secondary,
                    onPressed: () {
                      CreateSprintModal.show(context, projectId: currentProject.id);
                    },
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < NeoSpacing.mobileBreakpoint) {
                return MobileSprintKanbanView(sprint: activeSprint);
              }
              return DesktopSprintKanbanView(sprint: activeSprint);
            },
          );
        },
      ),
    );
  }
}
