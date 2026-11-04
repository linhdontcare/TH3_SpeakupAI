import 'dart:math';
import '../models/pronunciation_result.dart';

class PhonemeEngine {
  static final PhonemeEngine instance = PhonemeEngine._init();
  PhonemeEngine._init();

  // Common English words to IPA mapping
  static final Map<String, String> _ipaDictionary = {
    // Pronouns & Articles
    'i': 'aɪ',
    'you': 'juː',
    'he': 'hiː',
    'she': 'ʃiː',
    'it': 'ɪt',
    'we': 'wiː',
    'they': 'ðeɪ',
    'the': 'ðə',
    'a': 'ə',
    'an': 'æn',
    'this': 'ðɪs',
    'that': 'ðæt',
    'these': 'ðiːz',
    'those': 'ðəʊz',
    'my': 'maɪ',
    'your': 'jɔːr',
    'his': 'hɪz',
    'her': 'hɜːr',
    'our': 'ˈaʊər',
    'their': 'ðeər',
    'us': 'ʌs',

    // Verbs
    'is': 'ɪz',
    'am': 'æm',
    'are': 'ɑːr',
    'was': 'wɒz',
    'were': 'wɜːr',
    'be': 'biː',
    'have': 'hæv',
    'has': 'hæz',
    'had': 'hæd',
    'do': 'duː',
    'does': 'dʌz',
    'did': 'dɪd',
    'can': 'kæn',
    'could': 'kʊd',
    'will': 'wɪl',
    'would': 'wʊd',
    'should': 'ʃʊd',
    'think': 'θɪŋk',
    'thought': 'θɔːt',
    'speak': 'spiːk',
    'say': 'seɪ',
    'talk': 'tɔːk',
    'walk': 'wɔːk',
    'walked': 'wɔːkt',
    'decide': 'dɪˈsaɪd',
    'decided': 'dɪˈsaɪdɪd',
    'call': 'kɔːl',
    'called': 'kɔːld',
    'rest': 'rɛst',
    'meet': 'miːt',
    'see': 'siː',
    'sit': 'sɪt',
    'sell': 'sɛl',
    'sells': 'sɛlz',
    'drink': 'drɪŋk',
    'need': 'niːd',
    'want': 'wɒnt',
    'help': 'hɛlp',
    'practice': 'ˈpræktɪs',
    'learn': 'lɜːn',
    'schedule': 'ˈskɛdʒuːl',
    'review': 'rɪˈvjuː',
    'optimize': 'ˈɒptɪmaɪz',
    'improve': 'ɪmˈpruːv',
    'came': 'keɪm',
    'come': 'kʌm',
    'tell': 'tɛl',
    'get': 'ɡɛt',
    'love': 'lʌv',
    'breathing': 'ˈbriːðɪŋ',
    'ask': 'ɑːsk',
    'asks': 'ɑːsks',
    'test': 'tɛst',
    'accept': 'əkˈsɛpt',
    'accepted': 'əkˈsɛptɪd',
    'fixed': 'fɪkst',
    'put': 'pʊt',
    'drive': 'draɪv',
    'like': 'laɪk',
    'grab': 'ɡræb',
    'deploy': 'dɪˈplɔɪ',
    'present': 'prɪˈzɛnt',

    // Nouns & Adjectives
    'thirty': 'ˈθɜːti',
    'three': 'θriː',
    'thousand': 'ˈθaʊzənd',
    'people': 'ˈpiːpl',
    'theater': 'ˈθɪətər',
    'weather': 'ˈwɛðər',
    'together': 'təˈɡɛðər',
    'better': 'ˈbɛtər',
    'six': 'sɪks',
    'desk': 'dɛsk',
    'desks': 'dɛsks',
    'five': 'faɪv',
    'box': 'bɒks',
    'boxes': 'ˈbɒksɪz',
    'list': 'lɪst',
    'seat': 'siːt',
    'tea': 'tiː',
    'green': 'ɡriːn',
    'sea': 'siː',
    'shell': 'ʃɛl',
    'shells': 'ʃɛlz',
    'shore': 'ʃɔːr',
    'good': 'ɡʊd',
    'morning': 'ˈmɔːnɪŋ',
    'great': 'ɡreɪt',
    'pleasure': 'ˈplɛʒər',
    'today': 'təˈdeɪ',
    'coffee': 'ˈkɒfi',
    'shop': 'ʃɒp',
    'database': 'ˈdeɪtəbeɪs',
    'query': 'ˈkwɪəri',
    'performance': 'pəˈfɔːməns',
    'meeting': 'ˈmiːtɪŋ',
    'project': 'ˈprɒdʒɛkt',
    'status': 'ˈsteɪtəs',
    'friend': 'frɛnd',
    'quick': 'kwɪk',
    'english': 'ˈɪŋɡlɪʃ',
    'word': 'wɜːd',
    'time': 'taɪm',
    'day': 'deɪ',
    'both': 'bəʊθ',
    'father': 'ˈfɑːðər',
    'mother': 'ˈmʌðər',
    'fresh': 'frɛʃ',
    'air': 'eər',
    'third': 'θɜːd',
    'thursday': 'ˈθɜːzdeɪ',
    'month': 'mʌnθ',
    'thanksgiving': 'ˌθæŋksˈɡɪvɪŋ',
    'host': 'həʊst',
    'guest': 'ɡɛst',
    'guests': 'ɡɛsts',
    'skill': 'skɪl',
    'skills': 'skɪlz',
    'text': 'tɛkst',
    'big': 'bɪɡ',
    'black': 'blæk',
    'pen': 'pɛn',
    'into': 'ˈɪntuː',
    'brown': 'braʊn',
    'bag': 'bæɡ',
    'red': 'rɛd',
    'lorries': 'ˈlɒriz',
    'yellow': 'ˈjɛləʊ',
    'rollies': 'ˈrəʊliz',
    'lake': 'leɪk',
    'iced': 'aɪst',
    'americano': 'əˌmɛrɪˈkɑːnəʊ',
    'extra': 'ˈɛkstrə',
    'milk': 'mɪlk',
    'available': 'əˈveɪləbl',
    'lunch': 'lʌntʃ',
    'updated': 'ʌpˈdeɪtɪd',
    'version': 'ˈvɜːʃn',
    'production': 'prəˈdʌkʃn',
    'server': 'ˈsɜːvər',
    'team': 'tiːm',
    'quarterly': 'ˈkwɔːtəli',
    'report': 'rɪˈpɔːt',
    'tomorrow': 'təˈmɒrəʊ',

    // Prepositions & Conjunctions
    'in': 'ɪn',
    'on': 'ɒn',
    'at': 'æt',
    'to': 'tuː',
    'for': 'fɔːr',
    'with': 'wɪð',
    'from': 'frɒm',
    'by': 'baɪ',
    'and': 'ænd',
    'but': 'bʌt',
    'or': 'ɔːr',
    'so': 'səʊ',
    'how': 'haʊ',
    'what': 'wɒt',
    'when': 'wɛn',
    'where': 'weər',
    'why': 'waɪ',
    'please': 'pliːz',
  };

