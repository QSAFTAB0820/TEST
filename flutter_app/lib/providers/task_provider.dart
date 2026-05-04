import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();
  
  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;
  String? _statusFilter;
  String? _priorityFilter;

  List<Task> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get priorityFilter => _priorityFilter;

  Future<void> loadTasks({String? search}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _service.getTasks(
        status: _statusFilter,
        priority: _priorityFilter,
        search: search,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadTasks();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    loadTasks();
  }

  Future<bool> createTask({
    required String title,
    String? description,
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    try {
      final task = Task(
        id: 0,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 0,
      );
      await _service.createTask(task);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      await _service.updateTask(task);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _service.deleteTask(id);
      await loadTasks();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}