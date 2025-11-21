import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/galmuri_provider.dart';
import 'capture_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../widgets/item_card.dart';
import '../widgets/web_app_bar.dart';

/// Web-optimized home screen
class WebHomeScreen extends ConsumerStatefulWidget {
  const WebHomeScreen({super.key});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galmuriItemsProvider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(galmuriItemsProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      appBar: WebAppBar(
        onSearch: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: Row(
        children: [
          // Sidebar (wide screens only)
          if (isWideScreen)
            Container(
              width: 250,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('홈'),
                    selected: true,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('검색'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('설정'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CaptureScreen()),
                        ).then((_) {
                          ref.read(galmuriItemsProvider.notifier).loadItems();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('새 캡처'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '저장된 캡처가 없습니다',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '새 캡처를 추가하여 시작하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CaptureScreen()),
                            ).then((_) {
                              ref.read(galmuriItemsProvider.notifier).loadItems();
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('첫 캡처 추가하기'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Grid view for web
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(galmuriItemsProvider.notifier).loadItems();
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWideScreen ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ItemCard(item: items[index]);
                            },
                            childCount: items.length,
                          ),
                        ),
                      ),
                    ],
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
          ),
        ],
      ),
      floatingActionButton: !isWideScreen
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaptureScreen()),
                ).then((_) {
                  ref.read(galmuriItemsProvider.notifier).loadItems();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('캡처'),
            )
          : null,
    );
  }
}

