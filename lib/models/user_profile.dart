import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String nickname;
  final String avatar;
  final int targetMinutesPerDay;
  final int targetExercisesPerDay;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int currentStreak;
  final int maxStreak;
  final String? lastActiveDate; // YYYY-MM-DD
  final String level; // Beginner, Intermediate, Advanced, PRO Scholar

  UserProfile({
    required this.id,
    this.name = 'linhdontcare',
    this.nickname = 'LDC',
    this.avatar = 'assets/avatars/user_default.png',
    this.targetMinutesPerDay = 15,
    this.targetExercisesPerDay = 5,
    this.reminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastActiveDate,
    this.level = 'PRO Scholar 💎',
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? nickname,
    String? avatar,
    int? targetMinutesPerDay,
    int? targetExercisesPerDay,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? currentStreak,
    int? maxStreak,
    String? lastActiveDate,
    String? level,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      targetMinutesPerDay: targetMinutesPerDay ?? this.targetMinutesPerDay,
      targetExercisesPerDay: targetExercisesPerDay ?? this.targetExercisesPerDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'avatar': avatar,
      'targetMinutesPerDay': targetMinutesPerDay,
      'targetExercisesPerDay': targetExercisesPerDay,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'lastActiveDate': lastActiveDate,
      'level': level,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? 'user_1',
      name: map['name'] ?? 'linhdontcare',
      nickname: map['nickname'] ?? 'LDC',
      avatar: map['avatar'] ?? 'assets/avatars/user_default.png',
      targetMinutesPerDay: map['targetMinutesPerDay'] is int ? map['targetMinutesPerDay'] : 15,
      targetExercisesPerDay: map['targetExercisesPerDay'] is int ? map['targetExercisesPerDay'] : 5,
      reminderEnabled: map['reminderEnabled'] == 1 || map['reminderEnabled'] == true,
      reminderHour: map['reminderHour'] is int ? map['reminderHour'] : 20,
      reminderMinute: map['reminderMinute'] is int ? map['reminderMinute'] : 0,
      currentStreak: map['currentStreak'] is int ? map['currentStreak'] : 0,
      maxStreak: map['maxStreak'] is int ? map['maxStreak'] : 0,
      lastActiveDate: map['lastActiveDate'] ?? DateTime.now().toIso8601String().substring(0, 10),
      level: map['level'] ?? 'PRO Scholar 💎',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
