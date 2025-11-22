import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/galmuri_item.dart';
import '../../domain/repositories/galmuri_repository.dart';
import '../datasources/local_database.dart';

/// Local Repository Implementation
/// Uses SQLite for Local First storage (mobile only)
/// Web uses in-memory storage
class LocalGalmuriRepository implements IGalmuriRepository {
  final List<GalmuriItem> _webStorage = []; // Web fallback storage
  
  Database? get _db {
    if (kIsWeb) return null;
    try {
      return LocalDatabase.database;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<GalmuriItem> save(GalmuriItem item) async {
    if (kIsWeb || _db == null) {
      // Web: use in-memory storage
      final index = _webStorage.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _webStorage[index] = item;
      } else {
        _webStorage.add(item);
      }
      return item;
    }
    
    await _db!.insert(
      'galmuri_items',
      _toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return item;
  }

  @override
  Future<GalmuriItem?> findById(String itemId) async {
    if (kIsWeb || _db == null) {
      try {
        return _webStorage.firstWhere((item) => item.id == itemId);
      } catch (e) {
        return null;
      }
    }
    
    final maps = await _db!.query(
      'galmuri_items',
      where: 'id = ?',
      whereArgs: [itemId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  @override
  Future<List<GalmuriItem>> findByUserId(String userId) async {
    if (kIsWeb || _db == null) {
      return _webStorage
          .where((item) => item.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    final maps = await _db!.query(
      'galmuri_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<GalmuriItem>> search(String userId, String query) async {
    if (kIsWeb || _db == null) {
      final lowerQuery = query.toLowerCase();
      return _webStorage
          .where((item) => 
              item.userId == userId &&
              (item.pageTitle.toLowerCase().contains(lowerQuery) ||
               item.memoContent.toLowerCase().contains(lowerQuery) ||
               item.ocrText.toLowerCase().contains(lowerQuery)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    final searchPattern = '%$query%';
    final maps = await _db!.query(
      'galmuri_items',
      where: 'user_id = ? AND (page_title LIKE ? OR memo_content LIKE ? OR ocr_text LIKE ?)',
      whereArgs: [userId, searchPattern, searchPattern, searchPattern],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<GalmuriItem>> findUnsynced(String userId) async {
    if (kIsWeb || _db == null) {
      return _webStorage
          .where((item) => item.userId == userId && !item.isSynced)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    final maps = await _db!.query(
      'galmuri_items',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<bool> delete(String itemId) async {
    if (kIsWeb || _db == null) {
      final index = _webStorage.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _webStorage.removeAt(index);
        return true;
      }
      return false;
    }
    
    final count = await _db!.delete(
      'galmuri_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
    return count > 0;
  }

  /// Convert GalmuriItem to Map for database
  Map<String, dynamic> _toMap(GalmuriItem item) {
    return {
      'id': item.id,
      'user_id': item.userId,
      'image_data': item.imageData,
      'source_url': item.sourceUrl,
      'page_title': item.pageTitle,
      'memo_content': item.memoContent,
      'ocr_text': item.ocrText,
      'ocr_status': item.ocrStatus.value,
      'platform': item.platform.value,
      'is_synced': item.isSynced ? 1 : 0,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }

  /// Convert Map to GalmuriItem
  GalmuriItem _fromMap(Map<String, dynamic> map) {
    return GalmuriItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      imageData: map['image_data'] as String,
      sourceUrl: map['source_url'] as String?,
      pageTitle: map['page_title'] as String,
      memoContent: map['memo_content'] as String? ?? '',
      ocrText: map['ocr_text'] as String? ?? '',
      ocrStatus: OCRStatus.fromString(map['ocr_status'] as String),
      platform: Platform.fromString(map['platform'] as String),
      isSynced: (map['is_synced'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}


