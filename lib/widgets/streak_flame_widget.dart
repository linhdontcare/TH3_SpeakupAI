import 'package:flutter/material.dart';

class StreakFlameWidget extends StatelessWidget {
  final int streakDays;
  final bool isCompletedToday;
  final VoidCallback? onTap;

  const StreakFlameWidget({
    super.key,
    required this.streakDays,
    this.isCompletedToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExtinguished = streakDays <= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isExtinguished
                ? const [Color(0xFF64748B), Color(0xFF94A3B8)]
                : const [Color(0xFFFF3D00), Color(0xFFFF9100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isExtinguished
                  ? Colors.black.withOpacity(0.12)
                  : const Color(0xFFFF6D00).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: isExtinguished ? Colors.white70 : const Color(0xFFFFEE58),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$streakDays Ngày',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
