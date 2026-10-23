import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:disciplaner_flutter/features/shell/presentation/shell_placeholders.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/project_list_view.dart';
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

        if (currentProject != null) {
          return ProjectListView(projectId: currentProject.id);
        }

        return const ShellPlaceholderView(
          title: 'Explorateur de Projets',
          subtitle:
              'Sélectionnez ou créez un projet pour afficher sa vue liste et son backlog.',
          icon: Icons.folder_copy,
        );
      },
    );
  }
}
