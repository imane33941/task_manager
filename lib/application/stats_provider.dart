import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_extensions.dart';
import '../domain/entities/task.dart';
import 'task_list_provider.dart';

class TaskStats {
  final int total;
  final int todo;
  final int inProgress;
  final int done;
  final int overdue;
  final Map<Priority, int> byPriority;
  final Map<String?, int> byProject; // clé null = sans projet

  const TaskStats({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.done,
    required this.overdue,
    required this.byPriority,
    required this.byProject,
  });
}

final taskStatsProvider = Provider<AsyncValue<TaskStats>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);

  return tasksAsync.whenData((tasks) {
    final byPriority = {for (final p in Priority.values) p: 0};
    final byProject = <String?, int>{};
    var todo = 0, inProgress = 0, done = 0, overdue = 0;

    for (final t in tasks) {
      switch (t.status) {
        case TaskStatus.todo:
          todo++;
        case TaskStatus.inProgress:
          inProgress++;
        case TaskStatus.done:
          done++;
      }
      byPriority[t.priority] = (byPriority[t.priority] ?? 0) + 1;
      byProject[t.projectId] = (byProject[t.projectId] ?? 0) + 1;
      if (t.dueDate != null &&
          t.dueDate!.isOverdue &&
          t.status != TaskStatus.done) {
        overdue++;
      }
    }

    return TaskStats(
      total: tasks.length,
      todo: todo,
      inProgress: inProgress,
      done: done,
      overdue: overdue,
      byPriority: byPriority,
      byProject: byProject,
    );
  });
});
