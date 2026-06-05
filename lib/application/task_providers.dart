import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories/task_repository.dart';
import '../infrastructure/repositories/shared_prefs_task_repository.dart';
import 'shared_preferences_provider.dart';

part 'task_providers.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsTaskRepository(prefs);
}
