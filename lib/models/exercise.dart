class Exercise {
  final String id;
  final String category;
  final String title;
  final String targetText;
  final String phoneticIpa;
  final String meaningVi;
  final String difficulty; // Easy, Medium, Hard
  final List<String> targetPhonemes; // e.g., ['θ', 'ð', 'iː', 's']
  final String pronunciationTip;

  const Exercise({
    required this.id,
    required this.category,
    required this.title,
    required this.targetText,
    required this.phoneticIpa,
    required this.meaningVi,
    this.difficulty = 'Medium',
    this.targetPhonemes = const [],
    this.pronunciationTip = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'targetText': targetText,
      'phoneticIpa': phoneticIpa,
      'meaningVi': meaningVi,
      'difficulty': difficulty,
      'targetPhonemes': targetPhonemes.join(','),
      'pronunciationTip': pronunciationTip,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      category: map['category'] ?? 'Giao tiếp hàng ngày',
      title: map['title'] ?? '',
      targetText: map['targetText'] ?? '',
      phoneticIpa: map['phoneticIpa'] ?? '',
      meaningVi: map['meaningVi'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      targetPhonemes: map['targetPhonemes'] != null && map['targetPhonemes'].isNotEmpty
          ? (map['targetPhonemes'] as String).split(',')
          : [],
      pronunciationTip: map['pronunciationTip'] ?? '',
    );
  }
}

