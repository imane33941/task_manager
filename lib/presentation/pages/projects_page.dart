import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/date_filtered_providers.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

import '../../application/project_list_provider.dart';
import '../../domain/entities/project.dart';

@RoutePage()
class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  Project? _selected;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projets')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProjectFab',
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (projects) {
          if (projects.isEmpty) return _emptyState(context);

          final selected =
              (_selected != null && projects.any((p) => p.id == _selected!.id))
                  ? _selected
                  : null;

          return Row(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _projectCard(
                      context,
                      project,
                      isSelected: selected?.id == project.id,
                    );
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 340,
                child: _detailPanel(context, selected),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 56, color: theme.hintColor),
          const SizedBox(height: 12),
          Text('Aucun projet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Touchez + pour créer votre premier projet',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _projectCard(BuildContext context, Project project,
      {required bool isSelected}) {
    final color = Color(project.color);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selected = project),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.folder, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Consumer(
                      builder: (context, ref, _) {
                        final tasksAsync =
                            ref.watch(tasksByProjectProvider(project.id));
                        final count = tasksAsync.maybeWhen(
                          data: (tasks) => tasks.length,
                          orElse: () => 0,
                        );
                        return Text(
                          count == 0
                              ? 'Aucune tâche'
                              : '$count tâche${count > 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Supprimer',
                color: theme.hintColor,
                onPressed: () => ref
                    .read(projectListProvider.notifier)
                    .deleteProject(project),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailPanel(BuildContext context, Project? project) {
    final theme = Theme.of(context);

    if (project == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text(
              'Sélectionnez un projet',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      );
    }

    final color = Color(project.color);
    final tasksAsync = ref.watch(tasksByProjectProvider(project.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.folder, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Erreur : $err')),
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune tâche pour ce projet',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) => TaskTile(task: tasks[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddProjectDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau projet'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final newProject = Project(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  color: Colors.blue.toARGB32(),
                );
                ref.read(projectListProvider.notifier).addProject(newProject);
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
