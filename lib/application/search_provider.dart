import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/task_list_provider.dart';
import 'package:task_manager/domain/entities/task.dart';

final searchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode();
  ref.onDispose(node.dispose);
  return node;
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class StatusFilterNotifier extends Notifier<TaskStatus?> {
  @override
  TaskStatus? build() => null;

  void setStatus(TaskStatus? status) => state = status;
}

final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, TaskStatus?>(
        StatusFilterNotifier.new);

class PriorityFilterNotifier extends Notifier<Priority?> {
  @override
  Priority? build() => null;

  void setPriority(Priority? priority) => state = priority;
}

final priorityFilterProvider =
    NotifierProvider<PriorityFilterNotifier, Priority?>(
        PriorityFilterNotifier.new);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);
  final priorityFilter = ref.watch(priorityFilterProvider);

  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      final matchesQuery =
          query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesStatus = statusFilter == null || task.status == statusFilter;
      final matchesPriority =
          priorityFilter == null || task.priority == priorityFilter;
      return matchesQuery && matchesStatus && matchesPriority;
    }).toList();
  });
});
