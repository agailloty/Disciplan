import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/errors/app_failure.dart';
import 'package:disciplaner_flutter/core/l10n/failure_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'create_project_modal.dart';
import 'project_providers.dart';

class MobileProjectsView extends ConsumerStatefulWidget {
  const MobileProjectsView({super.key});

  @override
  ConsumerState<MobileProjectsView> createState() => _MobileProjectsViewState();
}

class _MobileProjectsViewState extends ConsumerState<MobileProjectsView> {
  String _activeFilter = 'all'; // 'all', 'owner', 'member'
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectsAsync = ref.watch(projectsListProvider);
    final currentProject = ref.watch(currentProjectDetailProvider).value;
    final selectedId = ref.watch(selectedProjectIdProvider) ?? currentProject?.id;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= NeoSpacing.mobileBreakpoint;

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: RefreshIndicator(
        color: NeoColors.primary,
        onRefresh: () async {
          ref.invalidate(projectsListProvider);
        },
        child: ListView(
          padding: NeoSpacing.responsivePagePadding(screenWidth),
          children: [
            // 1. Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: NeoSpacing.spaceMd,
              runSpacing: NeoSpacing.spaceSm,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                            borderRadius: NeoSpacing.roundedSm,
                          ),
                          child: Text(
                            l10n.projPortfolio.toUpperCase(),
                            style: NeoTypography.codeSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.secondary,
                            ),
                          ),
                        ),
                        if (currentProject != null) ...[
                          const SizedBox(width: NeoSpacing.spaceSm),
                          Text('•', style: NeoTypography.bodySm.copyWith(color: NeoColors.muted)),
                          const SizedBox(width: NeoSpacing.spaceSm),
                          Text(
                            l10n.projActiveSpace(currentProject.key, currentProject.name),
                            style: NeoTypography.labelSm.copyWith(
                              color: NeoColors.emerald,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceXs),
                    Text(l10n.projAllMyProjects, style: NeoTypography.headlineLg),
                    const SizedBox(height: 2),
                    Text(
                      l10n.projSelectSubtitle,
                      style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/my-tasks'),
                      icon: const Icon(Icons.dashboard_customize_outlined, size: 16),
                      label: Text(l10n.projDashboardGeneral),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeoColors.onSurface,
                        side: const BorderSide(color: NeoColors.borderWhisper),
                        shape: RoundedRectangleBorder(
                          borderRadius: NeoSpacing.roundedMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: NeoSpacing.spaceSm),
                    NeoButton(
                      label: l10n.projectCreateTitle,
                      icon: const Icon(Icons.add, size: 16),
                      onPressed: () => CreateProjectModal.show(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: NeoSpacing.spaceLg),

            projectsAsync.when(
              data: (projects) {
                final totalTickets = projects.fold<int>(
                  0,
                  (sum, p) => sum + p.ticketCount,
                );
                final totalSprints = projects.fold<int>(
                  0,
                  (sum, p) => sum + p.sprintCount,
                );
                final ownedCount = projects.where((p) => p.isOwner).length;
                final memberCount = projects.where((p) => !p.isOwner).length;

                final filteredProjects = projects.where((p) {
                  if (_activeFilter == 'owner' && !p.isOwner) return false;
                  if (_activeFilter == 'member' && p.isOwner) return false;
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return p.name.toLowerCase().contains(q) ||
                        p.key.toLowerCase().contains(q) ||
                        (p.description?.toLowerCase().contains(q) ?? false);
                  }
                  return true;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Global Projects KPI Strip
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryMetric(
                            label: l10n.projActiveProjects,
                            value: '${projects.length}',
                            icon: Icons.folder_copy_outlined,
                            color: NeoColors.primary,
                          ),
                        ),
                        const SizedBox(width: NeoSpacing.spaceSm),
                        Expanded(
                          child: _buildSummaryMetric(
                            label: l10n.projTotalTickets,
                            value: '$totalTickets',
                            icon: Icons.confirmation_number_outlined,
                            color: NeoColors.statusBlue,
                          ),
                        ),
                        const SizedBox(width: NeoSpacing.spaceSm),
                        Expanded(
                          child: _buildSummaryMetric(
                            label: l10n.projSprintsCycles,
                            value: '$totalSprints',
                            icon: Icons.timelapse_outlined,
                            color: NeoColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 3. Filter Pills & Search
                    Wrap(
                      spacing: NeoSpacing.spaceSm,
                      runSpacing: NeoSpacing.spaceSm,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterPill(l10n.projAllMyProjects, 'all', projects.length),
                              const SizedBox(width: NeoSpacing.spaceSm),
                              _buildFilterPill(l10n.projOwner, 'owner', ownedCount),
                              const SizedBox(width: NeoSpacing.spaceSm),
                              _buildFilterPill(l10n.projFilterMember, 'member', memberCount),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: isDesktop ? 280 : double.infinity,
                          height: 36,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            style: NeoTypography.bodySm,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: l10n.projSearchHint,
                              hintStyle: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                              prefixIcon: const Icon(Icons.search, size: 16, color: NeoColors.muted),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 14),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: NeoColors.surfaceContainerLow,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: NeoSpacing.roundedMd,
                                borderSide: const BorderSide(color: NeoColors.borderWhisper),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: NeoSpacing.roundedMd,
                                borderSide: const BorderSide(color: NeoColors.borderWhisper),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoSpacing.spaceLg),

                    // 4. Project Cards Grid / List
                    if (projects.isEmpty)
                      NeoCard(
                        padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                        child: Column(
                          children: [
                            const Icon(Icons.folder_open, size: 44, color: NeoColors.subdued),
                            const SizedBox(height: NeoSpacing.spaceSm),
                            Text(l10n.projectEmpty, style: NeoTypography.headlineSm),
                            const SizedBox(height: 4),
                            Text(
                              l10n.projEmptyHint,
                              textAlign: TextAlign.center,
                              style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                            ),
                            const SizedBox(height: NeoSpacing.spaceMd),
                            NeoButton(
                              label: l10n.projCreateNew,
                              onPressed: () => CreateProjectModal.show(context),
                            ),
                          ],
                        ),
                      )
                    else if (filteredProjects.isEmpty)
                      NeoCard(
                        padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                        child: Center(
                          child: Text(
                            l10n.projNoMatch,
                            style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                          ),
                        ),
                      )
                    else if (isDesktop)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth >= 1020 ? 3 : 2;
                          final spacing = NeoSpacing.spaceMd;
                          final itemWidth =
                              (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                                  crossAxisCount;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: filteredProjects.map((project) {
                              final isSelected = project.id == selectedId;
                              return SizedBox(
                                width: itemWidth,
                                child: _buildProjectCard(context, project, isSelected),
                              );
                            }).toList(),
                          );
                        },
                      )
                    else
                      Column(
                        children: filteredProjects.map((project) {
                          final isSelected = project.id == selectedId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: NeoSpacing.spaceMd),
                            child: _buildProjectCard(context, project, isSelected),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, _) => NeoCard(
                padding: const EdgeInsets.all(NeoSpacing.spaceMd),
                child: Text(
                  l10n.projLoadError(
                    err is AppFailure ? localizedFailureMessage(l10n, err) : err.toString(),
                  ),
                  style: const TextStyle(color: NeoColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoSpacing.spaceMd,
        vertical: NeoSpacing.spaceSm + 2,
      ),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedMd,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: NeoSpacing.roundedSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: NeoSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: NeoTypography.titleMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, String key, int count) {
    final isActive = _activeFilter == key;
    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: NeoSpacing.roundedFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? NeoColors.primary : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedFull,
          border: Border.all(
            color: isActive ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                color: isActive ? Colors.white : NeoColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? NeoColors.surfaceContainerLowest
                    : NeoColors.surfaceContainerHigh,
                borderRadius: NeoSpacing.roundedFull,
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? NeoColors.primary : NeoColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    ProjectSummaryDto project,
    bool isSelected,
  ) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(
          color: isSelected ? NeoColors.primary : NeoColors.borderWhisper,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: NeoSpacing.roundedLg,
        onTap: () {
          ref.read(selectedProjectIdProvider.notifier).select(project.id);
          context.go('/backlog');
        },
        child: Padding(
          padding: const EdgeInsets.all(NeoSpacing.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NeoColors.kineticAmber.withValues(alpha: 0.22)
                          : NeoColors.surfaceContainerLow,
                      borderRadius: NeoSpacing.roundedSm,
                      border: Border.all(
                        color: isSelected
                            ? NeoColors.kineticAmber
                            : NeoColors.borderWhisper,
                      ),
                    ),
                    child: Text(
                      project.key,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: NeoColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: NeoTypography.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          project.isOwner ? l10n.projOwner : l10n.projMember,
                          style: NeoTypography.labelSm.copyWith(
                            color: NeoColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: NeoColors.emerald.withValues(alpha: 0.14),
                        borderRadius: NeoSpacing.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: NeoColors.emerald,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.projActiveSpaceBadge.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceSm),
              Text(
                (project.description != null && project.description!.isNotEmpty)
                    ? project.description!
                    : l10n.projCardDescriptionFallback,
                style: NeoTypography.bodySm.copyWith(
                  color: NeoColors.muted,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: NeoSpacing.spaceMd),

              // Metrics row
              Row(
                children: [
                  _buildMiniBadge(
                    icon: Icons.confirmation_number_outlined,
                    label: l10n.projectTicketCount(project.ticketCount),
                  ),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  _buildMiniBadge(
                    icon: Icons.timelapse_outlined,
                    label: l10n.projectSprintCount(project.sprintCount),
                  ),
                ],
              ),
              const SizedBox(height: NeoSpacing.spaceMd),
              const Divider(height: 1, color: NeoColors.borderWhisper),
              const SizedBox(height: NeoSpacing.spaceSm),

              // Direct workspace entry actions
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildQuickActionChip(
                    icon: Icons.inbox_outlined,
                    label: l10n.projectBacklog,
                    isPrimary: true,
                    onTap: () {
                      ref.read(selectedProjectIdProvider.notifier).select(project.id);
                      context.go('/backlog');
                    },
                  ),
                  _buildQuickActionChip(
                    icon: Icons.view_kanban_outlined,
                    label: l10n.sprintViewKanban,
                    onTap: () {
                      ref.read(selectedProjectIdProvider.notifier).select(project.id);
                      context.go('/kanban');
                    },
                  ),
                  _buildQuickActionChip(
                    icon: Icons.autorenew_rounded,
                    label: l10n.projCycles,
                    onTap: () {
                      ref.read(selectedProjectIdProvider.notifier).select(project.id);
                      context.go('/cycles');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: NeoColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: NeoTypography.labelSm.copyWith(
              fontSize: 11,
              color: NeoColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: NeoSpacing.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isPrimary ? NeoColors.primary : NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedSm,
          border: Border.all(
            color: isPrimary ? NeoColors.primary : NeoColors.borderWhisper,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isPrimary ? Colors.white : NeoColors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: NeoTypography.labelSm.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : NeoColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
