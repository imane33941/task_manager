import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/application/project_list_provider.dart';
import 'package:task_manager/core/date_extensions.dart';

import '../../application/task_list_provider.dart';
import '../../domain/entities/task.dart';

void showTaskDialog(BuildContext context, WidgetRef ref,
    {Task? existingTask, TaskStatus? initialStatus}) {
  showDialog(
    context: context,
    builder: (context) => _TaskDialogContent(
      ref: ref,
      existingTask: existingTask,
      initialStatus: initialStatus,
    ),
  );
}

class _TaskDialogContent extends StatefulWidget {
  final WidgetRef ref;
  final Task? existingTask;
  final TaskStatus? initialStatus;

  const _TaskDialogContent(
      {required this.ref, this.existingTask, this.initialStatus});

  @override
  State<_TaskDialogContent> createState() => _TaskDialogContentState();
}

class _TaskDialogContentState extends State<_TaskDialogContent> {
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  bool _showCalendar = false;
  Priority _priority = Priority.medium;
  TaskStatus _status = TaskStatus.todo;
  String? _projectId;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _dueDate = widget.existingTask?.dueDate;
    _priority = widget.existingTask?.priority ?? Priority.medium;
    _status =
        widget.existingTask?.status ?? widget.initialStatus ?? TaskStatus.todo;
    _projectId = widget.existingTask?.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        projectId: _projectId,
      );
      widget.ref.read(taskListProvider.notifier).updateTask(updated);
    } else {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        projectId: _projectId,
        createdAt: DateTime.now(),
      );
      widget.ref.read(taskListProvider.notifier).addTask(newTask);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _showCalendar = !_showCalendar),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date d\'échéance',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Retirer l\'échéance',
                          onPressed: () => setState(() {
                            _dueDate = null;
                            _showCalendar = false;
                          }),
                        )
                      : Icon(_showCalendar
                          ? Icons.expand_less
                          : Icons.expand_more),
                ),
                child: Text(
                  _dueDate == null ? 'Aucune échéance' : _dueDate!.formatted,
                ),
              ),
            ),
            if (_showCalendar)
              SizedBox(
                width: 320,
                height: 320,
                child: CalendarDatePicker(
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 5),
                  onDateChanged: (date) {
                    setState(() {
                      _dueDate = date;
                      _showCalendar = false;
                    });
                  },
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priorité',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final projectsAsync = ref.watch(projectListProvider);
                return projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (projects) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _projectId,
                      decoration: const InputDecoration(
                        labelText: 'Projet',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Aucun projet'),
                        ),
                        ...projects.map((project) {
                          return DropdownMenuItem<String?>(
                            value: project.id,
                            child: Text(project.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _projectId = value);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }
}
