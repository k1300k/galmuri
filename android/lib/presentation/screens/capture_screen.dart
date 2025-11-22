import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/galmuri_provider.dart';
import '../providers/settings_provider.dart';
import '../../data/models/capture_request.dart';
import 'dart:ui' as ui;


class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _memoController = TextEditingController();
  final _titleController = TextEditingController();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  static const MethodChannel _channel = MethodChannel('com.galmuri.diary/screen_capture');
  File? _selectedImage;
  String? _imageBase64; // Web용
  Uint8List? _screenshotBytes; // 스크린샷용
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
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = null;
          _imageBase64 = base64Encode(bytes);
          _screenshotBytes = null;
          if (_titleController.text.isEmpty) {
            _titleController.text = '사진 ${DateTime.now().toString().substring(0, 16)}';
          }
        });
      } else {
        setState(() {
          _selectedImage = File(image.path);
          _screenshotBytes = null;
          if (_titleController.text.isEmpty) {
            _titleController.text = '사진 ${DateTime.now().toString().substring(0, 16)}';
          }
        });
      }
    }
  }

  Future<void> _captureScreen() async {
    if (kIsWeb) {
      // 웹에서는 스크린샷 기능 미지원
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('웹에서는 화면 캡처가 지원되지 않습니다')),
      );
      return;
    }

    try {
      // MediaProjection 권한 요청
      final result = await _channel.invokeMethod<String>('requestScreenCapture');
      
      if (result == 'permission_granted') {
        // 권한이 허용되었지만, 실제 캡처는 시스템 스크린샷을 사용해야 함
        // Android에서는 MediaProjection으로 직접 캡처하는 것이 복잡하므로
        // 사용자에게 시스템 스크린샷 사용을 안내
        if (mounted) {
          final shouldUseSystemScreenshot = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('화면 캡처'),
              content: const Text(
                '다른 앱의 화면을 캡처하려면:\n\n'
                '1. 확인을 누르면 앱이 백그라운드로 이동합니다\n'
                '2. 원하는 화면으로 이동하세요\n'
                '3. 볼륨 다운 + 전원 버튼을 눌러 스크린샷을 찍으세요\n'
                '4. 다시 앱으로 돌아와서 "갤러리" 버튼을 눌러 스크린샷을 선택하세요',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('확인'),
                ),
              ],
            ),
          );

          if (shouldUseSystemScreenshot == true) {
            // 앱을 백그라운드로 보내기 (홈 화면으로 이동)
            // 실제 구현은 플랫폼 채널을 통해 가능하지만,
            // 여기서는 사용자에게 안내만 제공
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('홈 버튼을 눌러 다른 앱으로 이동한 후 스크린샷을 찍으세요.'),
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('화면 캡처 권한이 필요합니다: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('화면 캡처 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _imageToBase64(File? imageFile) async {
    if (_screenshotBytes != null) {
      return base64Encode(_screenshotBytes!);
    }
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
    if (_selectedImage == null && _imageBase64 == null && _screenshotBytes == null) {
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
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Scaffold(
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
            if (_selectedImage != null || _imageBase64 != null || _screenshotBytes != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _screenshotBytes != null
                      ? Image.memory(
                          _screenshotBytes!,
                          fit: BoxFit.cover,
                        )
                      : kIsWeb && _imageBase64 != null
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
            
            const SizedBox(height: 8),
            
            // Screen capture button (모바일 전용)
            if (!kIsWeb)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _captureScreen,
                  icon: const Icon(Icons.screenshot),
                  label: const Text('화면 캡처'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
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
      ),
    );
  }
}


