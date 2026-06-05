import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/application/shared_preferences_provider.dart';
import 'package:task_manager/application/theme_provider.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/infrastructure/repositories/shared_prefs_task_repository.dart';

import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await _seedInitialDataIfNeeded(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _seedInitialDataIfNeeded(SharedPreferences prefs) async {
  const seededKey = 'seeded_v2';
  final alreadySeeded = prefs.getBool(seededKey) ?? false;
  if (alreadySeeded) return;

  final repo = SharedPrefsTaskRepository(prefs);
  await repo.add(Task(
    id: '1',
    title: 'Bienvenue dans Task Manager',
    description: 'Ceci est une tâche d\'exemple',
    priority: Priority.medium,
    createdAt: DateTime.now(),
  ));
  await repo.add(Task(
    id: '2',
    title: 'Rendre le projet',
    description: 'Envoyer le lien GitHub par mail',
    priority: Priority.urgent,
    status: TaskStatus.todo,
    dueDate: DateTime.now(),
    createdAt: DateTime.now(),
  ));

  await prefs.setBool(seededKey, true);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: _appRouter.config(),
    );
  }
}
