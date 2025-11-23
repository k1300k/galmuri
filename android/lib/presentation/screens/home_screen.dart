import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/galmuri_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/program_info_modal.dart';
import 'capture_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../widgets/item_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const MethodChannel _channel = MethodChannel('com.galmuri.diary/screen_capture');
  static const EventChannel _eventChannel = EventChannel('com.galmuri.diary/screen_capture_events');
  StreamSubscription<dynamic>? _captureSubscription;

  @override
  void initState() {
    super.initState();
    // Load items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galmuriItemsProvider.notifier).loadItems();
    });
    
    // 화면 캡처 이벤트 리스너 설정 (모바일 전용)
    if (!kIsWeb) {
      _setupCaptureListener();
    }
  }

  @override
  void dispose() {
    _captureSubscription?.cancel();
    super.dispose();
  }

  void _setupCaptureListener() {
    debugPrint('[HomeScreen] EventChannel 리스너 설정 시작');
    _captureSubscription?.cancel();
    _captureSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        debugPrint('[HomeScreen] EventChannel 이벤트 수신: ${event.runtimeType}');
        if (event is Map && event['type'] == 'screen_captured') {
          final imageBase64 = event['imageBase64'] as String?;
          debugPrint('[HomeScreen] screen_captured 이벤트 수신 (base64 length=${imageBase64?.length ?? 0})');
          if (imageBase64 != null && mounted) {
            debugPrint('[HomeScreen] CaptureScreen으로 이동 시작');
            // CaptureScreen으로 이동하면서 캡처된 이미지 전달
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaptureScreen(
                  capturedImageBytes: base64Decode(imageBase64),
                ),
              ),
            ).then((_) {
              debugPrint('[HomeScreen] CaptureScreen에서 복귀, 목록 새로고침');
              ref.read(galmuriItemsProvider.notifier).loadItems();
            });
          } else {
            debugPrint('[HomeScreen] imageBase64가 null이거나 mounted가 false');
          }
        } else {
          debugPrint('[HomeScreen] 알 수 없는 이벤트 타입: ${event is Map ? event['type'] : 'not Map'}');
        }
      },
      onError: (error) {
        debugPrint('[HomeScreen] EventChannel 오류: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('캡처 오류: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onDone: () {
        debugPrint('[HomeScreen] EventChannel 스트림 종료');
      },
    );
    debugPrint('[HomeScreen] EventChannel 리스너 설정 완료');
  }

  Future<void> _showOverlayCapture() async {
    if (kIsWeb) {
      // 웹에서는 캡처 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CaptureScreen()),
      ).then((_) {
        ref.read(galmuriItemsProvider.notifier).loadItems();
      });
      return;
    }

    try {
      final userId = ref.read(userIdProvider);
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('설정 화면에서 User ID를 먼저 입력해주세요.'),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '설정으로 이동',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
          );
        }
        return;
      }

      // 오버레이 권한 확인
      final hasOverlayPermission = await _channel.invokeMethod<bool>('checkOverlayPermission');
      
      if (hasOverlayPermission != true) {
        // 오버레이 권한 요청
        final permissionResult = await _channel.invokeMethod<String>('requestOverlayPermission');
        
        if (permissionResult != 'permission_granted') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('오버레이 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: '설정 열기',
                  onPressed: () async {
                    // 오버레이 권한 설정 화면으로 이동
                    try {
                      final result = await _channel.invokeMethod<String>('requestOverlayPermission');
                      if (result == 'permission_requested') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('설정 화면으로 이동했습니다. "갈무리 다이어리"를 허용해주세요.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('설정 화면 열기 실패: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          }
          return;
        }
      }

      // 화면 캡처 권한 요청 안내
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ 중요: 화면 공유 팝업에서 반드시 "전체 화면"을 선택해 주세요!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 4),
          ),
        );
      }

      // 오버레이 표시 (이 과정에서 화면 캡처 권한 요청 팝업이 뜸)
      final result = await _channel.invokeMethod<String>('showOverlay');
      
      if (result == 'overlay_shown') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('화면 캡처 버튼이 표시되었습니다. 다른 앱으로 이동하여 버튼을 눌러 캡처하세요.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('캡처 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(galmuriItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Galmuri Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '프로그램 정보',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ProgramInfoModal(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '저장된 캡처가 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '하단 버튼을 눌러 캡처를 시작하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(galmuriItemsProvider.notifier).loadItems();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemCard(item: items[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(galmuriItemsProvider.notifier).loadItems();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showOverlayCapture,
        icon: const Icon(Icons.camera_alt),
        label: const Text('캡처'),
      ),
    );
  }
}


