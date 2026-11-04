import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_repository.dart';
import '../services/phoneme_engine.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/database_helper.dart';
import '../services/streak_service.dart';
import '../models/practice_session.dart';
import 'pronunciation_result_screen.dart';

class PracticeScreen extends StatefulWidget {
  final Exercise? initialExercise;

  const PracticeScreen({super.key, this.initialExercise});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late Exercise _currentExercise;
  final SpeechService _speech = SpeechService.instance;
  final TtsService _tts = TtsService.instance;
  final PhonemeEngine _engine = PhonemeEngine.instance;

  bool _isRecording = false;
  String _recognizedText = '';
  DateTime? _sessionStartTime;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Multi-accent simulated presets (Checklist 7)
  final List<Map<String, String>> _accentSimulations = [
    {
      'label': '🎙️ Thu âm trực tiếp bằng Micro',
      'spoken': '',
    },
    {
      'label': '🇺🇸 Giọng chuẩn Bản xứ (Native Speaker)',
      'spoken': 'NATIVE_MATCH', // replaced with target text dynamically
    },
    {
      'label': '🇻🇳 Giọng người Việt (Lỗi âm /θ/, /ð/ -> /t/, /d/)',
      'spoken': 'I tink dirty tree tousand people came to de teater',
    },
    {
      'label': '⚡ Lỗi nuốt âm đuôi (Dropped Ending Sounds)',
      'spoken': 'Si desk and fie boxe are on the lis',
    },
    {
      'label': '🔄 Nhầm lẫn Vowel (/iː/ vs /ɪ/)',
      'spoken': 'Please seat in this sit and drink grin ti',
    },
  ];

