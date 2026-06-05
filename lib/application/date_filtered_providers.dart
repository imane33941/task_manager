import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_extensions.dart';
import '../domain/entities/task.dart';
import 'task_list_provider.dart';

final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  return tasksAsync.whenData((tasks) {
    return tasks
        .where((task) => task.dueDate != null && task.dueDate!.isToday)
        .toList();
  });
});

final weekTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  return tasksAsync.whenData((tasks) {
    return tasks
        .where((task) => task.dueDate != null && task.dueDate!.isThisWeek)
        .toList();
  });
});

final tasksByProjectProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, projectId) {
  final tasksAsync = ref.watch(taskListProvider);
  return tasksAsync.whenData((tasks) {
    return tasks.where((task) => task.projectId == projectId).toList();
  });
});