  // Convert a single word to IPA
  String wordToIpa(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (_ipaDictionary.containsKey(clean)) {
      return _ipaDictionary[clean]!;
    }
    // Heuristic fallback phonetic approximation
    return _heuristicGraphemeToPhoneme(clean);
  }

  // Heuristic Grapheme-to-Phoneme converter for words not in dictionary
  String _heuristicGraphemeToPhoneme(String word) {
    if (word.isEmpty) return '';
    String ipa = word.toLowerCase();

    // Digraph replacements
    ipa = ipa.replaceAll('ph', 'f');
    ipa = ipa.replaceAll('sh', 'ʃ');
    ipa = ipa.replaceAll('ch', 'tʃ');
    ipa = ipa.replaceAll('th', 'θ');
    ipa = ipa.replaceAll('ng', 'ŋ');
    ipa = ipa.replaceAll('ee', 'iː');
    ipa = ipa.replaceAll('ea', 'iː');
    ipa = ipa.replaceAll('oo', 'uː');
    ipa = ipa.replaceAll('ou', 'aʊ');
    ipa = ipa.replaceAll('ow', 'aʊ');
    ipa = ipa.replaceAll('ck', 'k');
    ipa = ipa.replaceAll('tion', 'ʃən');
    ipa = ipa.replaceAll('sion', 'ʒən');

    return ipa;
  }

