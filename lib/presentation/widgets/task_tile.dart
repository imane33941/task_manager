import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/project_list_provider.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre de priorité à gauche
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      if (showDragHandle) ...[
                        Icon(Icons.drag_indicator,
                            size: 18, color: theme.hintColor),
                        const SizedBox(width: 4),
                      ],
                      if (onToggleDone != null) ...[
                        Checkbox(
                          value: isDone,
                          onChanged: (checked) =>
                              onToggleDone!(checked ?? false),
                        ),
                        const SizedBox(width: 4),
                      ],
                      // Avatar rond avec emoji de priorité
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(_priorityEmoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 14),
                      // Titre + description + badges
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
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? theme.hintColor : null,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                task.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _Badge(
                                    label: task.priority.label, color: color),
                                _Badge(
                                  label: task.status.label,
                                  color: theme.hintColor,
                                  subtle: true,
                                ),
                                if (task.projectId != null)
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final projectsAsync =
                                          ref.watch(projectListProvider);
                                      final name = projectsAsync.maybeWhen(
                                        data: (projects) {
                                          for (final p in projects) {
                                            if (p.id == task.projectId) {
                                              return p.name;
                                            }
                                          }
                                          return null;
                                        },
                                        orElse: () => null,
                                      );
                                      if (name == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return _Badge(
                                        label: name,
                                        color: theme.colorScheme.primary,
                                        icon: Icons.folder,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.dueDate != null)
                            Builder(
                              builder: (context) {
                                final overdue =
                                    task.dueDate!.isOverdue && !isDone;
                                final dateColor =
                                    overdue ? Colors.red : theme.hintColor;
                                return Text(
                                  task.dueDate!.formatted,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: dateColor,
                                    fontWeight:
                                        overdue ? FontWeight.bold : null,
                                  ),
                                );
                              },
                            ),
                          if (onDelete != null)
                            SizedBox(
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                                tooltip: 'Supprimer',
                                onPressed: onDelete,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool subtle;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.subtle = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = subtle
        ? theme.colorScheme.surfaceContainerHighest
        : color.withValues(alpha: 0.15);
    final fg = subtle ? theme.hintColor : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
