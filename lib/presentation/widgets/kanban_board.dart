import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/task_list_provider.dart';
import '../../domain/entities/task.dart';
import 'task_dialog.dart';
import 'task_tile.dart';

class KanbanBoard extends ConsumerWidget {
  final List<Task> tasks;

  const KanbanBoard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = tasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgress =
        tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Column(
            title: 'À faire',
            status: TaskStatus.todo,
            tasks: todo,
          ),
        ),
        Expanded(
          child: _Column(
            title: 'En cours',
            status: TaskStatus.inProgress,
            tasks: inProgress,
          ),
        ),
        Expanded(
          child: _Column(
            title: 'Terminée',
            status: TaskStatus.done,
            tasks: done,
          ),
        ),
      ],
    );
  }
}

class _Column extends ConsumerWidget {
  final String title;
  final TaskStatus status;
  final List<Task> tasks;

  const _Column({
    required this.title,
    required this.status,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$title (${tasks.length})',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Ajouter dans "$title"',
                  onPressed: () =>
                      showTaskDialog(context, ref, initialStatus: status),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: tasks.map((task) {
                return TaskTile(
                  task: task,
                  onTap: () => showTaskDialog(context, ref, existingTask: task),
                  onDelete: () =>
                      ref.read(taskListProvider.notifier).deleteTask(task.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
