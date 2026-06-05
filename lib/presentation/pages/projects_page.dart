import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/date_filtered_providers.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

import '../../application/project_list_provider.dart';
import '../../domain/entities/project.dart';

@RoutePage()
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Projets')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProjectFab',
        onPressed: () => _showAddProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('Aucun projet'));
          }
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(project.color),
                ),
                title: Text(project.name),
                onTap: () => _showProjectTasks(context, ref, project),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer',
                  onPressed: () {
                    ref
                        .read(projectListProvider.notifier)
                        .deleteProject(project);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
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

  void _showProjectTasks(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tâches de "${project.name}"'),
          content: SizedBox(
            width: 400,
            child: Consumer(
              builder: (context, ref, _) {
                final tasksAsync =
                    ref.watch(tasksByProjectProvider(project.id));
                return tasksAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Erreur : $err'),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return const Text('Aucune tâche pour ce projet');
                    }
                    return SizedBox(
                      width: 400,
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return TaskTile(task: tasks[index]);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
