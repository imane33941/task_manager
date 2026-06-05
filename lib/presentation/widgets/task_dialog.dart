import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/task_list_provider.dart';
import '../../domain/entities/task.dart';

void showTaskDialog(BuildContext context, WidgetRef ref, {Task? existingTask}) {
  final isEditing = existingTask != null;
  final titleController =
      TextEditingController(text: existingTask?.title ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Titre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              if (isEditing) {
                final updated = existingTask.copyWith(title: title);
                ref.read(taskListProvider.notifier).updateTask(updated);
              } else {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  createdAt: DateTime.now(),
                );
                ref.read(taskListProvider.notifier).addTask(newTask);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
          ),
        ],
      );
    },
  );
}
