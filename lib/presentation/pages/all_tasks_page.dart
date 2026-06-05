import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

import '../../application/search_provider.dart';
import '../../application/task_list_provider.dart';
import '../widgets/task_dialog.dart';

@RoutePage()
class AllTasksPage extends ConsumerStatefulWidget {
  const AllTasksPage({super.key});

  @override
  ConsumerState<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends ConsumerState<AllTasksPage> {
  final _searchFocus = FocusNode();
  bool _isKanbanView = false;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les tâches'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list),
                  tooltip: 'Vue liste',
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.view_kanban),
                  tooltip: 'Vue tableau',
                ),
              ],
              selected: {_isKanbanView},
              onSelectionChanged: (selection) {
                setState(() => _isKanbanView = selection.first);
              },
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
      floatingActionButton: _isKanbanView
          ? null
          : FloatingActionButton(
              heroTag: 'addTaskFab',
              onPressed: () => showTaskDialog(context, ref),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              focusNode: _searchFocus,
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          Expanded(
            child: _isKanbanView
                ? const Center(child: Text('Vue Kanban (à venir)'))
                : tasksAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Erreur : $err')),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return const Center(child: Text('Aucune tâche'));
                      }
                      final todo = tasks
                          .where((t) => t.status == TaskStatus.todo)
                          .toList();
                      final inProgress = tasks
                          .where((t) => t.status == TaskStatus.inProgress)
                          .toList();
                      final done = tasks
                          .where((t) => t.status == TaskStatus.done)
                          .toList();

                      return ListView(
                        children: [
                          _buildSection(context, ref, 'À faire', todo),
                          _buildSection(context, ref, 'En cours', inProgress),
                          _buildSection(context, ref, 'Terminée', done),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche'),
          content: Text('Voulez-vous vraiment supprimer "${task.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(taskListProvider.notifier).deleteTask(task.id);
                Navigator.pop(context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, WidgetRef ref, String title, List tasks) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text('$title (${tasks.length})'),
      children: tasks.map<Widget>((task) {
        return TaskTile(
          task: task,
          onTap: () => showTaskDialog(context, ref, existingTask: task),
          onDelete: () => _confirmDelete(context, ref, task),
        );
      }).toList(),
    );
  }
}
