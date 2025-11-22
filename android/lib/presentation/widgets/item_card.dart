import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../domain/entities/galmuri_item.dart';

class ItemCard extends StatelessWidget {
  final GalmuriItem item;

  const ItemCard({super.key, required this.item});

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Widget _buildImage() {
    try {
      // Try to decode base64 image
      final imageBytes = base64Decode(item.imageData);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 48),
          );
        },
      );
    } catch (e) {
      // If not base64, might be file path (for local storage)
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 48),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to detail screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: _buildImage(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.pageTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Memo
                  if (item.memoContent.isNotEmpty)
                    Text(
                      item.memoContent,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  // Metadata row
                  Row(
                    children: [
                      // OCR status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.ocrStatus == OCRStatus.done
                              ? Colors.green[100]
                              : item.ocrStatus == OCRStatus.failed
                                  ? Colors.red[100]
                                  : Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.ocrStatus == OCRStatus.done
                              ? 'OCR 완료'
                              : item.ocrStatus == OCRStatus.failed
                                  ? 'OCR 실패'
                                  : 'OCR 처리 중',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.ocrStatus == OCRStatus.done
                                ? Colors.green[800]
                                : item.ocrStatus == OCRStatus.failed
                                    ? Colors.red[800]
                                    : Colors.orange[800],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Sync status
                      if (!item.isSynced)
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 16,
                          color: Colors.orange[600],
                        ),

                      const SizedBox(width: 4),

                      // Date
                      Text(
                        _formatDate(item.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


