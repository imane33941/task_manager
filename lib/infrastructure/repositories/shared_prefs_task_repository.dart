import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class SharedPrefsTaskRepository implements TaskRepository {
  static const _key = 'tasks';
  final SharedPreferences _prefs;

  SharedPrefsTaskRepository(this._prefs);

  // Lit la liste depuis le disque
  List<Task> _load() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Task.fromJson(json)).toList();
  }

  // Écrit la liste sur le disque
  Future<void> _save(List<Task> tasks) async {
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }

  @override
  Future<List<Task>> getAll() async => _load();

  @override
  Future<void> add(Task task) async {
    final tasks = _load();
    tasks.add(task);
    await _save(tasks);
  }

  @override
  Future<void> update(Task task) async {
    final tasks = _load();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _save(tasks);
    }
  }

  @override
  Future<void> delete(String id) async {
    final tasks = _load();
    tasks.removeWhere((t) => t.id == id);
    await _save(tasks);
  }
}
