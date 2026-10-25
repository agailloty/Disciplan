import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/cycles_overview_screen.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/sprint_providers.dart';
import 'package:disciplaner_flutter/features/sprints/presentation/widgets/create_sprint_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'desktop_sprint_kanban_view.dart';
import 'mobile_sprint_kanban_view.dart';

/// Vue affichée dans l'onglet Sprint sur mobile : le board kanban du sprint
/// actif ou la vue Cycles (anciennement onglet Cycles dédié).
enum _MobileSprintView { board, cycles }

class KanbanAdaptiveScreen extends ConsumerStatefulWidget {
  const KanbanAdaptiveScreen({super.key});

  @override
  ConsumerState<KanbanAdaptiveScreen> createState() => _KanbanAdaptiveScreenState();
}

class _KanbanAdaptiveScreenState extends ConsumerState<KanbanAdaptiveScreen> {
  String? _selectedSprintId;
  _MobileSprintView _mobileView = _MobileSprintView.board;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentProject = ref.watch(currentProjectDetailProvider).value;

    if (currentProject == null) {
      return Scaffold(
        backgroundColor: NeoColors.surfaceContainerLowest,
        body: Center(
          child: Text(l10n.kanbanSelectProject),
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
          child: Text(l10n.kanbanErrorWithDetail(err.toString())),
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

          Widget buildNoSprintView() {
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
                      Text(l10n.sprintNoActive, style: NeoTypography.headlineMd),
                      const SizedBox(height: NeoSpacing.spaceSm),
                      Text(
                        l10n.sprintNoActiveCycleDesc,
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
                              label: l10n.kanbanStartNamed(plannedSprint.name),
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
                              label: l10n.kanbanOpenSprintBoard(plannedSprint.name),
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
                            label: l10n.sprintCreateButton,
                            variant: NeoButtonVariant.secondary,
                            onPressed: () {
                              CreateSprintModal.show(context, projectId: currentProject.id);
                            },
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/backlog'),
                            icon: const Icon(Icons.inbox_outlined, size: 16),
                            label: Text(l10n.kanbanViewBacklog),
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
                final boardView = selectedSprint != null
                    ? MobileSprintKanbanView(sprint: selectedSprint)
                    : buildNoSprintView();
                return Column(
                  children: [
                    _SprintMobileViewToggle(
                      selected: _mobileView,
                      onChanged: (view) => setState(() => _mobileView = view),
                    ),
                    Expanded(
                      child: _mobileView == _MobileSprintView.cycles
                          ? const CyclesOverviewBody()
                          : boardView,
                    ),
                  ],
                );
              }
              if (selectedSprint == null) {
                return buildNoSprintView();
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

/// Bascule mobile entre le board du sprint actif et la vue Cycles.
class _SprintMobileViewToggle extends StatelessWidget {
  final _MobileSprintView selected;
  final ValueChanged<_MobileSprintView> onChanged;

  const _SprintMobileViewToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceXs,
      ),
      decoration: const BoxDecoration(
        color: NeoColors.surface,
        border: Border(
          bottom: BorderSide(color: NeoColors.borderWhisper, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildChip(
              context,
              label: l10n.sprintLabel,
              view: _MobileSprintView.board,
            ),
          ),
          const SizedBox(width: NeoSpacing.spaceXs),
          Expanded(
            child: _buildChip(
              context,
              label: l10n.shellMobileCycles,
              view: _MobileSprintView.cycles,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required _MobileSprintView view,
  }) {
    final isSelected = selected == view;
    final color = isSelected ? NeoColors.primary : NeoColors.muted;
    return InkWell(
      onTap: () => onChanged(view),
      borderRadius: NeoSpacing.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? NeoColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: NeoSpacing.roundedSm,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: NeoTypography.labelSm.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
