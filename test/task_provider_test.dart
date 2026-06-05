import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_manager/application/task_list_provider.dart';
import 'package:task_manager/application/task_providers.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
import 'task_provider_test.mocks.dart';

void main() {
  late MockTaskRepository mockRepo;

  setUp(() {
    mockRepo = MockTaskRepository();
  });

  group('TaskRepository (mocké)', () {
    test('getAll retourne la liste des tâches', () async {
      final fakeTasks = [
        Task(id: '1', title: 'Tâche test', createdAt: DateTime.now()),
      ];
      when(mockRepo.getAll()).thenAnswer((_) async => fakeTasks);

      final result = await mockRepo.getAll();

      expect(result, hasLength(1));
      expect(result.first.title, equals('Tâche test'));
      verify(mockRepo.getAll()).called(1);
    });
  });

  group('TaskList Notifier', () {
    test('addTask appelle le repository et recharge la liste', () async {
      when(mockRepo.getAll()).thenAnswer((_) async => []);
      when(mockRepo.add(any)).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(taskListProvider.future);

      final newTask =
          Task(id: '2', title: 'Nouvelle', createdAt: DateTime.now());
      await container.read(taskListProvider.notifier).addTask(newTask);

      verify(mockRepo.add(newTask)).called(1);
    });
  });
}
