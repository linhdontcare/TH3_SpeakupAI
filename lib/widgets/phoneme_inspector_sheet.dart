import 'package:flutter/material.dart';
import '../models/pronunciation_result.dart';
import '../services/tts_service.dart';

class PhonemeInspectorSheet extends StatelessWidget {
  final WordFeedback wordFeedback;

  const PhonemeInspectorSheet({
    super.key,
    required this.wordFeedback,
  });

  static void show(BuildContext context, WordFeedback word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PhonemeInspectorSheet(wordFeedback: word),
    );
  }

  Color _getStatusColor(WordAccuracyStatus status) {
    switch (status) {
      case WordAccuracyStatus.excellent:
        return const Color(0xFF10B981);
      case WordAccuracyStatus.acceptable:
        return const Color(0xFFF59E0B);
      case WordAccuracyStatus.poor:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(wordFeedback.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: Word + IPA + Listen button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordFeedback.word,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/${wordFeedback.targetIpa}/',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Word score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  '${wordFeedback.score.toInt()}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Audio Play button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                ),
                icon: const Icon(Icons.volume_up, color: Color(0xFF4F46E5)),
                onPressed: () {
                  TtsService.instance.speak(wordFeedback.word, rate: 0.35);
                },
                tooltip: 'Nghe phát âm chuẩn',
              ),
            ],
          ),
          const Divider(height: 32),

          // Recognition analysis comparison
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phiên âm chuẩn (Target):',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      '/${wordFeedback.targetIpa}/',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Âm AI ghi nhận (Spoken):',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Text(
                      wordFeedback.spokenIpa.isNotEmpty
                          ? '/${wordFeedback.spokenIpa}/'
                          : '(Không rõ / Thiếu)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: wordFeedback.spokenIpa == wordFeedback.targetIpa
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Phonemes breakdown chips
          const Text(
            'Phân tích từng âm vị (Phonemes):',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: wordFeedback.phonemes.map((ph) {
              final isGood = ph.isCorrect;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGood
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '/${ph.targetPhoneme}/',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isGood
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isGood ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: isGood
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Articulation Tip Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates, color: Color(0xFFD97706), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hướng dẫn khẩu hình & cách phát âm:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wordFeedback.practicalTip.isNotEmpty
                            ? wordFeedback.practicalTip
                            : 'Mở rộng cơ miệng, phát âm dứt khoát và chú ý phụ âm cuối.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

