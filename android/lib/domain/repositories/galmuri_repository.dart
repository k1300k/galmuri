import '../entities/galmuri_item.dart';

/// Repository interface (Port in Clean Architecture)
/// Defines contracts without implementation details
abstract class IGalmuriRepository {
  /// Save or update an item
  Future<GalmuriItem> save(GalmuriItem item);

  /// Find item by ID
  Future<GalmuriItem?> findById(String itemId);

  /// Find all items for a user
  Future<List<GalmuriItem>> findByUserId(String userId);

  /// Search items by query (searches in title, memo, and OCR text)
  Future<List<GalmuriItem>> search(String userId, String query);

  /// Find all unsynced items for a user
  Future<List<GalmuriItem>> findUnsynced(String userId);

  /// Delete an item
  Future<bool> delete(String itemId);
}


