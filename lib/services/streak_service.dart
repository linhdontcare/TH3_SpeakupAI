import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import 'database_helper.dart';

class StreakService {
  static final StreakService instance = StreakService._init();
  StreakService._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // Process a completed practice session and update streak accordingly
  // Quy tắc tính streak:
  // - Hoàn thành mục tiêu: >= 5 câu HOẶC hoàn thành cả 2 nhiệm vụ (số câu & số phút)
  // - Khi đạt mục tiêu và là ngày liên tiếp (hôm qua đã hoàn thành): +1 ngày
  // - Nếu chưa đạt mục tiêu hôm nay: giữ nguyên streak hiện tại
  // - Nếu bỏ lỡ 1 ngày không tập luyện: reset streak về 0
  Future<UserProfile> recordPracticeActivity({
    required int durationSeconds,
    required int exercisesCount,
    required double averageScore,
  }) async {
    final user = await _db.getUserProfile();
    final todayStats = await _db.getTodayStats();
    final exercisesDone = todayStats['exercisesCompleted'] as int? ?? 0;
    final minutesDone = todayStats['minutesLearned'] as int? ?? 0;

    final targetExercises = user.targetExercisesPerDay > 0
        ? user.targetExercisesPerDay
        : 5;
    final targetMinutes = user.targetMinutesPerDay > 0
        ? user.targetMinutesPerDay
        : 15;

    // Điều kiện hoàn thành mục tiêu hôm nay:
    // 1. Hoàn thành từ 5 câu trở lên hoặc đạt targetExercisesPerDay
    // 2. HOẶC hoàn thành cả 2 nhiệm vụ (cả số câu và số phút quy định)
    final bool isGoalMet =
        exercisesDone >= 5 ||
        exercisesDone >= targetExercises ||
        (exercisesDone >= targetExercises && minutesDone >= targetMinutes);

    // Nếu chưa hoàn thành mục tiêu ngày hôm nay -> Chưa được tính cộng streak!
    if (!isGoalMet) {
      return user;
    }

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 1)));

    // Nếu hôm nay đã được ghi nhận streak rồi (đã hoàn thành trước đó trong ngày), không cộng trùng lặp
    if (user.lastActiveDate == todayStr) {
      return user;
    }

    int newStreak = user.currentStreak;
    int newMaxStreak = user.maxStreak;

    if (user.lastActiveDate == yesterdayStr) {
      // Hôm qua cũng đã hoàn thành mục tiêu -> Chuỗi liên tiếp tăng +1!
      newStreak = user.currentStreak + 1;
    } else {
      // Bắt đầu chuỗi mới (người dùng mới bắt đầu từ 0 ngày, hoặc từng bị gián đoạn về 0):
      // Hoàn thành mục tiêu hôm nay -> Streak đạt mốc 1 ngày!
      newStreak = 1;
    }

    if (newStreak > newMaxStreak) {
      newMaxStreak = newStreak;
    }

    final updatedUser = user.copyWith(
      currentStreak: newStreak,
      maxStreak: newMaxStreak,
      lastActiveDate: todayStr,
    );

    await _db.updateUserProfile(updatedUser);
    return updatedUser;
  }

  // Check current streak integrity when app launches
  // Quy tắc: Nếu 1 ngày không vào tập luyện (lastActiveDate != today && != yesterday) -> reset về 0
  Future<UserProfile> evaluateCurrentStreak() async {
    final user = await _db.getUserProfile();
    if (user.lastActiveDate == null || user.lastActiveDate!.isEmpty) {
      return user;
    }

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 1)));

    // Nếu ngày hoàn thành mục tiêu gần nhất không phải hôm nay và không phải hôm qua
    // -> Người dùng đã bỏ lỡ ít nhất 1 ngày -> Reset chuỗi về 0!
    if (user.lastActiveDate != todayStr &&
        user.lastActiveDate != yesterdayStr) {
      if (user.currentStreak != 0) {
        final updatedUser = user.copyWith(currentStreak: 0);
        await _db.updateUserProfile(updatedUser);
        return updatedUser;
      }
    }

    return user;
  }

  // Update Daily Goals
  Future<UserProfile> updateDailyGoals({
    required int targetMinutes,
    required int targetExercises,
  }) async {
    final user = await _db.getUserProfile();
    final updatedUser = user.copyWith(
      targetMinutesPerDay: targetMinutes,
      targetExercisesPerDay: targetExercises,
    );
    await _db.updateUserProfile(updatedUser);
    return updatedUser;
  }

  // Calculate goal completion percentage for today
  Future<Map<String, dynamic>> getDailyGoalProgress() async {
    final user = await _db.getUserProfile();
    final todayStats = await _db.getTodayStats();

    final minutesDone = todayStats['minutesLearned'] as int? ?? 0;
    final exercisesDone = todayStats['exercisesCompleted'] as int? ?? 0;

    final targetMinutes = user.targetMinutesPerDay > 0
        ? user.targetMinutesPerDay
        : 15;
    final targetExercises = user.targetExercisesPerDay > 0
        ? user.targetExercisesPerDay
        : 5;

    final minutesProgress = (minutesDone / targetMinutes).clamp(0.0, 1.0);
    final exercisesProgress = (exercisesDone / targetExercises).clamp(0.0, 1.0);

    // Goal is met if completed 5 exercises, or met exercise target, or met both targets
    final isGoalMet =
        exercisesDone >= 5 ||
        exercisesDone >= targetExercises ||
        (exercisesDone >= targetExercises && minutesDone >= targetMinutes);
    final overallProgress = ((minutesProgress + exercisesProgress) / 2).clamp(
      0.0,
      1.0,
    );

    return {
      'minutesDone': minutesDone,
      'targetMinutes': targetMinutes,
      'exercisesDone': exercisesDone,
      'targetExercises': targetExercises,
      'minutesProgress': minutesProgress,
      'exercisesProgress': exercisesProgress,
      'overallProgress': overallProgress,
      'isGoalMet': isGoalMet,
    };
  }
}
