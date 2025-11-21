import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings keys
const String _apiUrlKey = 'api_url';
const String _apiKeyKey = 'api_key';
const String _userIdKey = 'user_id';

/// API URL provider
final apiUrlProvider = StateNotifierProvider<ApiUrlNotifier, String?>((ref) {
  return ApiUrlNotifier();
});

/// API Key provider
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>((ref) {
  return ApiKeyNotifier();
});

/// User ID provider
final userIdProvider = StateNotifierProvider<UserIdNotifier, String?>((ref) {
  return UserIdNotifier();
});

class ApiUrlNotifier extends StateNotifier<String?> {
  // Render 백엔드 기본 URL
  static const String defaultApiUrl = 'https://galmuri.onrender.com';
  
  ApiUrlNotifier() : super(defaultApiUrl) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_apiUrlKey);
    state = value ?? defaultApiUrl;
  }

  Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_apiUrlKey);
    } else {
      await prefs.setString(_apiUrlKey, value);
    }
    state = value;
  }
}

class ApiKeyNotifier extends StateNotifier<String?> {
  ApiKeyNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_apiKeyKey);
    state = value;
  }

  Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_apiKeyKey);
    } else {
      await prefs.setString(_apiKeyKey, value);
    }
    state = value;
  }
}

class UserIdNotifier extends StateNotifier<String?> {
  UserIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_userIdKey);
    state = value;
  }

  Future<void> setValue(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_userIdKey);
    } else {
      await prefs.setString(_userIdKey, value);
    }
    state = value;
  }
}
