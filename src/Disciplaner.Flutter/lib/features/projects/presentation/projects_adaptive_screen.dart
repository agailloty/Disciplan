import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplaner_flutter/core/l10n/l10n.dart';
import 'package:disciplaner_flutter/features/shell/presentation/shell_placeholders.dart';
import 'package:disciplaner_flutter/features/tickets/presentation/project_list_view.dart';
import 'project_providers.dart';

class ProjectsAdaptiveScreen extends ConsumerWidget {
  const ProjectsAdaptiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentProject = ref.watch(currentProjectDetailProvider).value;

    if (currentProject != null) {
      return ProjectListView(projectId: currentProject.id);
    }

    return ShellPlaceholderView(
      title: l10n.projExplorerTitle,
      subtitle: l10n.projExplorerSubtitle,
      icon: Icons.folder_copy,
    );
  }
}
