import 'package:task_manager/domain/entities/task.dart';

extension PriorityLabel on Priority {
  String get label => switch (this) {
        Priority.low => 'Basse',
        Priority.medium => 'Moyenne',
        Priority.high => 'Haute',
        Priority.urgent => 'Urgente',
      };
}

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'À faire',
        TaskStatus.inProgress => 'En cours',
        TaskStatus.done => 'Terminée',
      };
}
