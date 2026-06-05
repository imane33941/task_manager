import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/project.dart';
import 'project_providers.dart';

part 'project_list_provider.g.dart';

@riverpod
class ProjectList extends _$ProjectList {
  @override
  Future<List<Project>> build() async {
    return ref.watch(projectRepositoryProvider).getAll();
  }

  Future<void> addProject(Project project) async {
    await ref.read(projectRepositoryProvider).add(project);
    ref.invalidateSelf();
  }

  Future<void> updateProject(Project project) async {
    await ref.read(projectRepositoryProvider).update(project);
    ref.invalidateSelf();
  }

  Future<void> deleteProject(Project project) async {
    await ref.read(projectRepositoryProvider).delete(project.id);
    ref.invalidateSelf();
  }
}
