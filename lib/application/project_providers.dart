import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/project_repository.dart';
import '../infrastructure/repositories/in_memory_project_repository.dart';

part 'project_providers.g.dart';

@riverpod
ProjectRepository projectRepository(Ref ref) {
  return InMemoryProjectRepository();
}
