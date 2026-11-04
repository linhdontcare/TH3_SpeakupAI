import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:speakupai/services/database_helper.dart';
import 'package:speakupai/models/pronunciation_result.dart';
import 'package:speakupai/models/practice_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('KIỂM TRA TOÀN DIỆN CHECKLIST 1 - CƠ SỞ DỮ LIỆU', () {
    late DatabaseHelper db;

    setUp(() async {
      db = DatabaseHelper.instance;
      // Pre-warm database
      await db.database;
    });

    test('1. Kiểm tra lưu trữ và truy vấn Thông tin người dùng (Users Table)', () async {
      // Lấy thông tin user khởi tạo
      final user = await db.getUserProfile();
      expect(user.id, 'default_user');
      expect(user.name, 'linhdontcare');
      expect(user.nickname, 'LDC');
      expect(user.currentStreak, greaterThanOrEqualTo(0));

      // Cập nhật thông tin người dùng
      final updatedUser = user.copyWith(
        name: 'linhdontcare_updated',
        targetMinutesPerDay: 25,
        targetExercisesPerDay: 10,
        currentStreak: 6,
      );
      await db.updateUserProfile(updatedUser);

      final fetchedUser = await db.getUserProfile();
      expect(fetchedUser.name, 'linhdontcare_updated');
      expect(fetchedUser.targetMinutesPerDay, 25);
      expect(fetchedUser.targetExercisesPerDay, 10);
      expect(fetchedUser.currentStreak, 6);
    });

    test('2. Kiểm tra lưu trữ và truy vấn Lịch sử luyện tập (Practice Sessions & Daily Stats)', () async {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10);

      final session = PracticeSession(
        id: 'sess_test_01',
        dateString: todayStr,
        timestamp: now,
        durationSeconds: 120, // 2 phút
        exercisesCompleted: 3,
        averageScore: 85.5,
      );

      // Chèn phiên luyện tập vào database
      final res = await db.insertPracticeSession(session);
      expect(res, greaterThan(0));

      // Kiểm tra bảng daily_stats tự động cập nhật số phút và số câu
      final todayStats = await db.getTodayStats();
      expect(todayStats['date'], todayStr);
      expect(todayStats['minutesLearned'], greaterThanOrEqualTo(2));
      expect(todayStats['exercisesCompleted'], greaterThanOrEqualTo(3));
    });

    test('3. Kiểm tra lưu trữ và truy vấn Kết quả phân tích phát âm AI (Pronunciation Records Table)', () async {
      final result = PronunciationResult(
        id: 'rec_test_01',
        exerciseId: 'th_01',
        timestamp: DateTime.now(),
        targetText: 'I think thirty three',
        recognizedText: 'I tink thirty three',
        overallScore: 78.5,
        accuracyScore: 75.0,
        fluencyScore: 82.0,
        completenessScore: 100.0,
        words: [
          WordFeedback(
            word: 'think',
            spokenWord: 'tink',
            targetIpa: 'θɪŋk',
            spokenIpa: 'tɪŋk',
            score: 60.0,
            status: WordAccuracyStatus.poor,
            phonemes: [
              PhonemeFeedback(
                targetPhoneme: 'θ',
                detectedPhoneme: 't',
                isCorrect: false,
                articulationTip: 'Đặt đầu lưỡi giữa hai hàm răng và thổi hơi nhẹ.',
              ),
            ],
            errorAnalysis: 'Âm /θ/ phát âm nhầm thành /t/',
            practicalTip: 'Đặt đầu lưỡi giữa hai hàm răng.',
          ),
        ],
        mispronouncedSounds: ['θ'],
        generalFeedback: 'Cần chú ý âm /θ/.',
        recommendedDrills: ['Luyện âm Th thổi hơi'],
      );

      // Chèn kết quả phân tích AI vào CSDL
      final insertStatus = await db.insertPronunciationResult(result);
      expect(insertStatus, greaterThan(0));

      // Đọc lại danh sách lịch sử phân tích
      final history = await db.getPronunciationHistory(limit: 10);
      expect(history, isNotEmpty);

      final savedRecord = history.firstWhere((r) => r.id == 'rec_test_01');
      expect(savedRecord.targetText, 'I think thirty three');
      expect(savedRecord.recognizedText, 'I tink thirty three');
      expect(savedRecord.overallScore, 78.5);
      expect(savedRecord.mispronouncedSounds, contains('θ'));
      expect(savedRecord.words.first.word, 'think');
      expect(savedRecord.words.first.targetIpa, 'θɪŋk');

      // Kiểm tra thống kê âm sai nhiều nhất
      final mistakes = await db.getMostFrequentMistakes();
      expect(mistakes.containsKey('θ'), isTrue);
    });
  });
}
