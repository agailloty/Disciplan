import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/app/theme/neo_typography.dart';
import 'package:disciplaner_flutter/core/models/project_models.dart';
import 'package:disciplaner_flutter/core/widgets/neo_button.dart';
import 'package:disciplaner_flutter/core/widgets/neo_card.dart';
import 'package:disciplaner_flutter/core/widgets/user_avatar.dart';
import 'create_project_modal.dart';
import 'project_providers.dart';

class MobileProjectsView extends ConsumerStatefulWidget {
  const MobileProjectsView({super.key});

  @override
  ConsumerState<MobileProjectsView> createState() => _MobileProjectsViewState();
}

class _MobileProjectsViewState extends ConsumerState<MobileProjectsView> {
  String _activeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);
    final selectedId = ref.watch(selectedProjectIdProvider);

    return Scaffold(
      backgroundColor: NeoColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: NeoSpacing.marginMobile,
            vertical: NeoSpacing.spaceMd,
          ),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Projets & Équipes', style: NeoTypography.headlineMd),
                      const SizedBox(height: 2),
                      Text(
                        'Chantiers actifs • Équipe Produit',
                        style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: NeoSpacing.spaceSm),
                NeoButton(
                  label: '+ Projet',
                  isDense: true,
                  onPressed: () => CreateProjectModal.show(context),
                ),
              ],
            ),
            const SizedBox(height: NeoSpacing.spaceMd),

            // Filter pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill('Tous', 'all', projectsAsync.value?.length ?? 0),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  _buildFilterPill('En cours', 'active', projectsAsync.value?.length ?? 0),
                  const SizedBox(width: NeoSpacing.spaceSm),
                  _buildFilterPill('Favoris', 'favorites', 0),
                ],
              ),
            ),
            const SizedBox(height: NeoSpacing.spaceLg),

            // Project cards
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) {
                  return NeoCard(
                    padding: const EdgeInsets.all(NeoSpacing.spaceXl),
                    child: Column(
                      children: [
                        const Icon(Icons.folder_open, size: 40, color: NeoColors.subdued),
                        const SizedBox(height: NeoSpacing.spaceSm),
                        Text('Aucun projet pour le moment', style: NeoTypography.headlineSm),
                        const SizedBox(height: 4),
                        Text(
                          'Créez votre premier projet pour commencer à organiser vos sprints.',
                          textAlign: TextAlign.center,
                          style: NeoTypography.bodySm.copyWith(color: NeoColors.muted),
                        ),
                        const SizedBox(height: NeoSpacing.spaceMd),
                        NeoButton(
                          label: 'Créer un projet',
                          onPressed: () => CreateProjectModal.show(context),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: projects.map((project) {
                    final isSelected = project.id == selectedId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: NeoSpacing.spaceMd),
                      child: _buildProjectCard(project, isSelected),
                    );
                  }).toList(),
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
                child: Text('Erreur: $err', style: TextStyle(color: NeoColors.error)),
              ),
            ),
          ],
        ),
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
                color: isActive ? NeoColors.surfaceContainerLowest : NeoColors.surfaceContainerHigh,
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

  Widget _buildProjectCard(ProjectSummaryDto project, bool isSelected) {
    return NeoCard(
      hasOverlayShadow: isSelected,
      onTap: () {
        ref.read(selectedProjectIdProvider.notifier).select(project.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NeoColors.surfaceContainerLow,
                  borderRadius: NeoSpacing.roundedMd,
                  border: Border.all(color: NeoColors.borderWhisper),
                ),
                alignment: Alignment.center,
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
                      style: NeoTypography.headlineSm.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description != null && project.description!.isNotEmpty)
                      Text(
                        project.description!,
                        style: NeoTypography.bodySm.copyWith(
                          color: NeoColors.muted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, size: 18, color: NeoColors.emerald),
            ],
          ),
          const SizedBox(height: NeoSpacing.spaceMd),

          // Stats bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${project.ticketCount} tickets • ${project.sprintCount} sprints',
                style: NeoTypography.bodySm.copyWith(
                  fontSize: 11,
                  color: NeoColors.onSurfaceVariant,
                ),
              ),
              UserAvatar(
                name: project.isOwner ? 'Owner' : 'Membre',
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
