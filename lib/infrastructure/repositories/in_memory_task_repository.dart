import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Réviser Flutter',
      description: 'Architecture hexagonale et Riverpod',
      priority: Priority.high,
      status: TaskStatus.inProgress,
      createdAt: DateTime.now(),
    ),
    Task(
      id: '2',
      title: 'Faire les courses',
      priority: Priority.low,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
    ),
    Task(
      id: '3',
      title: 'Rendre le projet',
      description: 'Envoyer le lien GitHub par mail',
      priority: Priority.urgent,
      status: TaskStatus.todo,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<void> add(Task task) async {
    _tasks.add(task);
  }

  @override
  Future<void> update(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}
