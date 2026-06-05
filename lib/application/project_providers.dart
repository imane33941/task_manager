import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repositories/project_repository.dart';
import '../infrastructure/repositories/shared_prefs_project_repository.dart';
import 'shared_preferences_provider.dart';

part 'project_providers.g.dart';

@riverpod
ProjectRepository projectRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsProjectRepository(prefs);
}
