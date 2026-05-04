import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = true;
  bool _authenticated = false;
  Map<String, dynamic>? _user;

  bool get loading => _loading;
  bool get authenticated => _authenticated;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    bootstrap();
  }

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token != null && token.isNotEmpty) {
      _authenticated = true;
      await _fetchUser();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _fetchUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}api/auth/me/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _user = json.decode(response.body);
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}api/auth/login/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", data["tokens"]["access"]);
        await prefs.setString("refresh_token", data["tokens"]["refresh"]);
        
        _user = data["user"];
        _authenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}api/auth/register/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
          "first_name": firstName ?? "",
          "last_name": lastName ?? "",
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _authenticated = false;
    _user = null;
    notifyListeners();
  }
}