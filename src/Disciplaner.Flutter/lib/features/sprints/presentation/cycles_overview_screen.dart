import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/sprint_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'sprint_providers.dart';
import 'widgets/create_sprint_modal.dart';
import 'widgets/sprint_metrics_header.dart';

class CyclesOverviewScreen extends ConsumerWidget {
  const CyclesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentProject = ref.watch(currentProjectDetailProvider).value;
    if (currentProject == null) {
      return Scaffold(
        backgroundColor: NeoColors.surfaceContainerLowest,
        body: Center(
          child: Text(l10n.sprintSelectProject),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: NeoColors.error),
              const SizedBox(height: NeoSpacing.spaceSm),
              Text(l10n.sprintLoadError(err.toString()), style: NeoTypography.bodyMd),
              const SizedBox(height: NeoSpacing.spaceMd),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(projectSprintsProvider(currentProject.id)),
                child: Text(l10n.attachmentRetry),
              ),
            ],
          ),
        ),
        data: (sprints) {
          final activeSprint = sprints
              .where((s) => s.status == SprintStatus.active)
              .firstOrNull;
          final plannedSprints = sprints
              .where((s) => s.status == SprintStatus.planned)
              .toList();
          final closedSprints = sprints
              .where((s) => s.status == SprintStatus.closed)
              .toList();

          return RefreshIndicator(
            color: NeoColors.primary,
            onRefresh: () async {
              ref.invalidate(projectSprintsProvider(currentProject.id));
            },
            child: ListView(
              padding: const EdgeInsets.all(NeoSpacing.spaceLg),
              children: [
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.sprintCyclesTitle, style: NeoTypography.headlineLg),
                        const SizedBox(height: 2),
                        Text(
                          l10n.sprintCyclesSubtitle(currentProject.name),
                          style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                        ),
                      ],
                    ),
                    NeoButton(
                      label: l10n.sprintCreateCycle,
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () {
                        CreateSprintModal.show(context, projectId: currentProject.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: NeoSpacing.spaceLg),

                // Active Sprint Section
                if (activeSprint != null) ...[
                  Consumer(
                    builder: (context, ref, _) {
                      final metricsAsync =
                          ref.watch(sprintMetricsProvider(activeSprint.id));
                      final metrics = metricsAsync.value;

                      return SprintMetricsHeader(
                        sprint: activeSprint,
                        metrics: metrics,
                        onClose: () async {
                          await ref
                              .read(sprintRepositoryProvider)
                              .close(activeSprint.id);
                          ref.invalidate(
                            projectSprintsProvider(currentProject.id),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: NeoSpacing.spaceXl),
                ],

                // Planned Sprints Section
                _buildSectionHeader(l10n.sprintPlannedCyclesSection.toUpperCase(), plannedSprints.length),
                const SizedBox(height: NeoSpacing.spaceSm),
                if (plannedSprints.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceMd),
                    child: Text(
                      l10n.sprintNoPlannedCycles,
                      style: NeoTypography.bodySm.copyWith(
                        color: NeoColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...plannedSprints.map((s) => _buildSprintCard(context, ref, s, currentProject.id)),

                const SizedBox(height: NeoSpacing.spaceXl),

                // Closed Sprints Section
                _buildSectionHeader(l10n.sprintClosedCyclesSection.toUpperCase(), closedSprints.length),
                const SizedBox(height: NeoSpacing.spaceSm),
                if (closedSprints.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: NeoSpacing.spaceMd),
                    child: Text(
                      l10n.sprintNoClosedCycles,
                      style: NeoTypography.bodySm.copyWith(
                        color: NeoColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...closedSprints.map((s) => _buildSprintCard(context, ref, s, currentProject.id)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: NeoColors.muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: NeoSpacing.spaceSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: NeoColors.surfaceContainerHigh,
            borderRadius: NeoSpacing.roundedSm,
          ),
          child: Text(
            '$count',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NeoColors.muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSprintCard(
    BuildContext context,
    WidgetRef ref,
    SprintDto sprint,
    String projectId,
  ) {
    final isPlanned = sprint.status == SprintStatus.planned;
    final l10n = context.l10n;
    final formatter = DateFormat(
      'd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );
    final datesStr = (sprint.startDate != null && sprint.endDate != null)
        ? '${formatter.format(sprint.startDate!)} – ${formatter.format(sprint.endDate!)}'
        : l10n.sprintDatesUndefined;

    return Container(
      margin: const EdgeInsets.only(bottom: NeoSpacing.spaceSm),
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceSm,
      ),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isPlanned ? NeoColors.muted : NeoColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: NeoSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sprint.name,
                  style: NeoTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  datesStr,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: NeoColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: NeoColors.surfaceContainerLowest,
              borderRadius: NeoSpacing.roundedSm,
              border: Border.all(color: NeoColors.borderWhisper),
            ),
            child: Text(
              l10n.sprintTaskCount(sprint.ticketCount),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: NeoColors.onSurface,
              ),
            ),
          ),
          if (isPlanned) ...[
            const SizedBox(width: NeoSpacing.spaceSm),
            NeoButton(
              label: l10n.sprintStart,
              isDense: true,
              onPressed: () async {
                final now = DateTime.now();
                await ref.read(sprintRepositoryProvider).start(
                      sprint.id,
                      StartSprintRequest(
                        startDate: sprint.startDate ?? now,
                        endDate: sprint.endDate ?? now.add(const Duration(days: 14)),
                      ),
                    );
                ref.invalidate(projectSprintsProvider(projectId));
              },
            ),
          ],
        ],
      ),
    );
  }
}
