import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'database_helper.dart';
import 'exercise_repository.dart';
import '../screens/practice_screen.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // Global Keys for triggering UI popups anywhere in the app
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Timer? _periodicTimer;
  String? _lastNotifiedKey;

  // Motivational reminder templates
  static final List<String> reminderMessages = [
    '🔥 Đừng để đứt chuỗi streak hôm nay! Hãy dành 5 phút luyện phát âm nào.',
    '🎯 Mục tiêu phát âm mỗi ngày đang chờ bạn. Hãy mở SpeakUp AI ngay!',
    '🌟 Chăm chỉ mỗi ngày là chìa khóa nói tiếng Anh tự tin và chuẩn bản xứ.',
    '🗣️ Luyện tập phản xạ cơ miệng với các âm /θ/ và âm đuôi hôm nay nhé!',
    '🚀 5 phút luyện tập hôm nay sẽ giúp bạn tự tin hơn trong buổi phỏng vấn ngày mai.',
  ];

  String getRandomMotivationalMessage() {
    final list = List<String>.from(reminderMessages)..shuffle();
    return list.first;
  }

  // Bắt đầu bộ đếm ngầm thời gian thực (quét mỗi 5 giây)
  void startPeriodicChecker() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkAndTriggerScheduledReminder();
    });
  }

  void stopPeriodicChecker() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  // Kiểm tra thời gian thực và kích hoạt thông báo nếu trùng khớp
  Future<void> checkAndTriggerScheduledReminder() async {
    try {
      final user = await _db.getUserProfile();
      if (!user.reminderEnabled) return;

      final now = DateTime.now();
      if (now.hour == user.reminderHour && now.minute == user.reminderMinute) {
        final key =
            '${now.year}-${now.month}-${now.day}_${now.hour}_${now.minute}';
        if (_lastNotifiedKey != key) {
          _lastNotifiedKey = key;
          triggerScheduledReminder(user: user);
        }
      }
    } catch (e) {
      debugPrint('Reminder check notice: $e');
    }
  }

  // Kích hoạt toàn diện thông báo nhắc nhở
  void triggerScheduledReminder({
    UserProfile? user,
    bool isTest = false,
  }) async {
    final currentUser = user ?? await _db.getUserProfile();
    final nickname = currentUser.nickname;
    final streak = currentUser.currentStreak;
    final msg = getRandomMotivationalMessage();

    // 1. Hiển thị SnackBar nổi
    showInAppReminder(
      scaffoldMessengerKey.currentContext,
      customMessage: '🔥 Nhắc nhở SpeakUp AI ($nickname): $msg',
    );

    // 2. Hiển thị Dialog thông báo popup nổi bật
    final navContext = navigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      showReminderDialog(
        navContext,
        nickname: nickname,
        streak: streak,
        message: msg,
        isTest: isTest,
      );
    }
  }

  // Hiển thị Dialog nổi bật giữa màn hình
  void showReminderDialog(
    BuildContext context, {
    required String nickname,
    required int streak,
    required String message,
    bool isTest = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFFD97706),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTest ? 'Thử nghiệm thông báo 🔔' : 'Đến giờ luyện tập!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    isTest
                        ? 'Mô phỏng chuông nhắc nhở'
                        : 'Giữ vững kỷ luật mỗi ngày',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$nickname ơi! Chuỗi hiện tại: $streak ngày liên tiếp',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chỉ cần 5 phút hoàn thành 5 câu hôm nay để ghi thêm +1 ngày Streak!',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Để sau',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            icon: const Icon(Icons.record_voice_over, size: 18),
            label: const Text(
              'Luyện tập ngay 🚀',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final currentNav = navigatorKey.currentContext;
              if (currentNav != null) {
                Navigator.push(
                  currentNav,
                  MaterialPageRoute(
                    builder: (_) => PracticeScreen(
                      initialExercise: ExerciseRepository.sampleExercises.first,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Update reminder settings
  Future<void> updateReminderSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final user = await _db.getUserProfile();
    final updatedUser = user.copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    await _db.updateUserProfile(updatedUser);

    // Reset last notified key when user changes reminder time
    _lastNotifiedKey = null;

    // Check immediately if current time matches new time
    checkAndTriggerScheduledReminder();
  }

  // Check if reminder is due
  bool isReminderTime(int hour, int minute) {
    final now = DateTime.now();
    return now.hour == hour && now.minute == minute;
  }

  // Show a simulation in-app notification banner
  void showInAppReminder(BuildContext? context, {String? customMessage}) {
    final message = customMessage ?? getRandomMotivationalMessage();
    final messenger = context != null
        ? ScaffoldMessenger.maybeOf(context)
        : scaffoldMessengerKey.currentState;

    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SpeakUp AI • Nhắc nhở học tập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
