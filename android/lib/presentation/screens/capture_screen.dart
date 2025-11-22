import 'dart:async';
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
  final Uint8List? capturedImageBytes; // 홈에서 전달받은 캡처 이미지
  
  const CaptureScreen({super.key, this.capturedImageBytes});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _memoController = TextEditingController();
  final _titleController = TextEditingController();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  static const MethodChannel _channel = MethodChannel('com.galmuri.diary/screen_capture');
  static const EventChannel _eventChannel = EventChannel('com.galmuri.diary/screen_capture_events');
  File? _selectedImage;
  String? _imageBase64; // Web용
  Uint8List? _screenshotBytes; // 스크린샷용
  bool _isSaving = false;
  StreamSubscription<dynamic>? _captureSubscription;

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
      // 오버레이 권한 확인
      final hasOverlayPermission = await _channel.invokeMethod<bool>('checkOverlayPermission');
      
      if (hasOverlayPermission != true) {
        // 오버레이 권한 요청
        final permissionResult = await _channel.invokeMethod<String>('requestOverlayPermission');
        
        if (permissionResult != 'permission_granted') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('오버레이 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // 오버레이 표시
      final result = await _channel.invokeMethod<String>('showOverlay');
      
      if (result == 'overlay_shown') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('다른 앱으로 이동하여 상단의 "화면 캡처" 버튼을 눌러주세요'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // 캡처 결과를 기다리는 리스너 설정
        _setupCaptureListener();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오버레이 표시 실패: $result'),
              backgroundColor: Colors.red,
            ),
          );
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

  void _setupCaptureListener() {
    if (kIsWeb) return;
    
    _captureSubscription?.cancel();
    _captureSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) async {
        if (event is Map && event['type'] == 'screen_captured') {
          final imageBase64 = event['imageBase64'] as String?;
          if (imageBase64 != null) {
            setState(() {
              _screenshotBytes = base64Decode(imageBase64);
              _selectedImage = null;
              _imageBase64 = null;
            });
            
            // 앱을 포그라운드로 가져오기
            if (mounted) {
              // 제목 자동 생성
              if (_titleController.text.isEmpty) {
                _titleController.text = '화면 캡처 ${DateTime.now().toString().substring(0, 16)}';
              }
              
              // 자동 저장
              await _autoSave();
            }
          }
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('캡처 오류: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
  
  Future<void> _autoSave() async {
    if (_screenshotBytes == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final imageBase64 = base64Encode(_screenshotBytes!);
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
            content: Text('화면 캡처가 자동 저장되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 2초 후 자동으로 홈으로 이동
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('자동 저장 실패: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
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
    _captureSubscription?.cancel();
    _memoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    // 홈에서 전달받은 캡처 이미지가 있으면 자동으로 설정
    if (widget.capturedImageBytes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _screenshotBytes = widget.capturedImageBytes;
          _titleController.text = '화면 캡처 ${DateTime.now().toString().substring(0, 16)}';
        });
        // 자동 저장
        _autoSave();
      });
    }
    
    if (!kIsWeb) {
      _setupCaptureListener();
    }
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