  // Break an IPA string into discrete phoneme tokens
  List<String> extractPhonemes(String ipa) {
    final List<String> phonemes = [];
    final multiCharPhonemes = [
      'tʃ', 'dʒ', 'eɪ', 'aɪ', 'ɔɪ', 'aʊ', 'əʊ', 'ɪə', 'eə', 'ʊə',
      'iː', 'ɑː', 'ɔː', 'uː', 'ɜː', 'sks', 'skt', 'kts', 'sts', 'ks',
    ];

    String remaining = ipa.replaceAll(RegExp(r'[ˈˌ\s.]'), '');
    while (remaining.isNotEmpty) {
      bool matched = false;
      for (final multi in multiCharPhonemes) {
        if (remaining.startsWith(multi)) {
          phonemes.add(multi);
          remaining = remaining.substring(multi.length);
          matched = true;
          break;
        }
      }
      if (!matched) {
        phonemes.add(remaining.substring(0, 1));
        remaining = remaining.substring(1);
      }
    }
    return phonemes;
  }

  // Calculate Levenshtein distance between two strings
  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  // Clean raw text into words
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  // Generate specific articulation advice for Vietnamese learners
  String _getArticulationAdvice(String phoneme, String? detectedPhoneme) {
    switch (phoneme) {
      case 'θ':
        return 'Âm /θ/ (unvoiced th): Đặt đầu lưỡi nhẹ nhàng giữa hai hàm răng, đẩy luồng hơi êm qua khe răng, không làm rung dây thanh quản (tránh đọc thành /t/ hay /s/).';
      case 'ð':
        return 'Âm /ð/ (voiced th): Đặt đầu lưỡi giữa hai hàm răng tương tự /θ/ nhưng làm rung cổ họng (tránh đọc thành /d/ hay /z/).';
      case 'ʃ':
        return 'Âm /ʃ/ (sh): Chu tròn môi và hơi đẩy ra phía trước như đang ra hiệu suỵt im lặng (tránh đọc thành /s/ dẹt miệng).';
      case 'tʃ':
        return 'Âm /tʃ/ (ch): Bắt đầu bằng vị trí của âm /t/ sau đó bật nhanh sang /ʃ/, luồng hơi bật mạnh dứt khoát.';
      case 'dʒ':
        return 'Âm /dʒ/ (j): Giống âm /tʃ/ nhưng cần rung cổ họng mạnh mẽ (tránh đọc thành âm /z/ hoặc /d/).';
      case 'z':
        return 'Âm /z/: Đặt lưỡi như âm /s/ nhưng làm rung dây thanh quản, phát ra âm xì rung rõ nét.';
      case 's':
        return 'Âm /s/ (ending s): Kéo khóe miệng sang hai bên như cười nhẹ và đẩy luồng hơi xì qua kẽ răng, chú ý không nuốt âm cuối.';
      case 't':
        return 'Âm /t/ (ending t): Đầu lưỡi chạm vòm họng trên phía sau răng cửa rồi bật ra một luồng khí dứt khoát.';
      case 'd':
        return 'Âm /d/ (ending d): Giống âm /t/ nhưng rung thanh quản và ngắt hơi nhanh.';
      case 'iː':
        return 'Âm /iː/ dài: Kéo khóe miệng sang hai bên như đang cười tươi, phát âm ngân dài hơn /ɪ/.';
      case 'ɪ':
        return 'Âm /ɪ/ ngắn: Cơ miệng thả lỏng tự nhiên, phát âm ngắn và gọn hơn.';
      case 'æ':
        return 'Âm /æ/ (a bẹt): Mở rộng miệng cả về chiều dọc lẫn chiều ngang, hạ thấp hàm và đẩy lưỡi về phía trước.';
      default:
        return 'Luyện tập phát âm rõ ràng, giữ nhịp thở đều và chú ý bật các phụ âm cuối (ending sounds).';
    }
  }

