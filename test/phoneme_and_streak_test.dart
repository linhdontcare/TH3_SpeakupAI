import 'package:flutter_test/flutter_test.dart';
import 'package:speakupai/services/phoneme_engine.dart';
import 'package:speakupai/services/benchmark_service.dart';
import 'package:speakupai/models/user_profile.dart';

void main() {
  group('PhonemeEngine & Pronunciation Analysis Tests (Checklist 4 & 5)', () {
    late PhonemeEngine engine;

    setUp(() {
      engine = PhonemeEngine.instance;
    });

    test('IPA conversion for known and heuristic words', () {
      expect(engine.wordToIpa('think'), 'θɪŋk');
      expect(engine.wordToIpa('weather'), 'ˈwɛðər');
      expect(engine.wordToIpa('seat'), 'siːt');
      expect(engine.wordToIpa('sit'), 'sɪt');
      expect(engine.wordToIpa('six'), 'sɪks');
    });

    test('Phoneme extraction decomposes multi-char phonemes properly', () {
      final phonemes = engine.extractPhonemes('θɪŋk');
      expect(phonemes, contains('θ'));
      expect(phonemes, contains('ŋ'));
    });

    test('Native speaker gives high overall score (>= 90%)', () {
      const target = 'I think thirty three thousand people came to the theater';
      const spoken = 'I think thirty three thousand people came to the theater';

      final result = engine.analyzePronunciation(
        targetSentence: target,
        spokenSentence: spoken,
      );

      expect(result.overallScore, greaterThanOrEqualTo(90.0));
      expect(result.accuracyScore, 100.0);
      expect(result.completenessScore, 100.0);
      expect(result.mispronouncedSounds, isEmpty);
    });

    test('Vietnamese accent errors (/θ/ -> /t/) are detected and penalized', () {
      const target = 'I think thirty three thousand people came to the theater';
      const spoken = 'I tink dirty tree tousand people came to de teater';

      final result = engine.analyzePronunciation(
        targetSentence: target,
        spokenSentence: spoken,
      );

      // Score should be moderately lower
      expect(result.overallScore, lessThan(80.0));
      expect(result.overallScore, greaterThan(35.0));
      // Mispronounced sounds should flag /θ/
      expect(result.mispronouncedSounds, contains('θ'));
      // Feedback advice should be provided
      expect(result.recommendedDrills, isNotEmpty);
    });

    test('Dropped ending sounds are identified and flagged', () {
      const target = 'Six desks and five boxes are on the list';
      const spoken = 'Si desk and fie boxe are on the lis';

      final result = engine.analyzePronunciation(
        targetSentence: target,
        spokenSentence: spoken,
      );

      expect(result.overallScore, lessThan(80.0));
      expect(result.mispronouncedSounds.any((s) => s.contains('s') || s.contains('ks') || s.contains('st')), isTrue);
    });
  });

  group('Benchmark Lab Suite (Checklist 7)', () {
    test('All default benchmark cases pass within expected score thresholds', () {
      final results = BenchmarkService.runAllBenchmarks();
      expect(results.length, 5);
      for (final res in results) {
        expect(res.passed, isTrue, reason: 'Failed test case: ${res.testCase.personaName}: ${res.commentary}');
      }
    });
  });

  group('User Profile & Streak Model Tests (Checklist 1 & 2)', () {
    test('UserProfile serialization and deserialization', () {
      final user = UserProfile(
        id: 'u1',
        name: 'linhdontcare',
        nickname: 'LDC',
        targetMinutesPerDay: 20,
        targetExercisesPerDay: 8,
        currentStreak: 5,
        maxStreak: 12,
        reminderHour: 21,
        reminderMinute: 30,
      );

      final map = user.toMap();
      final restored = UserProfile.fromMap(map);

      expect(restored.id, 'u1');
      expect(restored.name, 'linhdontcare');
      expect(restored.nickname, 'LDC');
      expect(restored.targetMinutesPerDay, 20);
      expect(restored.targetExercisesPerDay, 8);
      expect(restored.currentStreak, 5);
      expect(restored.maxStreak, 12);
      expect(restored.reminderHour, 21);
      expect(restored.reminderMinute, 30);
    });

    test('UserProfile copyWith maintains unchanged fields', () {
      final user = UserProfile(id: 'u1', name: 'Test', currentStreak: 1);
      final updated = user.copyWith(currentStreak: 2);

      expect(updated.currentStreak, 2);
      expect(updated.name, 'Test');
    });

    test('Default initial streak is 0', () {
      final defaultUser = UserProfile(id: 'default');
      expect(defaultUser.currentStreak, 0);
      expect(defaultUser.maxStreak, 0);
    });
  });
}

