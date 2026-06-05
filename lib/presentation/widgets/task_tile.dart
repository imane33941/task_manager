import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../theme/priority_colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskTile({super.key, required this.task, this.onTap, this.onDelete});

  String get _priorityEmoji {
    switch (task.priority) {
      case Priority.low:
        return '🌱';
      case Priority.medium:
        return '⚡';
      case Priority.high:
        return '🔥';
      case Priority.urgent:
        return '🚨';
    }
  }

  Color _statusColor(BuildContext context) {
    switch (task.status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColors = Theme.of(context).extension<PriorityColors>()!;
    final color = priorityColors.forPriority(task.priority);
    final theme = Theme.of(context);
    final statusColor = _statusColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji de priorité dans une pastille
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(_priorityEmoji,
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                // Titre + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Ligne de métadonnées : statut + échéance
                      Row(
                        children: [
                          // Pastille de statut
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.status.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.event, size: 13, color: theme.hintColor),
                            const SizedBox(width: 3),
                            Text(
                              '${task.dueDate!.day}/${task.dueDate!.month}',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton supprimer
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Supprimer',
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
