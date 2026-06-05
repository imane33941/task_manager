import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/presentation/theme/priority_colors.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

void main() {
  testWidgets('TaskTile affiche le titre et la description', (tester) async {
    final task = Task(
      id: '1',
      title: 'Ma tâche',
      description: 'Une description',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        extensions: const [PriorityColors.light],
      ),
      home: Scaffold(body: TaskTile(task: task)),
    ));

    expect(find.text('Ma tâche'), findsOneWidget);
    expect(find.text('Une description'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
