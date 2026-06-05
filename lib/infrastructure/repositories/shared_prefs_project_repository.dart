import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class SharedPrefsProjectRepository implements ProjectRepository {
  static const _key = 'projects';
  final SharedPreferences _prefs;

  SharedPrefsProjectRepository(this._prefs);

  // Lit la liste depuis le disque
  List<Project> _load() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Project.fromJson(json)).toList();
  }

  // Écrit la liste sur le disque
  Future<void> _save(List<Project> projects) async {
    final jsonString = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }

  @override
  Future<List<Project>> getAll() async => _load();

  @override
  Future<void> add(Project project) async {
    final projects = _load();
    projects.add(project);
    await _save(projects);
  }

  @override
  Future<void> update(Project project) async {
    final projects = _load();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await _save(projects);
    }
  }

  @override
  Future<void> delete(String id) async {
    final projects = _load();
    projects.removeWhere((p) => p.id == id);
    await _save(projects);
  }
}