  // Map identified errors to recommended practice drills
  List<String> _generateRecommendedDrills(List<String> mispronouncedSounds) {
    final Set<String> drills = {};
    for (final sound in mispronouncedSounds) {
      if (sound.contains('θ') || sound.contains('ð')) {
        drills.add('Luyện âm thổi hơi /θ/ & /ð/ (think, that, thirty)');
      }
      if (sound.contains('ʃ') || sound.contains('s')) {
        drills.add('Phân biệt cặp âm /s/ vs /ʃ/ (she sells sea shells)');
      }
      if (sound.contains('tʃ') || sound.contains('dʒ')) {
        drills.add('Luyện âm bật /tʃ/ và âm rung /dʒ/ (chair, job, project)');
      }
      if (sound.contains('t') || sound.contains('d') || sound.contains('k') || sound.contains('z')) {
        drills.add('Cải thiện âm đuôi (Ending Consonants: desks, boxes, walked)');
      }
      if (sound.contains('iː') || sound.contains('ɪ')) {
        drills.add('Cặp nguyên âm ngắn - dài /iː/ vs /ɪ/ (seat vs sit, tea)');
      }
    }

    if (drills.isEmpty) {
      drills.add('Luyện ngữ điệu và nối âm tự nhiên trong câu dài');
      drills.add('Thực hành các cặp từ đồng âm dị nghĩa (Minimal Pairs)');
    }

    return drills.toList();
  }

