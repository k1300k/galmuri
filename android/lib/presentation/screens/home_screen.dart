import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/galmuri_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Load items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galmuriItemsProvider.notifier).loadItems();
    });
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
      // 스크린샷 감지 시작
      final result = await _channel.invokeMethod<String>('startScreenshotObserver');
      
      if (result == 'observer_started' || result == 'permission_requested') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('스크린샷 자동 저장이 활성화되었습니다!\n\n볼륨 다운 + 전원 버튼으로 스크린샷을 찍으면 자동으로 저장됩니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('시작 실패: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: ${e.toString()}'),
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