  String _selectedVoicePreset = '🎙️ Thu âm trực tiếp bằng Micro';

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.initialExercise ?? ExerciseRepository.sampleExercises.first;
    _sessionStartTime = DateTime.now();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stopListening();
    _tts.stop();
    super.dispose();
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _speech.stopListening();
      setState(() {
        _isRecording = false;
      });
    } else {
      setState(() {
        _isRecording = true;
        _recognizedText = '';
      });

      final available = await _speech.initialize();
      if (!available) {
        setState(() {
          _isRecording = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể kích hoạt Micro. Bạn có thể chọn mẫu giọng thử nghiệm bên dưới.'),
            ),
          );
        }
        return;
      }

      await _speech.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _recognizedText = text;
            });
          }
        },
      );
    }
  }

  void _onPresetChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedVoicePreset = val;
      if (val == '🇺🇸 Giọng chuẩn Bản xứ (Native Speaker)') {
        _recognizedText = _currentExercise.targetText;
      } else if (val == '🇻🇳 Giọng người Việt (Lỗi âm /θ/, /ð/ -> /t/, /d/)') {
        _recognizedText = 'I tink dirty tree tousand people came to de teater';
      } else if (val == '⚡ Lỗi nuốt âm đuôi (Dropped Ending Sounds)') {
        _recognizedText = 'Si desk and fie boxe are on the lis';
      } else if (val == '🔄 Nhầm lẫn Vowel (/iː/ vs /ɪ/)') {
        _recognizedText = 'Please seat in this sit and drink grin ti';
      } else {
        _recognizedText = '';
      }
    });
  }

  void _runAnalysis() async {
    final spoken = _recognizedText.trim();
    if (spoken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Bạn chưa phát âm! Hãy nhấn biểu tượng micro để thu âm trước khi phân tích.'),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final result = _engine.analyzePronunciation(
      exerciseId: _currentExercise.id,
      targetSentence: _currentExercise.targetText,
      spokenSentence: spoken,
    );

    // Save to Database (chỉ tăng số câu nếu là câu mới trong ngày; cập nhật nếu điểm cao hơn)
    final saveResult = await DatabaseHelper.instance.insertOrUpdatePronunciationResult(result);
    final bool isNewUnique = saveResult['isNewUnique'] as bool? ?? false;
    final double? previousScore = saveResult['previousScore'] as double?;

    // Record session & update streak
    final durationSeconds = DateTime.now().difference(_sessionStartTime ?? DateTime.now()).inSeconds;
    final session = PracticeSession(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      dateString: DateTime.now().toIso8601String().substring(0, 10),
      timestamp: DateTime.now(),
      durationSeconds: durationSeconds < 30 ? 30 : durationSeconds,
      exercisesCompleted: isNewUnique ? 1 : 0,
      averageScore: result.overallScore,
    );
    await DatabaseHelper.instance.insertPracticeSession(session);
    await StreakService.instance.recordPracticeActivity(
      durationSeconds: durationSeconds,
      exercisesCount: isNewUnique ? 1 : 0,
      averageScore: result.overallScore,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PronunciationResultScreen(
          result: result,
          exercise: _currentExercise,
          previousBestScore: previousScore,
          onRetry: () {
            Navigator.pop(ctx);
            setState(() {
              _recognizedText = '';
              _sessionStartTime = DateTime.now();
            });
          },
          onNext: () {
            Navigator.pop(ctx);
            final all = ExerciseRepository.sampleExercises;
            final currentIndex = all.indexWhere((e) => e.id == _currentExercise.id);
            final nextIndex = (currentIndex + 1) % all.length;
            setState(() {
              _currentExercise = all[nextIndex];
              _recognizedText = '';
              _sessionStartTime = DateTime.now();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSpokenText = _recognizedText.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _currentExercise.category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _currentExercise.difficulty,
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exercise Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentExercise.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Target sentence
                  Text(
                    _currentExercise.targetText,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Phonetic IPA
                  Text(
                    '/${_currentExercise.phoneticIpa}/',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Vietnamese meaning
                  Text(
                    _currentExercise.meaningVi,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Listen options
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4F46E5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.volume_up, size: 18, color: Color(0xFF4F46E5)),
                        label: const Text('Nghe mẫu (1.0x)', style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13)),
                        onPressed: () => _tts.speak(_currentExercise.targetText, rate: 0.5),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.slow_motion_video, size: 18, color: Colors.black87),
                        label: const Text('Chậm (0.35x)', style: TextStyle(color: Colors.black87, fontSize: 13)),
                        onPressed: () => _tts.speak(_currentExercise.targetText, rate: 0.35),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Pronunciation tip alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _currentExercise.pronunciationTip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E40AF),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live recognized preview box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecording ? const Color(0xFFEF4444) : Colors.grey.shade300,
                  width: _isRecording ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isRecording ? 'Đang lắng nghe...' : 'Giọng của bạn:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isRecording ? const Color(0xFFEF4444) : Colors.grey.shade600,
                        ),
                      ),
                      if (_recognizedText.isNotEmpty)
                        InkWell(
                          onTap: () => setState(() => _recognizedText = ''),
                          child: const Text('Xóa', style: TextStyle(fontSize: 12, color: Colors.blue)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recognizedText.isNotEmpty
                        ? _recognizedText
                        : 'Chạm biểu tượng micro bên dưới và đọc to câu trên...',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: _recognizedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: _recognizedText.isNotEmpty ? const Color(0xFF1E293B) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Voice Preset Selector (Checklist 7 Multi-user / Multi-accent simulation)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedVoicePreset,
                  items: _accentSimulations.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['label'],
                      child: Text(
                        item['label']!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: _onPresetChanged,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Center Recording Button with Pulse Animation
            Center(
              child: ScaleTransition(
                scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isRecording
                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                            : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFF4F46E5))
                              .withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isRecording ? 'Nhấn để dừng thu âm' : 'Nhấn để bắt đầu đọc',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isRecording ? const Color(0xFFDC2626) : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Analyze Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSpokenText ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: Icon(
                Icons.analytics,
                color: hasSpokenText ? Colors.white : const Color(0xFF94A3B8),
              ),
              label: Text(
                'Phân tích phát âm AI',
                style: TextStyle(
                  color: hasSpokenText ? Colors.white : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: hasSpokenText ? _runAnalysis : null,
            ),
            if (!hasSpokenText) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Nhấn micro và phát âm để mở khóa phân tích',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
