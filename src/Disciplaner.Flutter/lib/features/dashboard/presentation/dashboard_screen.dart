import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/l10n/enum_l10n.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/core/models/enums.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/models/ticket_models.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_providers.dart';
import 'package:disciplaner_flutter/features/auth/presentation/auth_state.dart';
import 'package:disciplaner_flutter/features/dashboard/presentation/dashboard_providers.dart';
import 'package:disciplaner_flutter/features/projects/presentation/project_providers.dart';
import 'package:disciplaner_flutter/features/shell/presentation/workspace_tabs.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/ticket_providers.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/dense_ticket_row.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/mobile_ticket_detail_sheet.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/widgets/split_inspector_panel.dart';

/// Home dashboard (VS Code welcome page style): one summary rectangle per
/// project, then a flat list of the tickets assigned to me filtered by the
/// status categories I configured (To Do + In Progress by default).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dashboardStatusFilterProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.session : null;
    final projectsAsync = ref.watch(projectsListProvider);
    final projects = projectsAsync.asData?.value ?? const <ProjectSummaryDto>[];
    final tickets = ref.watch(dashboardMyTicketsProvider);
    final categories = ref.watch(dashboardStatusFilterProvider);
    final selectedDetailId = ref.watch(selectedTicketDetailIdProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= NeoSpacing.mobileBreakpoint;

    final mainList = RefreshIndicator(
      color: NeoColors.primary,
      onRefresh: () async => ref.read(myTasksProvider.notifier).refresh(),
      child: ListView(
        padding: NeoSpacing.responsivePagePadding(screenWidth),
        children: [
          // 1. Welcome header (VS Code welcome page)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: NeoColors.kineticAmber.withValues(alpha: 0.14),
                  borderRadius: NeoSpacing.roundedMd,
                ),
                child: const Icon(
                  Icons.home_outlined,
                  size: 20,
                  color: NeoColors.secondary,
                ),
              ),
              const SizedBox(width: NeoSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardGreeting(user?.displayName ?? ''),
                      style: NeoTypography.headlineLg,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.dashboardSubtitle,
                      style:
                          NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceLg),

          // 2. One summary rectangle per project
          _DashboardSectionHeader(
            icon: Icons.folder_copy_outlined,
            title: l10n.dashboardProjectsSection,
            count: projects.length,
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          if (projects.isEmpty)
            _buildEmptyProjectsCard(l10n)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (!isDesktop) {
                  return Column(
                    children: [
                      for (var i = 0; i < projects.length; i++) ...[
                        if (i > 0) const SizedBox(height: NeoSpacing.spaceSm),
                        _DashboardProjectCard(project: projects[i]),
                      ],
                    ],
                  );
                }
                final cols = constraints.maxWidth >= 1080
                    ? 3
                    : (constraints.maxWidth >= 680 ? 2 : 1);
                final gap = NeoSpacing.spaceSm;
                final width = (constraints.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: projects
                      .map((p) => SizedBox(
                            width: width,
                            child: _DashboardProjectCard(project: p),
                          ))
                      .toList(),
                );
              },
            ),
          const SizedBox(height: NeoSpacing.spaceLg),

          // 3. My assigned tickets, filtered by configured statuses
          _DashboardSectionHeader(
            icon: Icons.check_circle_outline,
            title: l10n.dashboardMyTicketsSection,
            count: tickets.length,
            trailing: _buildStatusFilterButton(l10n, categories),
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          Text(
            categories
                .map((c) => c.localizedLabel(l10n))
                .join(' • '),
            style: NeoTypography.labelSm.copyWith(color: NeoColors.muted),
          ),
          const SizedBox(height: NeoSpacing.spaceSm),
          _buildMyTicketsList(l10n, tickets, isDesktop),
          const SizedBox(height: 80),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: NeoColors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(child: mainList),
          if (selectedDetailId != null && isDesktop)
            SplitInspectorPanel(
              ticketId: selectedDetailId,
              onClose: () =>
                  ref.read(selectedTicketDetailIdProvider.notifier).clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyProjectsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(NeoSpacing.spaceXl),
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLow,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Center(
        child: Text(
          l10n.dashboardNoProjects,
          style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
        ),
      ),
    );
  }

  Widget _buildStatusFilterButton(
    AppLocalizations l10n,
    Set<StatusCategory> categories,
  ) {
    return PopupMenuButton<int>(
      tooltip: l10n.dashboardStatusFilterTooltip,
      shape: RoundedRectangleBorder(
        borderRadius: NeoSpacing.roundedMd,
        side: const BorderSide(color: NeoColors.borderWhisper),
      ),
      itemBuilder: (context) => [
        for (final category in StatusCategory.values)
          PopupMenuItem(
            value: category.value,
            child: Row(
              children: [
                Icon(
                  categories.contains(category)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: categories.contains(category)
                      ? NeoColors.primary
                      : NeoColors.muted,
                ),
                const SizedBox(width: 8),
                Text(category.localizedLabel(l10n)),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        final category = StatusCategory.values
            .where((c) => c.value == value)
            .firstOrNull;
        if (category != null) {
          ref.read(dashboardStatusFilterProvider.notifier).toggle(category);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLowest,
          borderRadius: NeoSpacing.roundedSm,
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 13, color: NeoColors.secondary),
            const SizedBox(width: 5),
            Text(
              l10n.dashboardStatusFilterTooltip,
              style: NeoTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color: NeoColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTicketsList(
    AppLocalizations l10n,
    List<TicketDto> tickets,
    bool isDesktop,
  ) {
    if (tickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(NeoSpacing.spaceXl),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLowest,
          borderRadius: NeoSpacing.roundedLg,
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Center(
          child: Text(
            l10n.dashboardNoTickets,
            style: NeoTypography.bodyMd.copyWith(color: NeoColors.muted),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: NeoColors.surfaceContainerLowest,
        borderRadius: NeoSpacing.roundedLg,
        border: Border.all(color: NeoColors.borderWhisper),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tickets.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: NeoColors.borderWhisper),
            DenseTicketRow(
              ticket: tickets[i],
              onTap: () {
                if (isDesktop) {
                  ref
                      .read(selectedTicketDetailIdProvider.notifier)
                      .select(tickets[i].id);
                } else {
                  MobileTicketDetailSheet.show(context, tickets[i].id);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Widget? trailing;

  const _DashboardSectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: NeoSpacing.spaceSm,
      runSpacing: NeoSpacing.spaceXs,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: NeoColors.secondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: NeoTypography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: NeoColors.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: NeoColors.surfaceContainerHigh,
                borderRadius: NeoSpacing.roundedFull,
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.primary,
                ),
              ),
            ),
          ],
        ),
        ?trailing,
      ],
    );
  }
}

class _DashboardProjectCard extends ConsumerWidget {
  final ProjectSummaryDto project;

  const _DashboardProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return InkWell(
      onTap: () => openProjectTab(
        context,
        ref,
        projectId: project.id,
        title: project.name,
        projectKey: project.key,
      ),
      borderRadius: NeoSpacing.roundedMd,
      child: Container(
        padding: const EdgeInsets.all(NeoSpacing.spaceMd),
        decoration: BoxDecoration(
          color: NeoColors.surfaceContainerLow,
          borderRadius: NeoSpacing.roundedMd,
          border: Border.all(color: NeoColors.borderWhisper),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: NeoColors.kineticAmber.withValues(alpha: 0.16),
                    borderRadius: NeoSpacing.roundedSm,
                  ),
                  child: Text(
                    project.key,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NeoTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NeoColors.onSurface,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: NeoColors.subdued,
                ),
              ],
            ),
            if (project.description != null &&
                project.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NeoTypography.labelSm.copyWith(
                  color: NeoColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.ticketsProjectTileSummary(
                project.ticketCount,
                project.sprintCount,
                project.isOwner ? l10n.ticketsOwner : l10n.roleMember,
              ),
              style: NeoTypography.labelSm.copyWith(
                color: NeoColors.muted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: NeoSpacing.spaceSm),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoColors.surfaceContainerLowest,
                    borderRadius: NeoSpacing.roundedSm,
                    border: Border.all(color: NeoColors.borderWhisper),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new,
                          size: 12, color: NeoColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.dashboardOpenProject,
                        style: NeoTypography.labelSm.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: NeoColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
