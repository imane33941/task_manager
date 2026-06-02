import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAll();
  Future<void> add(Project project);
  Future<void> update(Project project);
  Future<void> delete(String id);
}
