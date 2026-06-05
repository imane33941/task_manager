import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/task_list_provider.dart';
import 'package:task_manager/domain/entities/task.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(taskListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return tasksAsync.whenData((tasks) {
    if (query.isEmpty) return tasks;
    return tasks
        .where((task) => task.title.toLowerCase().contains(query))
        .toList();
  });
});
