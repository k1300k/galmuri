import 'package:dio/dio.dart';
import '../../domain/entities/galmuri_item.dart';
import '../models/capture_request.dart';

/// API Client for Galmuri Diary Backend
class GalmuriApiClient {
  final Dio _dio;
  final String baseUrl;
  final String apiKey;

  GalmuriApiClient({
    required this.baseUrl,
    required this.apiKey,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {
              'X-API-Key': apiKey,
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _dio.get('/');
    return response.data as Map<String, dynamic>;
  }

  /// Capture and save item
  Future<GalmuriItem> capture(CaptureRequest request) async {
    final response = await _dio.post(
      '/api/capture',
      data: request.toJson(),
    );
    return GalmuriItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get all items for a user
  Future<List<GalmuriItem>> getItems(String userId) async {
    final response = await _dio.get('/api/items/$userId');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => GalmuriItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search items
  Future<List<GalmuriItem>> search(String userId, String query) async {
    final response = await _dio.post(
      '/api/search',
      data: {
        'user_id': userId,
        'query': query,
      },
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => GalmuriItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get item by ID
  Future<GalmuriItem> getItem(String itemId) async {
    final response = await _dio.get('/api/item/$itemId');
    return GalmuriItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    await _dio.delete('/api/item/$itemId');
  }

  /// Get unsynced items
  Future<List<GalmuriItem>> getUnsyncedItems(String userId) async {
    final response = await _dio.get('/api/items/$userId/unsynced');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => GalmuriItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}


