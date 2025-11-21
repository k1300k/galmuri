import 'package:flutter/material.dart';

/// Web-optimized app bar
class WebAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearch;
  final VoidCallback? onSettings;

  const WebAppBar({
    super.key,
    this.onSearch,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.book, color: Color(0xFF667eea)),
          const SizedBox(width: 12),
          const Text(
            'Galmuri Diary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '검색',
          onPressed: onSearch,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: '설정',
          onPressed: onSettings,
        ),
        const SizedBox(width: 8),
      ],
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

