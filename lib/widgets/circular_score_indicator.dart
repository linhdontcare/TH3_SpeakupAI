import 'package:flutter/material.dart';

class CircularScoreIndicator extends StatelessWidget {
  final double score; // 0 - 100
  final double size;
  final String label;

  const CircularScoreIndicator({
    super.key,
    required this.score,
    this.size = 130,
    this.label = 'Tổng điểm AI',
  });

  Color _getScoreColor(double s) {
    if (s >= 80) return const Color(0xFF10B981); // Emerald Green
    if (s >= 60) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  String _getScoreRating(double s) {
    if (s >= 85) return 'Chuẩn bản xứ';
    if (s >= 70) return 'Tốt & Rõ ràng';
    if (s >= 50) return 'Cần luyện tập';
    return 'Cần sửa lại';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    final percentage = (score / 100.0).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 10,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: size * 0.11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            _getScoreRating(score),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