  // MAIN ANALYSIS PIPELINE
  PronunciationResult analyzePronunciation({
    String? exerciseId,
    required String targetSentence,
    required String spokenSentence,
  }) {
    final targetWords = _tokenize(targetSentence);
    final spokenWords = _tokenize(spokenSentence);

    final List<WordFeedback> wordFeedbacks = [];
    final Set<String> mispronouncedSounds = {};

    double totalWordScore = 0.0;
    int wordsCount = targetWords.length;

    // Compare each target word with spoken word (with tolerance for word alignment)
    for (int i = 0; i < targetWords.length; i++) {
      final targetWord = targetWords[i];
      final targetIpa = wordToIpa(targetWord);
      final targetPhonemes = extractPhonemes(targetIpa);

      String spokenWord = '';
      if (i < spokenWords.length) {
        spokenWord = spokenWords[i];
      } else {
        // Word was completely omitted
        spokenWord = '';
      }

      final spokenIpa = spokenWord.isNotEmpty ? wordToIpa(spokenWord) : '';
      final spokenPhonemes = extractPhonemes(spokenIpa);

      // Compare phonemes
      final List<PhonemeFeedback> phonemeFeedbacks = [];
      int matchingPhonemes = 0;

      for (int p = 0; p < targetPhonemes.length; p++) {
        final tp = targetPhonemes[p];
        String? detectedPh;
        bool isCorrect = false;

        if (p < spokenPhonemes.length) {
          detectedPh = spokenPhonemes[p];
          if (detectedPh == tp) {
            isCorrect = true;
            matchingPhonemes++;
          } else {
            isCorrect = false;
            mispronouncedSounds.add(tp);
          }
        } else {
          // Dropped phoneme (especially common in ending sounds)
          detectedPh = null;
          isCorrect = false;
          mispronouncedSounds.add(tp);
        }

        final isVowel = 'aeiouɑɔəɛɜɪʊæ'.contains(tp[0]);
        phonemeFeedbacks.add(PhonemeFeedback(
          targetPhoneme: tp,
          detectedPhoneme: detectedPh,
          isCorrect: isCorrect,
          soundType: isVowel ? 'vowel' : 'consonant',
          articulationTip: _getArticulationAdvice(tp, detectedPh),
        ));
      }

      // Word score calculation: combination of phoneme match & Levenshtein distance
      double wordScore = 0.0;
      if (spokenWord.isEmpty) {
        wordScore = 0.0;
      } else if (targetWord == spokenWord) {
        wordScore = 100.0;
      } else {
        final phonemeRatio = targetPhonemes.isNotEmpty
            ? (matchingPhonemes / targetPhonemes.length)
            : 0.0;
        final dist = _levenshtein(targetWord, spokenWord);
        final maxLen = max(targetWord.length, spokenWord.length);
        final editRatio = (1.0 - (dist / maxLen)).clamp(0.0, 1.0);

        wordScore = ((phonemeRatio * 0.7 + editRatio * 0.3) * 100).clamp(0.0, 100.0);
      }

      WordAccuracyStatus status;
      if (wordScore >= 80.0) {
        status = WordAccuracyStatus.excellent;
      } else if (wordScore >= 55.0) {
        status = WordAccuracyStatus.acceptable;
      } else {
        status = WordAccuracyStatus.poor;
      }

      String errorAnalysis = '';
      String practicalTip = '';
      if (wordScore < 80.0) {
        if (spokenWord.isEmpty) {
          errorAnalysis = 'Từ này bị bỏ qua hoặc máy chưa ghi nhận được âm thanh.';
          practicalTip = 'Hãy đọc to, dõng dạc và ngắt nhịp rõ ràng giữa các từ.';
        } else {
          errorAnalysis = 'Phát âm thực tế [$spokenIpa] khác với phiên âm chuẩn [$targetIpa].';
          final firstError = phonemeFeedbacks.firstWhere(
            (p) => !p.isCorrect,
            orElse: () => phonemeFeedbacks.first,
          );
          practicalTip = firstError.articulationTip;
        }
      } else {
        errorAnalysis = 'Phát âm rất tốt và chuẩn phiên âm quốc tế IPA.';
        practicalTip = 'Giữ vững độ chính xác và duy trì ngữ điệu tự nhiên!';
      }

      wordFeedbacks.add(WordFeedback(
        word: targetWord,
        spokenWord: spokenWord,
        targetIpa: targetIpa,
        spokenIpa: spokenIpa,
        score: wordScore,
        status: status,
        phonemes: phonemeFeedbacks,
        errorAnalysis: errorAnalysis,
        practicalTip: practicalTip,
      ));

      totalWordScore += wordScore;
    }

    // High level metrics
    final accuracyScore = wordsCount > 0 ? (totalWordScore / wordsCount).clamp(0.0, 100.0) : 0.0;
    
    // Completeness: proportion of words spoken
    final spokenCount = min(spokenWords.length, targetWords.length);
    final completenessScore = wordsCount > 0 ? ((spokenCount / wordsCount) * 100).clamp(0.0, 100.0) : 0.0;

    // Fluency: penalize for severe word count mismatch or too many fragmented utterances
    final lengthDiff = (spokenWords.length - targetWords.length).abs();
    final fluencyPenalty = (lengthDiff * 8.0).clamp(0.0, 40.0);
    final fluencyScore = (accuracyScore * 0.8 + 20.0 - fluencyPenalty).clamp(20.0, 100.0);

    // Weighted Overall Score
    final overallScore = ((0.60 * accuracyScore) + (0.25 * fluencyScore) + (0.15 * completenessScore)).clamp(0.0, 100.0);

    // General feedback
    String generalFeedback = '';
    if (overallScore >= 90) {
      generalFeedback = '🌟 Tuyệt vời! Phát âm của bạn rất tự nhiên, chuẩn xác và chuẩn âm vị quốc tế.';
    } else if (overallScore >= 75) {
      generalFeedback = '👍 Tốt lắm! Khả năng phát âm ổn định. Hãy chú ý hoàn thiện thêm các phụ âm cuối và âm gió.';
    } else if (overallScore >= 50) {
      generalFeedback = '⚡ Khá tốt nhưng cần lưu ý một số âm vị chưa chuẩn và chú ý phát âm đủ các từ trong câu.';
    } else {
      generalFeedback = '🎯 Đừng nản lòng! Hãy nghe lại phát âm mẫu bản xứ và thử lại từng từ chậm rãi nhé.';
    }

    final recommendedDrills = _generateRecommendedDrills(mispronouncedSounds.toList());

    return PronunciationResult(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: exerciseId,
      timestamp: DateTime.now(),
      targetText: targetSentence,
      recognizedText: spokenSentence,
      overallScore: double.parse(overallScore.toStringAsFixed(1)),
      accuracyScore: double.parse(accuracyScore.toStringAsFixed(1)),
      fluencyScore: double.parse(fluencyScore.toStringAsFixed(1)),
      completenessScore: double.parse(completenessScore.toStringAsFixed(1)),
      words: wordFeedbacks,
      mispronouncedSounds: mispronouncedSounds.toList(),
      generalFeedback: generalFeedback,
      recommendedDrills: recommendedDrills,
    );
  }
}

