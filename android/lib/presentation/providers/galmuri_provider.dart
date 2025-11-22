import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/galmuri_item.dart';
import '../../domain/repositories/galmuri_repository.dart';
import '../../data/repositories/galmuri_repository_impl.dart';
import '../../data/api/galmuri_api_client.dart';
import '../../data/models/capture_request.dart';
import 'settings_provider.dart';

/// Repository provider
final galmuriRepositoryProvider = Provider<IGalmuriRepository>((ref) {
  return LocalGalmuriRepository();
});

/// API client provider
final apiClientProvider = Provider<GalmuriApiClient?>((ref) {
  final apiUrl = ref.watch(apiUrlProvider);
  final apiKey = ref.watch(apiKeyProvider);
  
  if (apiUrl == null || apiUrl.isEmpty || apiKey == null || apiKey.isEmpty) {
    return null;
  }
  
  return GalmuriApiClient(baseUrl: apiUrl, apiKey: apiKey);
});

/// Galmuri items provider
final galmuriItemsProvider = StateNotifierProvider<GalmuriItemsNotifier, AsyncValue<List<GalmuriItem>>>((ref) {
  return GalmuriItemsNotifier(ref);
});

class GalmuriItemsNotifier extends StateNotifier<AsyncValue<List<GalmuriItem>>> {
  final Ref _ref;
  final IGalmuriRepository _repository = LocalGalmuriRepository();

  GalmuriItemsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null || userId.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final items = await _repository.findByUserId(userId);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> capture(CaptureRequest request) async {
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID가 설정되지 않았습니다.');
      }

      // Create item
      final item = GalmuriItem(
        id: Uuid().v4(),
        userId: userId,
        imageData: request.imageData,
        sourceUrl: request.sourceUrl,
        pageTitle: request.pageTitle,
        memoContent: request.memoContent,
        platform: Platform.mobileApp,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally first (Local First)
      await _repository.save(item);

      // Try to sync with server in background
      final apiClient = _ref.read(apiClientProvider);
      if (apiClient != null) {
        try {
          final syncedItem = await apiClient.capture(request);
          // Update local item with server response
          await _repository.save(syncedItem);
        } catch (e) {
          // Server sync failed, but local save succeeded
          print('Server sync failed: $e');
        }
      }

      // Reload items
      await loadItems();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> search(String query) async {
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null || userId.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      state = const AsyncValue.loading();
      final items = await _repository.search(userId, query);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.delete(itemId);
      
      // Try to delete from server
      final apiClient = _ref.read(apiClientProvider);
      if (apiClient != null) {
        try {
          await apiClient.deleteItem(itemId);
        } catch (e) {
          print('Server delete failed: $e');
        }
      }

      await loadItems();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncUnsyncedItems() async {
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null || userId.isEmpty) return;

      final apiClient = _ref.read(apiClientProvider);
      if (apiClient == null) return;

      final unsyncedItems = await _repository.findUnsynced(userId);
      
      for (final item in unsyncedItems) {
        try {
          final request = CaptureRequest(
            userId: item.userId,
            imageData: item.imageData,
            sourceUrl: item.sourceUrl,
            pageTitle: item.pageTitle,
            memoContent: item.memoContent,
            platform: item.platform.value,
          );
          
          final syncedItem = await apiClient.capture(request);
          await _repository.save(syncedItem);
        } catch (e) {
          print('Failed to sync item ${item.id}: $e');
        }
      }

      await loadItems();
    } catch (e) {
      print('Sync failed: $e');
    }
  }
}


