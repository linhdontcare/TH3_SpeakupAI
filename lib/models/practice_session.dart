class PracticeSession {
  final String id;
  final String dateString; // YYYY-MM-DD
  final DateTime timestamp;
  final int durationSeconds;
  final int exercisesCompleted;
  final double averageScore;

  PracticeSession({
    required this.id,
    required this.dateString,
    required this.timestamp,
    required this.durationSeconds,
    required this.exercisesCompleted,
    required this.averageScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateString': dateString,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
      'exercisesCompleted': exercisesCompleted,
      'averageScore': averageScore,
    };
  }

  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'] ?? '',
      dateString: map['dateString'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      durationSeconds: map['durationSeconds'] is int ? map['durationSeconds'] : 0,
      exercisesCompleted: map['exercisesCompleted'] is int ? map['exercisesCompleted'] : 0,
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

