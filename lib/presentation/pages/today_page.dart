import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/date_filtered_providers.dart';
import '../widgets/task_tile.dart';

@RoutePage()
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aujourd\'hui')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Aucune tâche pour aujourd\'hui'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(task: task);
            },
          );
        },
      ),
    );
  }
}
