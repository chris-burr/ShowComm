import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../core/timecode/timecode.dart';

class CountdownChip extends StatelessWidget {
  const CountdownChip({
    super.key,
    required this.cueFrames,
    required this.currentFrames,
    required this.framerate,
  });

  final int cueFrames;
  final int currentFrames;
  final int framerate;

  @override
  Widget build(BuildContext context) {
    final delta = cueFrames - currentFrames;
    final isPast = delta < 0;

    if (isPast) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: AppColors.success),
      );
    }

    final totalSec = delta ~/ (framerate > 0 ? framerate : 25);
    final color = _color(totalSec);
    final text = Timecode.formatCountdown(delta, framerate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceMono(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _color(int seconds) {
    if (seconds < 30) return AppColors.error;
    if (seconds < 300) return AppColors.warning;
    return AppColors.textMuted;
  }
}
