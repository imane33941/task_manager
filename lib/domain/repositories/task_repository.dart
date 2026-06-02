import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<void> add(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
}
