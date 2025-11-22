/// Domain Entity for GalmuriItem
/// Follows Clean Architecture - Framework independent
class GalmuriItem {
  final String id;
  final String userId;
  final String imageData; // Base64 encoded or file path
  final String? sourceUrl;
  final String pageTitle;
  final String memoContent;
  final String ocrText;
  final OCRStatus ocrStatus;
  final Platform platform;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalmuriItem({
    required this.id,
    required this.userId,
    required this.imageData,
    this.sourceUrl,
    required this.pageTitle,
    this.memoContent = '',
    this.ocrText = '',
    this.ocrStatus = OCRStatus.pending,
    this.platform = Platform.mobileApp,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Mark OCR as completed
  GalmuriItem markOcrCompleted(String extractedText) {
    return GalmuriItem(
      id: id,
      userId: userId,
      imageData: imageData,
      sourceUrl: sourceUrl,
      pageTitle: pageTitle,
      memoContent: memoContent,
      ocrText: extractedText,
      ocrStatus: OCRStatus.done,
      platform: platform,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark OCR as failed
  GalmuriItem markOcrFailed() {
    return GalmuriItem(
      id: id,
      userId: userId,
      imageData: imageData,
      sourceUrl: sourceUrl,
      pageTitle: pageTitle,
      memoContent: memoContent,
      ocrText: ocrText,
      ocrStatus: OCRStatus.failed,
      platform: platform,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as synced
  GalmuriItem markSynced() {
    return GalmuriItem(
      id: id,
      userId: userId,
      imageData: imageData,
      sourceUrl: sourceUrl,
      pageTitle: pageTitle,
      memoContent: memoContent,
      ocrText: ocrText,
      ocrStatus: ocrStatus,
      platform: platform,
      isSynced: true,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Update memo
  GalmuriItem updateMemo(String newMemo) {
    return GalmuriItem(
      id: id,
      userId: userId,
      imageData: imageData,
      sourceUrl: sourceUrl,
      pageTitle: pageTitle,
      memoContent: newMemo,
      ocrText: ocrText,
      ocrStatus: ocrStatus,
      platform: platform,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get all searchable text
  String getSearchKeywords() {
    final keywords = <String>[];
    if (pageTitle.isNotEmpty) keywords.add(pageTitle);
    if (memoContent.isNotEmpty) keywords.add(memoContent);
    if (ocrText.isNotEmpty) keywords.add(ocrText);
    return keywords.join(' ');
  }

  /// Check if item is searchable
  bool isSearchable() {
    return ocrStatus == OCRStatus.done || memoContent.isNotEmpty;
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_data': imageData,
      'source_url': sourceUrl,
      'page_title': pageTitle,
      'memo_content': memoContent,
      'ocr_text': ocrText,
      'ocr_status': ocrStatus.value,
      'platform': platform.value,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory GalmuriItem.fromJson(Map<String, dynamic> json) {
    return GalmuriItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageData: json['image_data'] as String,
      sourceUrl: json['source_url'] as String?,
      pageTitle: json['page_title'] as String,
      memoContent: json['memo_content'] as String? ?? '',
      ocrText: json['ocr_text'] as String? ?? '',
      ocrStatus: OCRStatus.fromString(json['ocr_status'] as String),
      platform: Platform.fromString(json['platform'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

enum OCRStatus {
  pending('PENDING'),
  done('DONE'),
  failed('FAILED');

  final String value;
  const OCRStatus(this.value);

  static OCRStatus fromString(String value) {
    return OCRStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OCRStatus.pending,
    );
  }
}

enum Platform {
  mobileApp('MOBILE_APP'),
  webExtension('WEB_EXTENSION');

  final String value;
  const Platform(this.value);

  static Platform fromString(String value) {
    return Platform.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Platform.mobileApp,
    );
  }
}


