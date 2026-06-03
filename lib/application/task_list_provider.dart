import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/task.dart';
import 'task_providers.dart';

part 'task_list_provider.g.dart';

@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    return ref.watch(taskRepositoryProvider).getAll();
  }

  Future<void> addTask(Task task) async {
    await ref.read(taskRepositoryProvider).add(task);
    ref.invalidateSelf();
  }

  Future<void> updateTask(Task task) async {
    await ref.read(taskRepositoryProvider).update(task);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}
