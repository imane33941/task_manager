import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class InMemoryProjectRepository implements ProjectRepository {
  final List<Project> _projects = [];

  @override
  Future<List<Project>> getAll() async => List.unmodifiable(_projects);

  @override
  Future<void> add(Project project) async {
    _projects.add(project);
  }

  @override
  Future<void> update(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
  }

  @override
  Future<void> delete(String id) async {
    _projects.removeWhere((p) => p.id == id);
  }
}
