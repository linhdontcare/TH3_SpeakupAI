import '../models/pronunciation_result.dart';
import 'phoneme_engine.dart';

class BenchmarkCase {
  final String personaName;
  final String accentDescription;
  final String targetText;
  final String simulatedSpokenText;
  final double expectedMinScore;
  final double expectedMaxScore;
  final List<String> expectedDetectedErrors;
  final String description;

  const BenchmarkCase({
    required this.personaName,
    required this.accentDescription,
    required this.targetText,
    required this.simulatedSpokenText,
    required this.expectedMinScore,
    required this.expectedMaxScore,
    required this.expectedDetectedErrors,
    required this.description,
  });
}

class BenchmarkResultItem {
  final BenchmarkCase testCase;
  final PronunciationResult result;
  final bool passed;
  final String commentary;

  BenchmarkResultItem({
    required this.testCase,
    required this.result,
    required this.passed,
    required this.commentary,
  });
}

class BenchmarkService {
  static final List<BenchmarkCase> defaultCases = [
    const BenchmarkCase(
      personaName: 'Bản xứ (Native Speaker - US)',
      accentDescription: 'Giọng chuẩn Mỹ, phát âm rõ âm gió, âm nối và nguyên âm chuẩn',
      targetText: 'I think thirty three thousand people came to the theater',
      simulatedSpokenText: 'I think thirty three thousand people came to the theater',
      expectedMinScore: 90.0,
      expectedMaxScore: 100.0,
      expectedDetectedErrors: [],
      description: 'Kiểm tra độ nhạy khi người dùng phát âm hoàn hảo.',
    ),
    const BenchmarkCase(
      personaName: 'Người học Việt Nam (Lỗi âm /θ/ & /ð/)',
      accentDescription: 'Thay thế âm /θ/ bằng /t/ và /ð/ bằng /d/',
      targetText: 'I think thirty three thousand people came to the theater',
      simulatedSpokenText: 'I tink dirty tree tousand people came to de teater',
      expectedMinScore: 40.0,
      expectedMaxScore: 78.0,
      expectedDetectedErrors: ['θ', 'ð'],
      description: 'Kiểm tra phát hiện lỗi thay thế âm vị đặc trưng của người Việt.',
    ),
    const BenchmarkCase(
      personaName: 'Lỗi nuốt âm đuôi (Dropped Ending Sounds)',
      accentDescription: 'Bỏ qua các phụ âm cuối /ks/, /sks/, /v/, /ɪz/, /st/',
      targetText: 'Six desks and five boxes are on the list',
      simulatedSpokenText: 'Si desk and fie boxe are on the lis',
      expectedMinScore: 40.0,
      expectedMaxScore: 85.0,
      expectedDetectedErrors: ['ks', 'sks', 'st'],
      description: 'Kiểm tra phát hiện thiếu âm đuôi (final consonant clusters).',
    ),
    const BenchmarkCase(
      personaName: 'Nhầm lẫn Cặp từ tối thiểu (/iː/ vs /ɪ/)',
      accentDescription: 'Nhầm lẫn giữa nguyên âm dài và nguyên âm ngắn trong seat/sit',
      targetText: 'Please sit in this seat and drink green tea',
      simulatedSpokenText: 'Please seat in this sit and drink grin ti',
      expectedMinScore: 50.0,
      expectedMaxScore: 85.0,
      expectedDetectedErrors: ['iː', 'ɪ'],
      description: 'Kiểm tra độ phân biệt nguyên âm đôi và nguyên âm ngắn/dài.',
    ),
    const BenchmarkCase(
      personaName: 'Phát âm đứt đoạn / Bỏ sót từ (Hesitant Beginner)',
      accentDescription: 'Ngắt quãng, bỏ sót một nửa số từ trong câu dài',
      targetText: 'We need to optimize the database query to improve performance',
      simulatedSpokenText: 'We need optimize database',
      expectedMinScore: 20.0,
      expectedMaxScore: 55.0,
      expectedDetectedErrors: [],
      description: 'Kiểm tra thuật toán tính toán Completeness (Độ hoàn chỉnh câu).',
    ),
  ];

  static List<BenchmarkResultItem> runAllBenchmarks() {
    final engine = PhonemeEngine.instance;
    final List<BenchmarkResultItem> report = [];

    for (final testCase in defaultCases) {
      final result = engine.analyzePronunciation(
        targetSentence: testCase.targetText,
        spokenSentence: testCase.simulatedSpokenText,
      );

      final scorePassed = result.overallScore >= testCase.expectedMinScore &&
          result.overallScore <= testCase.expectedMaxScore;

      bool errorsMatched = true;
      if (testCase.expectedDetectedErrors.isNotEmpty) {
        errorsMatched = testCase.expectedDetectedErrors.any(
          (err) => result.mispronouncedSounds.contains(err),
        );
      }

      final passed = scorePassed && errorsMatched;
      final commentary = passed
          ? 'Đạt: Điểm số (${result.overallScore}%) và nhận diện lỗi âm vị khớp với dự kiến.'
          : 'Cần hiệu chỉnh: Điểm thực tế (${result.overallScore}%) ngoài khoảng dự kiến [${testCase.expectedMinScore} - ${testCase.expectedMaxScore}]%.';

      report.add(BenchmarkResultItem(
        testCase: testCase,
        result: result,
        passed: passed,
        commentary: commentary,
      ));
    }

    return report;
  }
}
