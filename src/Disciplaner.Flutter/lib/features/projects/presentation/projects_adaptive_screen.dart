import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/features/shell/presentation/shell_placeholders.dart';
import 'mobile_projects_view.dart';
import 'project_providers.dart';

class ProjectsAdaptiveScreen extends ConsumerWidget {
  const ProjectsAdaptiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProject = ref.watch(currentProjectDetailProvider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < NeoSpacing.mobileBreakpoint) {
          return const MobileProjectsView();
        }

        return ShellPlaceholderView(
          title: currentProject?.name ?? 'Explorateur de Projets',
          subtitle: currentProject?.description ??
              'Espace de travail agile pour piloter tickets, sprints et workflows.',
          icon: Icons.folder_copy,
        );
      },
    );
  }
}
