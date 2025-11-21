import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/galmuri_provider.dart';
import '../providers/settings_provider.dart';
import '../../data/models/capture_request.dart';


class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _memoController = TextEditingController();
  final _titleController = TextEditingController();
  File? _selectedImage;
  String? _imageBase64; // Web용
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      if (kIsWeb) {
        // Web: bytes를 직접 읽어서 base64로 변환
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = null;
          _imageBase64 = base64Encode(bytes);
          if (_titleController.text.isEmpty) {
            _titleController.text = image.name;
          }
        });
      } else {
        // Mobile: File 객체 사용
        setState(() {
          _selectedImage = File(image.path);
          if (_titleController.text.isEmpty) {
            _titleController.text = image.name;
          }
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        if (_titleController.text.isEmpty) {
          _titleController.text = '사진 ${DateTime.now().toString().substring(0, 16)}';
        }
      });
    }
  }

  Future<String> _imageToBase64(File? imageFile) async {
    if (kIsWeb && _imageBase64 != null) {
      return _imageBase64!;
    }
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    }
    throw Exception('이미지가 선택되지 않았습니다');
  }

  Future<void> _save() async {
    if (_selectedImage == null && _imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 선택해주세요')),
      );
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final imageBase64 = await _imageToBase64(_selectedImage);
      final userId = ref.read(userIdProvider);
      
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID가 설정되지 않았습니다. 설정 화면에서 User ID를 입력해주세요.');
      }

      final request = CaptureRequest(
        userId: userId,
        imageData: imageBase64,
        pageTitle: _titleController.text,
        memoContent: _memoController.text,
        platform: kIsWeb ? 'WEB_APP' : 'MOBILE_APP',
      );

      await ref.read(galmuriItemsProvider.notifier).capture(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 캡처'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            if (_selectedImage != null || _imageBase64 != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb && _imageBase64 != null
                      ? Image.memory(
                          base64Decode(_imageBase64!),
                          fit: BoxFit.cover,
                        )
                      : _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Image selection buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            // Memo input
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}


