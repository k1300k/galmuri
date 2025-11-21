import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/web_home_screen.dart';
import 'data/datasources/local_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local database (only for mobile platforms)
  if (!kIsWeb) {
    try {
      await LocalDatabase.init();
    } catch (e) {
      print('Database initialization failed: $e');
    }
  }
  
  runApp(
    const ProviderScope(
      child: GalmuriDiaryApp(),
    ),
  );
}

class GalmuriDiaryApp extends StatelessWidget {
  const GalmuriDiaryApp({super.key});

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
          centerTitle: true,
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
      home: kIsWeb ? const WebHomeScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


