import 'package:flutter/material.dart';
import 'package:task_manager/core/date_extensions.dart';
import 'package:task_manager/core/enum_labels.dart';

import '../../domain/entities/task.dart';
import '../theme/priority_colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDragHandle;
  final ValueChanged<bool>? onToggleDone;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.showDragHandle = false,
    this.onToggleDone,
  });

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

  @override
  Widget build(BuildContext context) {
    final priorityColors = Theme.of(context).extension<PriorityColors>()!;
    final color = priorityColors.forPriority(task.priority);
    final theme = Theme.of(context);
    final isDone = task.status == TaskStatus.done;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (showDragHandle) ...[
              Icon(Icons.drag_indicator, size: 18, color: theme.hintColor),
              const SizedBox(width: 4),
            ],
            if (onToggleDone != null) ...[
              Checkbox(
                value: isDone,
                onChanged: (checked) => onToggleDone!(checked ?? false),
              ),
              const SizedBox(width: 4),
            ],
            // Avatar rond avec emoji de priorité
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(_priorityEmoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            // Titre + sous-ligne
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? theme.hintColor : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.description.isNotEmpty
                        ? task.description
                        : task.status.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Colonne de droite : échéance (style "heure" WhatsApp) + supprimer
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.dueDate != null)
                  Builder(
                    builder: (context) {
                      final overdue = task.dueDate!.isOverdue && !isDone;
                      final dateColor = overdue ? Colors.red : theme.hintColor;
                      return Text(
                        task.dueDate!.formatted,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: dateColor,
                          fontWeight: overdue ? FontWeight.bold : null,
                        ),
                      );
                    },
                  ),
                if (onDelete != null)
                  SizedBox(
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Supprimer',
                      onPressed: onDelete,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
