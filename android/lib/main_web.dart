import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/web_home_screen.dart';
import 'data/datasources/local_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web에서는 SQLite를 사용하지 않음 (인메모리 저장소 사용)
  // LocalDatabase.init() 호출하지 않음
  
  runApp(
    const ProviderScope(
      child: GalmuriDiaryWebApp(),
    ),
  );
}

class GalmuriDiaryWebApp extends StatelessWidget {
  const GalmuriDiaryWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galmuri Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const WebHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

