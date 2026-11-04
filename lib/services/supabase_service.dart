import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/pronunciation_result.dart';
import '../models/practice_session.dart';
import 'supabase_config.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient get client => Supabase.instance.client;

  Future<bool> init() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Supabase chưa được cấu hình URL/Key. Sử dụng SQLite fallback.');
      return false;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('Đã kết nối Supabase Cloud thành công!');
      return true;
    } catch (e) {
      debugPrint('Lỗi khởi tạo Supabase: $e');
      _isInitialized = false;
      return false;
    }
  }

  // 1. Quản lý Người dùng (Users)
  Future<UserProfile?> getUserProfile() async {
    if (!_isInitialized) return null;
    try {
      final res = await client.from('users').select().eq('id', 'default_user').maybeSingle();
      if (res != null) {
        return UserProfile(
          id: res['id'] ?? 'default_user',
          name: res['name'] ?? 'linhdontcare',
          nickname: res['nickname'] ?? 'LDC',
          targetMinutesPerDay: res['target_minutes_per_day'] ?? 15,
          targetExercisesPerDay: res['target_exercises_per_day'] ?? 5,
          reminderEnabled: res['reminder_enabled'] ?? true,
          reminderHour: res['reminder_hour'] ?? 20,
          reminderMinute: res['reminder_minute'] ?? 0,
          currentStreak: res['current_streak'] ?? 0,
          maxStreak: res['max_streak'] ?? 0,
          lastActiveDate: res['last_active_date'],
          level: res['level'] ?? 'PRO Scholar 💎',
        );
      }
    } catch (e) {
      debugPrint('Supabase getUserProfile error: $e');
    }
    return null;
  }

  Future<bool> updateUserProfile(UserProfile user) async {
    if (!_isInitialized) return false;
    try {
      await client.from('users').upsert({
        'id': user.id,
        'name': user.name,
        'nickname': user.nickname,
        'target_minutes_per_day': user.targetMinutesPerDay,
        'target_exercises_per_day': user.targetExercisesPerDay,
        'reminder_enabled': user.reminderEnabled,
        'reminder_hour': user.reminderHour,
        'reminder_minute': user.reminderMinute,
        'current_streak': user.currentStreak,
        'max_streak': user.maxStreak,
        'last_active_date': user.lastActiveDate,
        'level': user.level,
      });
      return true;
    } catch (e) {
      debugPrint('Supabase updateUserProfile error: $e');
      return false;
    }
  }

  // 2. Quản lý Kết quả phát âm AI (Pronunciation Records)
  Future<bool> insertPronunciationResult(PronunciationResult result) async {
    final res = await insertOrUpdatePronunciationResult(result);
    return res['isNewUnique'] as bool? ?? true;
  }

  // Chèn hoặc cập nhật kết quả: nếu cùng câu trong ngày mà điểm cao hơn thì cập nhật điểm mới
  Future<Map<String, dynamic>> insertOrUpdatePronunciationResult(PronunciationResult result) async {
    if (!_isInitialized) return {'isNewUnique': true, 'previousScore': null};
    try {
      final today = result.timestamp.toIso8601String().substring(0, 10);
      final existing = await client
          .from('pronunciation_records')
          .select()
          .eq('target_text', result.targetText)
          .gte('timestamp', '${today}T00:00:00.000Z')
          .maybeSingle();

      if (existing != null) {
        final double oldScore = (existing['overall_score'] as num?)?.toDouble() ?? 0.0;
        if (result.overallScore > oldScore) {
          // Luyện lại đạt điểm cao hơn -> cập nhật bản ghi với điểm số mới
          await client.from('pronunciation_records').update({
            'recognized_text': result.recognizedText,
            'overall_score': result.overallScore,
            'accuracy_score': result.accuracyScore,
            'fluency_score': result.fluencyScore,
            'completeness_score': result.completenessScore,
            'words_json': result.words.map((w) => w.toMap()).toList(),
            'mispronounced_sounds': result.mispronouncedSounds.join(','),
            'general_feedback': result.generalFeedback,
            'recommended_drills': result.recommendedDrills.join(';'),
            'timestamp': result.timestamp.toIso8601String(),
          }).eq('id', existing['id']);
        }
        return {'isNewUnique': false, 'previousScore': oldScore};
      }

      await client.from('pronunciation_records').insert({
        'id': result.id,
        'exercise_id': result.exerciseId,
        'timestamp': result.timestamp.toIso8601String(),
        'target_text': result.targetText,
        'recognized_text': result.recognizedText,
        'overall_score': result.overallScore,
        'accuracy_score': result.accuracyScore,
        'fluency_score': result.fluencyScore,
        'completeness_score': result.completenessScore,
        'words_json': result.words.map((w) => w.toMap()).toList(),
        'mispronounced_sounds': result.mispronouncedSounds.join(','),
        'general_feedback': result.generalFeedback,
        'recommended_drills': result.recommendedDrills.join(';'),
      });
      return {'isNewUnique': true, 'previousScore': null};
    } catch (e) {
      debugPrint('Supabase insertOrUpdatePronunciationResult error: $e');
      return {'isNewUnique': true, 'previousScore': null};
    }
  }

  // Đếm số câu duy nhất (Unique Sentences) đã luyện hôm nay
  Future<int> getUniqueExercisesCountToday() async {
    if (!_isInitialized) return 0;
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final res = await client
          .from('pronunciation_records')
          .select('target_text')
          .gte('timestamp', '${today}T00:00:00.000Z');
      final uniqueSet = (res as List)
          .map((e) => e['target_text']?.toString().trim().toLowerCase() ?? '')
          .where((s) => s.isNotEmpty)
          .toSet();
      return uniqueSet.length;
    } catch (e) {
      debugPrint('Supabase getUniqueExercisesCountToday error: $e');
      return 0;
    }
  }

  Future<List<PronunciationResult>> getPronunciationHistory({int limit = 50}) async {
    if (!_isInitialized) return [];
    try {
      final List res = await client
          .from('pronunciation_records')
          .select()
          .order('timestamp', ascending: false)
          .limit(limit);

      return res.map((m) {
        return PronunciationResult.fromMap({
          'id': m['id'],
          'exerciseId': m['exercise_id'],
          'timestamp': m['timestamp'],
          'targetText': m['target_text'],
          'recognizedText': m['recognized_text'],
          'overallScore': m['overall_score'],
          'accuracyScore': m['accuracy_score'],
          'fluencyScore': m['fluency_score'],
          'completenessScore': m['completeness_score'],
          'wordsJson': m['words_json']?.toString(),
          'mispronouncedSounds': m['mispronounced_sounds'],
          'generalFeedback': m['general_feedback'],
          'recommendedDrills': m['recommended_drills'],
        });
      }).toList();
    } catch (e) {
      debugPrint('Supabase getPronunciationHistory error: $e');
      return [];
    }
  }

  // 3. Quản lý Phiên luyện tập & Thống kê Ngày
  Future<bool> insertPracticeSession(PracticeSession session) async {
    if (!_isInitialized) return false;
    try {
      await client.from('practice_sessions').insert({
        'id': session.id,
        'date_string': session.dateString,
        'timestamp': session.timestamp.toIso8601String(),
        'duration_seconds': session.durationSeconds,
        'exercises_completed': session.exercisesCompleted,
        'average_score': session.averageScore,
      });

      // Cập nhật daily_stats (chỉ tính câu duy nhất - unique sentences)
      final today = session.dateString;
      final minutesAdded = (session.durationSeconds / 60).ceil();
      final uniqueCount = await getUniqueExercisesCountToday();
      final existing = await client.from('daily_stats').select().eq('date', today).maybeSingle();

      if (existing != null) {
        await client.from('daily_stats').update({
          'minutes_learned': (existing['minutes_learned'] ?? 0) + minutesAdded,
          'exercises_completed': uniqueCount > 0 ? uniqueCount : (existing['exercises_completed'] ?? 0),
        }).eq('date', today);
      } else {
        await client.from('daily_stats').insert({
          'date': today,
          'minutes_learned': minutesAdded,
          'exercises_completed': uniqueCount > 0 ? uniqueCount : session.exercisesCompleted,
          'streak_count': 1,
        });
      }
      return true;
    } catch (e) {
      debugPrint('Supabase insertPracticeSession error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTodayStats() async {
    if (!_isInitialized) return null;
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final uniqueCount = await getUniqueExercisesCountToday();
      final res = await client.from('daily_stats').select().eq('date', today).maybeSingle();
      if (res != null) {
        return {
          'date': res['date'],
          'minutesLearned': res['minutes_learned'] ?? 0,
          'exercisesCompleted': uniqueCount > 0 ? uniqueCount : (res['exercises_completed'] ?? 0),
          'streakCount': res['streak_count'] ?? 1,
        };
      }
      if (uniqueCount > 0) {
        return {
          'date': today,
          'minutesLearned': 0,
          'exercisesCompleted': uniqueCount,
          'streakCount': 1,
        };
      }
    } catch (e) {
      debugPrint('Supabase getTodayStats error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    if (!_isInitialized) return [];
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6)).toIso8601String().substring(0, 10);
      final List res = await client
          .from('daily_stats')
          .select()
          .gte('date', sevenDaysAgo)
          .order('date', ascending: true);

      return res.map((item) => {
        'date': item['date'],
        'minutesLearned': item['minutes_learned'] ?? 0,
        'exercisesCompleted': item['exercises_completed'] ?? 0,
        'streakCount': item['streak_count'] ?? 0,
      }).toList();
    } catch (e) {
      debugPrint('Supabase getWeeklyStats error: $e');
      return [];
    }
  }

  Future<void> clearAllData() async {
    if (!_isInitialized) return;
    try {
      await client.from('pronunciation_records').delete().neq('id', '');
      await client.from('practice_sessions').delete().neq('id', '');
      await client.from('daily_stats').delete().neq('date', '');
    } catch (e) {
      debugPrint('Supabase clearAllData error: $e');
    }
  }
}
