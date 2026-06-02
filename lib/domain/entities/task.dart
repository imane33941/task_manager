import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default('') String description,
    @Default(Priority.medium) Priority priority,
    @Default(TaskStatus.todo) TaskStatus status,
    DateTime? dueDate,
    String? projectId,
    required DateTime createdAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum Priority { low, medium, high, urgent }

enum TaskStatus { todo, inProgress, done }
