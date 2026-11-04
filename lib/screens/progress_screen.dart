import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_profile.dart';
import '../services/database_helper.dart';
import '../services/streak_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProfile? _user;
  Map<String, dynamic>? _todayStats;
  List<Map<String, dynamic>> _weeklyStats = [];
  Map<String, int> _frequentMistakes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await StreakService.instance.evaluateCurrentStreak();
    final today = await DatabaseHelper.instance.getTodayStats();
    final weekly = await DatabaseHelper.instance.getWeeklyStats();
    final mistakes = await DatabaseHelper.instance.getMostFrequentMistakes();

    if (mounted) {
      setState(() {
        _user = user;
        _todayStats = today;
        _weeklyStats = weekly;
        _frequentMistakes = mistakes;
        _isLoading = false;
      });
    }
  }

  void _showSetGoalDialog() {
    if (_user == null) return;
    int selectedMinutes = _user!.targetMinutesPerDay;
    int selectedExercises = _user!.targetExercisesPerDay;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Đặt mục tiêu hàng ngày', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thời gian luyện tập mỗi ngày:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$selectedMinutes phút', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                    Slider(
                      value: selectedMinutes.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '$selectedMinutes phút',
                      onChanged: (val) {
                        setDialogState(() => selectedMinutes = val.toInt());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Số câu luyện tập mỗi ngày:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$selectedExercises câu', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    Slider(
                      value: selectedExercises.toDouble(),
                      min: 2,
                      max: 20,
                      divisions: 9,
                      label: '$selectedExercises câu',
                      onChanged: (val) {
                        setDialogState(() => selectedExercises = val.toInt());
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await StreakService.instance.updateDailyGoals(
                    targetMinutes: selectedMinutes,
                    targetExercises: selectedExercises,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  _loadData();
                },
                child: const Text('Lưu mục tiêu', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final minutesDone = _todayStats?['minutesLearned'] as int? ?? 0;
    final exercisesDone = _todayStats?['exercisesCompleted'] as int? ?? 0;
    final targetMins = _user!.targetMinutesPerDay;
    final targetEx = _user!.targetExercisesPerDay;

    final minsRatio = (minutesDone / targetMins).clamp(0.0, 1.0);
    final exRatio = (exercisesDone / targetEx).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tiến độ & Thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Big Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _user!.currentStreak <= 0
                      ? const [Color(0xFF64748B), Color(0xFF94A3B8)]
                      : const [Color(0xFFFF5722), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _user!.currentStreak <= 0
                        ? Colors.black.withOpacity(0.12)
                        : const Color(0xFFFF5722).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: _user!.currentStreak <= 0 ? Colors.white70 : const Color(0xFFFFEE58),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.currentStreak <= 0
                              ? 'Chuỗi streak: 0 ngày'
                              : 'Chuỗi streak: ${_user!.currentStreak} ngày',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.currentStreak <= 0
                              ? 'Luyện đủ 5 câu hôm nay để thắp lại ngọn lửa nhé!'
                              : 'Kỷ lục dài nhất: ${_user!.maxStreak} ngày liên tiếp',
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Target Tracker Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mục tiêu học hôm nay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16, color: Color(0xFF4F46E5)),
                        label: const Text('Đặt lại', style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13)),
                        onPressed: _showSetGoalDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Minutes bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thời gian: $minutesDone / $targetMins phút', style: const TextStyle(fontSize: 13)),
                      Text('${(minsRatio * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: minsRatio,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Exercises bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Số câu luyện: $exercisesDone / $targetEx câu', style: const TextStyle(fontSize: 13)),
                      Text('${(exRatio * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: exRatio,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Time Chart
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian luyện tập (7 ngày gần nhất)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 45,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                final index = val.toInt() % days.length;
                                return Text(days[index], style: const TextStyle(fontSize: 11, color: Colors.grey));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (val, meta) {
                                if (val % 15 == 0) {
                                  return Text('${val.toInt()}p', style: const TextStyle(fontSize: 10, color: Colors.grey));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          double minutes = 0.0;
                          if (i < _weeklyStats.length) {
                            minutes = (_weeklyStats[i]['minutesLearned'] as int? ?? 0).toDouble();
                          }
                          if (i == 6 && minutes == 0.0) {
                            minutes = minutesDone.toDouble();
                          }
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: minutes,
                                color: i == 6 ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                                width: 16,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weak Phonemes Analysis Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFFEF4444)),
                      SizedBox(width: 8),
                      Text(
                        'Các âm bạn hay phát âm sai nhất:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_frequentMistakes.isEmpty)
                    const Text(
                      'Chưa có dữ liệu lỗi phát âm. Hãy hoàn thành các bài học để AI phân tích!',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _frequentMistakes.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '/${entry.key}/',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C), fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB91C1C),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${entry.value} lần',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
