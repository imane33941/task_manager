import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/task_list_provider.dart';
import '../../domain/entities/task.dart';

void showTaskDialog(BuildContext context, WidgetRef ref, {Task? existingTask}) {
  showDialog(
    context: context,
    builder: (context) =>
        _TaskDialogContent(ref: ref, existingTask: existingTask),
  );
}

class _TaskDialogContent extends StatefulWidget {
  final WidgetRef ref;
  final Task? existingTask;

  const _TaskDialogContent({required this.ref, this.existingTask});

  @override
  State<_TaskDialogContent> createState() => _TaskDialogContentState();
}

class _TaskDialogContentState extends State<_TaskDialogContent> {
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  bool _showCalendar = false;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _dueDate = widget.existingTask?.dueDate;
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
      );
      widget.ref.read(taskListProvider.notifier).updateTask(updated);
    } else {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        dueDate: _dueDate,
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
                  _dueDate == null
                      ? 'Aucune échéance'
                      : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
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
