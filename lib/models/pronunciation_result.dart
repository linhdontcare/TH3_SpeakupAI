import 'dart:convert';

enum WordAccuracyStatus {
  excellent, // 85 - 100
  acceptable, // 60 - 84
  poor, // < 60
}

class PhonemeFeedback {
  final String targetPhoneme;
  final String? detectedPhoneme;
  final bool isCorrect;
  final String soundType; // vowel / consonant / diphthong
  final String articulationTip;

  PhonemeFeedback({
    required this.targetPhoneme,
    this.detectedPhoneme,
    required this.isCorrect,
    this.soundType = 'consonant',
    this.articulationTip = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'targetPhoneme': targetPhoneme,
      'detectedPhoneme': detectedPhoneme,
      'isCorrect': isCorrect,
      'soundType': soundType,
      'articulationTip': articulationTip,
    };
  }

  factory PhonemeFeedback.fromMap(Map<String, dynamic> map) {
    return PhonemeFeedback(
      targetPhoneme: map['targetPhoneme'] ?? '',
      detectedPhoneme: map['detectedPhoneme'],
      isCorrect: map['isCorrect'] == true || map['isCorrect'] == 1,
      soundType: map['soundType'] ?? 'consonant',
      articulationTip: map['articulationTip'] ?? '',
    );
  }
}

class WordFeedback {
  final String word;
  final String spokenWord;
  final String targetIpa;
  final String spokenIpa;
  final double score; // 0 - 100
  final WordAccuracyStatus status;
  final List<PhonemeFeedback> phonemes;
  final String errorAnalysis;
  final String practicalTip;

  WordFeedback({
    required this.word,
    required this.spokenWord,
    required this.targetIpa,
    required this.spokenIpa,
    required this.score,
    required this.status,
    required this.phonemes,
    this.errorAnalysis = '',
    this.practicalTip = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'spokenWord': spokenWord,
      'targetIpa': targetIpa,
      'spokenIpa': spokenIpa,
      'score': score,
      'status': status.name,
      'phonemes': phonemes.map((p) => p.toMap()).toList(),
      'errorAnalysis': errorAnalysis,
      'practicalTip': practicalTip,
    };
  }

  factory WordFeedback.fromMap(Map<String, dynamic> map) {
    return WordFeedback(
      word: map['word'] ?? '',
      spokenWord: map['spokenWord'] ?? '',
      targetIpa: map['targetIpa'] ?? '',
      spokenIpa: map['spokenIpa'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      status: WordAccuracyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WordAccuracyStatus.poor,
      ),
      phonemes: (map['phonemes'] as List<dynamic>?)
              ?.map((p) => PhonemeFeedback.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      errorAnalysis: map['errorAnalysis'] ?? '',
      practicalTip: map['practicalTip'] ?? '',
    );
  }
}

class PronunciationResult {
  final String id;
  final String? exerciseId;
  final DateTime timestamp;
  final String targetText;
  final String recognizedText;
  final double overallScore; // 0 - 100
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final List<WordFeedback> words;
  final List<String> mispronouncedSounds;
  final String generalFeedback;
  final List<String> recommendedDrills;

  PronunciationResult({
    required this.id,
    this.exerciseId,
    required this.timestamp,
    required this.targetText,
    required this.recognizedText,
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.words,
    required this.mispronouncedSounds,
    required this.generalFeedback,
    required this.recommendedDrills,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'timestamp': timestamp.toIso8601String(),
      'targetText': targetText,
      'recognizedText': recognizedText,
      'overallScore': overallScore,
      'accuracyScore': accuracyScore,
      'fluencyScore': fluencyScore,
      'completenessScore': completenessScore,
      'wordsJson': jsonEncode(words.map((w) => w.toMap()).toList()),
      'mispronouncedSounds': mispronouncedSounds.join(','),
      'generalFeedback': generalFeedback,
      'recommendedDrills': recommendedDrills.join(';'),
    };
  }

  factory PronunciationResult.fromMap(Map<String, dynamic> map) {
    List<WordFeedback> parsedWords = [];
    if (map['wordsJson'] != null && map['wordsJson'].isNotEmpty) {
      try {
        final decoded = jsonDecode(map['wordsJson']) as List;
        parsedWords = decoded.map((item) => WordFeedback.fromMap(item)).toList();
      } catch (_) {}
    }

    return PronunciationResult(
      id: map['id'] ?? '',
      exerciseId: map['exerciseId'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      targetText: map['targetText'] ?? '',
      recognizedText: map['recognizedText'] ?? '',
      overallScore: (map['overallScore'] as num?)?.toDouble() ?? 0.0,
      accuracyScore: (map['accuracyScore'] as num?)?.toDouble() ?? 0.0,
      fluencyScore: (map['fluencyScore'] as num?)?.toDouble() ?? 0.0,
      completenessScore: (map['completenessScore'] as num?)?.toDouble() ?? 0.0,
      words: parsedWords,
      mispronouncedSounds: map['mispronouncedSounds'] != null &&
              map['mispronouncedSounds'].isNotEmpty
          ? (map['mispronouncedSounds'] as String).split(',')
          : [],
      generalFeedback: map['generalFeedback'] ?? '',
      recommendedDrills: map['recommendedDrills'] != null &&
              map['recommendedDrills'].isNotEmpty
          ? (map['recommendedDrills'] as String).split(';')
          : [],
    );
  }
}

