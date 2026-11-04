import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/main_navigation_screen.dart';
import 'services/database_helper.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase Cloud nếu đã cấu hình
  try {
    await SupabaseService.instance.init();
  } catch (e) {
    debugPrint('Supabase init notice: $e');
  }

  try {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await DatabaseHelper.instance.database;
    }
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  // Khởi chạy bộ đếm thời gian thực cho tính năng nhắc nhở học tập (Checklist 6)
  NotificationService.instance.startPeriodicChecker();

  runApp(const SpeakUpAiApp());
}

class SpeakUpAiApp extends StatelessWidget {
  const SpeakUpAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.instance.navigatorKey,
      scaffoldMessengerKey: NotificationService.instance.scaffoldMessengerKey,
      title: 'SpeakUp AI - linhdontcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
