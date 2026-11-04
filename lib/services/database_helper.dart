import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user_profile.dart';
import '../models/pronunciation_result.dart';
import '../models/practice_session.dart';
import 'supabase_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Web in-memory storage fallback
  UserProfile _webUser = UserProfile(
    id: 'default_user',
    name: 'linhdontcare',
    nickname: 'LDC',
    targetMinutesPerDay: 15,
    targetExercisesPerDay: 5,
    reminderEnabled: true,
    reminderHour: 20,
    reminderMinute: 0,
    currentStreak: 0,
    maxStreak: 0,
    lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    level: 'PRO Scholar 💎',
  );
  final List<PronunciationResult> _webHistory = [];
  final List<PracticeSession> _webSessions = [];
  final Map<String, Map<String, dynamic>> _webDailyStats = {};

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('speakup_ai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath = inMemoryDatabasePath;
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      dbPath = p.join(documentsDirectory.path, filePath);
    } catch (_) {
      dbPath = inMemoryDatabasePath;
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        nickname TEXT DEFAULT 'LDC',
        avatar TEXT,
        targetMinutesPerDay INTEGER DEFAULT 15,
        targetExercisesPerDay INTEGER DEFAULT 5,
        reminderEnabled INTEGER DEFAULT 1,
        reminderHour INTEGER DEFAULT 20,
        reminderMinute INTEGER DEFAULT 0,
        currentStreak INTEGER DEFAULT 0,
        maxStreak INTEGER DEFAULT 0,
        lastActiveDate TEXT,
        level TEXT DEFAULT 'PRO Scholar 💎'
      )
    ''');

    await db.execute('''
      CREATE TABLE pronunciation_records (
        id TEXT PRIMARY KEY,
        exerciseId TEXT,
        timestamp TEXT NOT NULL,
        targetText TEXT NOT NULL,
        recognizedText TEXT NOT NULL,
        overallScore REAL NOT NULL,
        accuracyScore REAL NOT NULL,
        fluencyScore REAL NOT NULL,
        completenessScore REAL NOT NULL,
        wordsJson TEXT NOT NULL,
        mispronouncedSounds TEXT,
        generalFeedback TEXT,
        recommendedDrills TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE practice_sessions (
        id TEXT PRIMARY KEY,
        dateString TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        exercisesCompleted INTEGER NOT NULL,
        averageScore REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_stats (
        date TEXT PRIMARY KEY,
        minutesLearned INTEGER DEFAULT 0,
        exercisesCompleted INTEGER DEFAULT 0,
        streakCount INTEGER DEFAULT 0
      )
    ''');

    // Insert initial default user
    final initialUser = UserProfile(
      id: 'default_user',
      name: 'linhdontcare',
      nickname: 'LDC',
      targetMinutesPerDay: 15,
      targetExercisesPerDay: 5,
      reminderEnabled: true,
      reminderHour: 20,
      reminderMinute: 0,
      currentStreak: 0,
      maxStreak: 0,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
      level: 'PRO Scholar 💎',
    );
    await db.insert('users', initialUser.toMap());
  }

  // User Profile Operations
  Future<UserProfile> getUserProfile() async {
    if (SupabaseService.instance.isInitialized) {
      final supaUser = await SupabaseService.instance.getUserProfile();
      if (supaUser != null) {
        _webUser = supaUser;
        return supaUser;
      }
    }

    if (kIsWeb) {
      return _webUser;
    }
    final db = await database;
    if (db == null) return _webUser;

    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    final defaultUser = UserProfile(
      id: 'default_user',
      name: 'linhdontcare',
      nickname: 'LDC',
      level: 'PRO Scholar 💎',
    );
    await db.insert('users', defaultUser.toMap());
    return defaultUser;
  }

  Future<int> updateUserProfile(UserProfile user) async {
    if (SupabaseService.instance.isInitialized) {
      await SupabaseService.instance.updateUserProfile(user);
    }

    if (kIsWeb) {
      _webUser = user;
      return 1;
    }
    final db = await database;
    if (db == null) {
      _webUser = user;
      return 1;
    }

    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Pronunciation Records Operations
  Future<int> insertPronunciationResult(PronunciationResult result) async {
    final res = await insertOrUpdatePronunciationResult(result);
    return res['isNewUnique'] == true ? 1 : 0;
  }

  // Chèn hoặc cập nhật kết quả phân tích âm vị:
  // - Nếu là câu mới trong ngày: chèn mới, trả về isNewUnique: true
  // - Nếu câu này đã luyện hôm nay: cập nhật nếu điểm cao hơn, trả về isNewUnique: false
  Future<Map<String, dynamic>> insertOrUpdatePronunciationResult(PronunciationResult result) async {
    final today = result.timestamp.toIso8601String().substring(0, 10);
    double? previousScore;
    bool isNewUnique = false;

    if (SupabaseService.instance.isInitialized) {
      final supaRes = await SupabaseService.instance.insertOrUpdatePronunciationResult(result);
      isNewUnique = supaRes['isNewUnique'] as bool? ?? false;
      previousScore = (supaRes['previousScore'] as num?)?.toDouble();
    }

    if (kIsWeb) {
      final existingIndex = _webHistory.indexWhere((r) =>
          r.targetText.trim().toLowerCase() == result.targetText.trim().toLowerCase() &&
          r.timestamp.toIso8601String().startsWith(today));

      if (existingIndex >= 0) {
        previousScore = _webHistory[existingIndex].overallScore;
        isNewUnique = false;
        if (result.overallScore > previousScore) {
          _webHistory[existingIndex] = result;
        }
      } else {
        _webHistory.insert(0, result);
        isNewUnique = true;
      }
      return {'isNewUnique': isNewUnique, 'previousScore': previousScore};
    }

    final db = await database;
    if (db == null) {
      return {'isNewUnique': isNewUnique, 'previousScore': previousScore};
    }

    // Kiểm tra câu này đã luyện trong ngày hôm nay chưa
    final existing = await db.query(
      'pronunciation_records',
      where: 'LOWER(TRIM(targetText)) = ? AND timestamp LIKE ?',
      whereArgs: [result.targetText.trim().toLowerCase(), '$today%'],
      orderBy: 'overallScore DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      previousScore = (existing.first['overallScore'] as num?)?.toDouble() ?? 0.0;
      isNewUnique = false;
      final existingId = existing.first['id'] as String;
      if (result.overallScore > previousScore) {
        // Cập nhật điểm số cao hơn vào Database
        await db.update(
          'pronunciation_records',
          result.toMap(),
          where: 'id = ?',
          whereArgs: [existingId],
        );
      }
    } else {
      await db.insert(
        'pronunciation_records',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      isNewUnique = true;
    }

    return {'isNewUnique': isNewUnique, 'previousScore': previousScore};
  }

  // Đếm số câu duy nhất (Unique Sentences) đã luyện hôm nay
  Future<int> getUniqueExercisesCountToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (SupabaseService.instance.isInitialized) {
      final supaCount = await SupabaseService.instance.getUniqueExercisesCountToday();
      if (supaCount > 0) return supaCount;
    }

    if (kIsWeb) {
      final todayRecs = _webHistory.where((r) => r.timestamp.toIso8601String().startsWith(today));
      return todayRecs.map((r) => r.targetText.trim().toLowerCase()).toSet().length;
    }

    final db = await database;
    if (db == null) return 0;

    final res = await db.rawQuery(
      "SELECT COUNT(DISTINCT LOWER(TRIM(targetText))) as count FROM pronunciation_records WHERE timestamp LIKE ?",
      ['$today%'],
    );
    if (res.isNotEmpty) {
      return (res.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<List<PronunciationResult>> getPronunciationHistory({int limit = 50}) async {
    if (SupabaseService.instance.isInitialized) {
      final supaList = await SupabaseService.instance.getPronunciationHistory(limit: limit);
      if (supaList.isNotEmpty) {
        return supaList;
      }
    }

    if (kIsWeb) {
      return _webHistory.take(limit).toList();
    }
    final db = await database;
    if (db == null) {
      return _webHistory.take(limit).toList();
    }

    final maps = await db.query(
      'pronunciation_records',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => PronunciationResult.fromMap(m)).toList();
  }

  Future<Map<String, int>> getMostFrequentMistakes({int limit = 5}) async {
    final records = await getPronunciationHistory(limit: 100);
    final Map<String, int> counts = {};
    for (var r in records) {
      for (var sound in r.mispronouncedSounds) {
        final clean = sound.trim();
        if (clean.isNotEmpty) {
          counts[clean] = (counts[clean] ?? 0) + 1;
        }
      }
    }
    // Sort descending
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(limit));
  }

  // Practice Sessions & Daily Stats Operations
  Future<int> insertPracticeSession(PracticeSession session) async {
    if (SupabaseService.instance.isInitialized) {
      await SupabaseService.instance.insertPracticeSession(session);
    }

    final minutesAdded = (session.durationSeconds / 60).ceil();
    final today = session.dateString;

    final uniqueCount = await getUniqueExercisesCountToday();

    if (kIsWeb) {
      _webSessions.insert(0, session);
      final current = _webDailyStats[today] ?? {
        'date': today,
        'minutesLearned': 0,
        'exercisesCompleted': 0,
        'streakCount': 1,
      };
      _webDailyStats[today] = {
        'date': today,
        'minutesLearned': (current['minutesLearned'] as int? ?? 0) + minutesAdded,
        'exercisesCompleted': uniqueCount > 0 ? uniqueCount : (current['exercisesCompleted'] as int? ?? 0) + session.exercisesCompleted,
        'streakCount': 1,
      };
      return 1;
    }

    final db = await database;
    if (db == null) return 1;

    final res = await db.insert(
      'practice_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update daily_stats (chỉ cập nhật số câu duy nhất đã hoàn thành)
    final existingStats = await db.query(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existingStats.isNotEmpty) {
      final currentMinutes = existingStats.first['minutesLearned'] as int? ?? 0;
      final currentEx = existingStats.first['exercisesCompleted'] as int? ?? 0;
      await db.update(
        'daily_stats',
        {
          'minutesLearned': currentMinutes + minutesAdded,
          'exercisesCompleted': uniqueCount > 0 ? uniqueCount : (currentEx + session.exercisesCompleted),
        },
        where: 'date = ?',
        whereArgs: [today],
      );
    } else {
      await db.insert('daily_stats', {
        'date': today,
        'minutesLearned': minutesAdded,
        'exercisesCompleted': uniqueCount > 0 ? uniqueCount : session.exercisesCompleted,
        'streakCount': 1,
      });
    }

    return res;
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final uniqueCount = await getUniqueExercisesCountToday();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (SupabaseService.instance.isInitialized) {
      final supaStats = await SupabaseService.instance.getTodayStats();
      if (supaStats != null) {
        return {
          ...supaStats,
          'exercisesCompleted': uniqueCount > 0 ? uniqueCount : (supaStats['exercisesCompleted'] ?? 0),
        };
      }
    }

    if (kIsWeb) {
      final stats = _webDailyStats[today] ?? {
        'date': today,
        'minutesLearned': 0,
        'exercisesCompleted': uniqueCount,
        'streakCount': 0,
      };
      stats['exercisesCompleted'] = uniqueCount > 0 ? uniqueCount : (stats['exercisesCompleted'] ?? 0);
      return stats;
    }

    final db = await database;
    if (db == null) {
      return {
        'date': today,
        'minutesLearned': 0,
        'exercisesCompleted': uniqueCount,
        'streakCount': 0,
      };
    }

    final results = await db.query(
      'daily_stats',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (results.isNotEmpty) {
      final m = Map<String, dynamic>.from(results.first);
      m['exercisesCompleted'] = uniqueCount > 0 ? uniqueCount : (m['exercisesCompleted'] ?? 0);
      return m;
    }
    return {
      'date': today,
      'minutesLearned': 0,
      'exercisesCompleted': uniqueCount,
      'streakCount': 0,
    };
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    if (SupabaseService.instance.isInitialized) {
      final supaWeekly = await SupabaseService.instance.getWeeklyStats();
      if (supaWeekly.isNotEmpty) {
        return supaWeekly;
      }
    }

    if (kIsWeb) {
      return _webDailyStats.values.toList();
    }
    final db = await database;
    if (db == null) return [];

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final startDateStr = sevenDaysAgo.toIso8601String().substring(0, 10);

    return await db.query(
      'daily_stats',
      where: 'date >= ?',
      whereArgs: [startDateStr],
      orderBy: 'date ASC',
    );
  }

  Future<void> clearAllData() async {
    if (SupabaseService.instance.isInitialized) {
      await SupabaseService.instance.clearAllData();
    }

    if (kIsWeb) {
      _webHistory.clear();
      _webSessions.clear();
      _webDailyStats.clear();
      return;
    }
    final db = await database;
    if (db != null) {
      await db.delete('pronunciation_records');
      await db.delete('practice_sessions');
      await db.delete('daily_stats');
    }
  }
}
