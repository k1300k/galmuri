/// Request model for capturing an item
class CaptureRequest {
  final String userId;
  final String imageData; // Base64 encoded
  final String? sourceUrl;
  final String pageTitle;
  final String memoContent;
  final String platform;

  CaptureRequest({
    required this.userId,
    required this.imageData,
    this.sourceUrl,
    required this.pageTitle,
    this.memoContent = '',
    this.platform = 'MOBILE_APP',
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'image_data': imageData,
      'source_url': sourceUrl,
      'page_title': pageTitle,
      'memo_content': memoContent,
      'platform': platform,
    };
  }
}


