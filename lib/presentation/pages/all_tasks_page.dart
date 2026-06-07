import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/date_extensions.dart';
import 'package:task_manager/core/enum_labels.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/presentation/widgets/kanban_board.dart';
import 'package:task_manager/presentation/widgets/task_tile.dart';

import '../../application/project_list_provider.dart';
import '../../application/search_provider.dart';
import '../../application/task_list_provider.dart';
import '../widgets/task_dialog.dart';

@RoutePage()
class AllTasksPage extends ConsumerStatefulWidget {
  const AllTasksPage({super.key});

  @override
  ConsumerState<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends ConsumerState<AllTasksPage> {
  final _searchFocus = FocusNode();
  bool _isKanbanView = false;
  String? _selectedTaskId;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    final allTasks = ref.watch(taskListProvider).valueOrNull ?? const <Task>[];
    Task? selectedTask;
    if (_selectedTaskId != null) {
      for (final t in allTasks) {
        if (t.id == _selectedTaskId) {
          selectedTask = t;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les tâches'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list),
                  tooltip: 'Vue liste',
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.view_kanban),
                  tooltip: 'Vue tableau',
                ),
              ],
              selected: {_isKanbanView},
              onSelectionChanged: (selection) {
                setState(() => _isKanbanView = selection.first);
              },
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
      floatingActionButton: _isKanbanView
          ? null
          : FloatingActionButton(
              heroTag: 'addTaskFab',
              onPressed: () => showTaskDialog(context, ref),
              child: const Icon(Icons.add),
            ),
      body: Row(
        children: [
          // Liste (gauche)
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    focusNode: _searchFocus,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).setQuery(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TaskStatus?>(
                          initialValue: ref.watch(statusFilterProvider),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<TaskStatus?>(
                              value: null,
                              child: Text('Tous'),
                            ),
                            ...TaskStatus.values
                                .map((s) => DropdownMenuItem<TaskStatus?>(
                                      value: s,
                                      child: Text(s.label),
                                    )),
                          ],
                          onChanged: (value) => ref
                              .read(statusFilterProvider.notifier)
                              .setStatus(value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<Priority?>(
                          initialValue: ref.watch(priorityFilterProvider),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Priorité',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<Priority?>(
                              value: null,
                              child: Text('Toutes'),
                            ),
                            ...Priority.values
                                .map((p) => DropdownMenuItem<Priority?>(
                                      value: p,
                                      child: Text(p.label),
                                    )),
                          ],
                          onChanged: (value) => ref
                              .read(priorityFilterProvider.notifier)
                              .setPriority(value),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: tasksAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Erreur : $err')),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return const Center(child: Text('Aucune tâche'));
                      }
                      if (_isKanbanView) {
                        return KanbanBoard(tasks: tasks);
                      }
                      final todo = tasks
                          .where((t) => t.status == TaskStatus.todo)
                          .toList();
                      final inProgress = tasks
                          .where((t) => t.status == TaskStatus.inProgress)
                          .toList();
                      final done = tasks
                          .where((t) => t.status == TaskStatus.done)
                          .toList();
                      return ListView(
                        children: [
                          _buildSection(context, ref, TaskStatus.todo, todo),
                          _buildSection(
                              context, ref, TaskStatus.inProgress, inProgress),
                          _buildSection(context, ref, TaskStatus.done, done),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!_isKanbanView) ...[
            const VerticalDivider(width: 1),
            SizedBox(
              width: 340,
              child: selectedTask == null
                  ? _placeholder(context)
                  : _TaskDetailPanel(
                      key: ValueKey(selectedTask.id),
                      task: selectedTask,
                      onClose: () => setState(() => _selectedTaskId = null),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist, size: 48, color: theme.hintColor),
          const SizedBox(height: 12),
          Text(
            'Sélectionnez une tâche',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche'),
          content: Text('Voulez-vous vraiment supprimer "${task.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(taskListProvider.notifier).deleteTask(task.id);
                if (_selectedTaskId == task.id) {
                  setState(() => _selectedTaskId = null);
                }
                Navigator.pop(context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, WidgetRef ref, TaskStatus status, List tasks) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = _statusColor(status);

    return ExpansionTile(
      initiallyExpanded: true,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            status.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${tasks.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
      children: tasks.map<Widget>((task) {
        return TaskTile(
          task: task,
          onTap: () => setState(() => _selectedTaskId = task.id),
          onDelete: () => _confirmDelete(context, ref, task),
          onToggleDone: (done) {
            final newStatus = done ? TaskStatus.done : TaskStatus.todo;
            final updated = task.copyWith(status: newStatus);
            ref.read(taskListProvider.notifier).updateTask(updated);
          },
        );
      }).toList(),
    );
  }
}

class _TaskDetailPanel extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onClose;

  const _TaskDetailPanel({
    super.key,
    required this.task,
    required this.onClose,
  });

  @override
  ConsumerState<_TaskDetailPanel> createState() => _TaskDetailPanelState();
}

class _TaskDetailPanelState extends ConsumerState<_TaskDetailPanel> {
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  bool _showCalendar = false;
  late Priority _priority;
  late TaskStatus _status;
  String? _projectId;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t.title);
    _dueDate = t.dueDate;
    _priority = t.priority;
    _status = t.status;
    _projectId = t.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final updated = widget.task.copyWith(
      title: title,
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      projectId: _projectId,
    );
    ref.read(taskListProvider.notifier).updateTask(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tâche enregistrée'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _delete() {
    ref.read(taskListProvider.notifier).deleteTask(widget.task.id);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Détail de la tâche',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Fermer',
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _titleController,
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
                  height: 320,
                  child: CalendarDatePicker(
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 5),
                    onDateChanged: (date) => setState(() {
                      _dueDate = date;
                      _showCalendar = false;
                    }),
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
                items: Priority.values
                    .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
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
                items: TaskStatus.values
                    .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: 16),
              projectsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
                data: (projects) => DropdownButtonFormField<String?>(
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
                    ...projects.map((p) => DropdownMenuItem<String?>(
                          value: p.id,
                          child: Text(p.name),
                        )),
                  ],
                  onChanged: (v) => setState(() => _projectId = v),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
