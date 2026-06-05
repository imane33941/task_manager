import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(task.priority.name),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Supprimer',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
