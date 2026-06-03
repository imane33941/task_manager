import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/repositories/task_repository.dart';
import '../infrastructure/repositories/in_memory_task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'task_providers.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  return InMemoryTaskRepository();
}
