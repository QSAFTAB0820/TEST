import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/task.dart';

class TaskService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  Future<List<Task>> getTasks({String? status, String? priority, String? search}) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse("${AppConfig.baseUrl}api/tasks/tasks/").replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    }
    throw Exception("Failed to load tasks");
  }

  Future<Task> createTask(Task task) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}api/tasks/tasks/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    }
    throw Exception("Failed to create task");
  }

  Future<Task> updateTask(Task task) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final response = await http.put(
      Uri.parse("${AppConfig.baseUrl}api/tasks/tasks/${task.id}/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    }
    throw Exception("Failed to update task");
  }

  Future<void> deleteTask(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception("Not authenticated");

    final response = await http.delete(
      Uri.parse("${AppConfig.baseUrl}api/tasks/tasks/$id/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete task");
    }
  }
}