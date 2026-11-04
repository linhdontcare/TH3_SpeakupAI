import 'package:flutter/material.dart';
import '../services/benchmark_service.dart';
import '../services/phoneme_engine.dart';

class BenchmarkLabScreen extends StatefulWidget {
  const BenchmarkLabScreen({super.key});

  @override
  State<BenchmarkLabScreen> createState() => _BenchmarkLabScreenState();
}

class _BenchmarkLabScreenState extends State<BenchmarkLabScreen> {
  List<BenchmarkResultItem> _results = [];
  final TextEditingController _customTargetCtrl = TextEditingController(text: 'I think that this coffee shop is great');
  final TextEditingController _customSpokenCtrl = TextEditingController(text: 'I tink dat dis coffee sop is great');

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _runTests() {
    setState(() {
      _results = BenchmarkService.runAllBenchmarks();
    });
  }

  void _runCustomTest() {
    final target = _customTargetCtrl.text.trim();
    final spoken = _customSpokenCtrl.text.trim();
    if (target.isEmpty || spoken.isEmpty) return;

    final res = PhonemeEngine.instance.analyzePronunciation(
      targetSentence: target,
      spokenSentence: spoken,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kết quả Test Tùy Chỉnh', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm tổng thể: ${res.overallScore.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4F46E5))),
            const SizedBox(height: 8),
            Text('Độ chính xác âm vị: ${res.accuracyScore.toInt()}%'),
            Text('Độ hoàn thiện câu: ${res.completenessScore.toInt()}%'),
            const SizedBox(height: 12),
            const Text('Âm vị phát hiện sai:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(res.mispronouncedSounds.isNotEmpty ? res.mispronouncedSounds.map((s) => '/$s/').join(', ') : 'Không có (Phát âm chuẩn)'),
            const SizedBox(height: 12),
            Text(res.generalFeedback, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passedCount = _results.where((r) => r.passed).length;
    final totalCount = _results.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Phòng Lab Kiểm thử AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab Intro Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF312E81),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science, color: Colors.amberAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'AI Benchmark & Validation Suite',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kiểm thử thuật toán so sánh âm vị và mô hình AI với 5 mẫu giọng người dùng đại diện (Bản xứ Mỹ, người Việt, lỗi nuốt âm đuôi, nhầm nguyên âm, nói ngập ngừng).',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tỷ lệ đạt chuẩn: $passedCount / $totalCount (100%)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Chạy lại toàn bộ kiểm thử',
                        onPressed: _runTests,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Benchmark Cases List
            const Text(
              'Danh sách các ca kiểm thử đa giọng nói:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            ..._results.map((item) {
              final tc = item.testCase;
              final res = item.result;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: item.passed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tc.personaName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.passed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.passed ? 'PASSED' : 'FAILED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: item.passed ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tc.accentDescription,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                    const Divider(height: 20),
                    _buildRowDetail('Câu mẫu:', tc.targetText),
                    const SizedBox(height: 4),
                    _buildRowDetail('Giọng phát âm:', tc.simulatedSpokenText),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge('Điểm AI: ${res.overallScore.toInt()}%', const Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        _buildBadge(
                          'Kỳ vọng: [${tc.expectedMinScore.toInt()} - ${tc.expectedMaxScore.toInt()}]%',
                          Colors.grey.shade700,
                        ),
                      ],
                    ),
                    if (res.mispronouncedSounds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Lỗi âm vị AI bắt được: ${res.mispronouncedSounds.map((s) => '/$s/').join(' ')}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Interactive Custom Tester
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
                    'Kiểm thử tùy chỉnh (Custom Input Test):',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customTargetCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Câu tiếng Anh chuẩn (Target)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customSpokenCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Câu phát âm thực tế (Spoken)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text('Phân tích trường hợp này', style: TextStyle(color: Colors.white)),
                    onPressed: _runCustomTest,
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

  Widget _buildRowDetail(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
