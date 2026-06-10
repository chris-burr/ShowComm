import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../core/timecode/timecode.dart';

enum TimecodeDisplaySize { large, compact }

class TimecodeDisplay extends StatelessWidget {
  const TimecodeDisplay({
    super.key,
    required this.frames,
    required this.framerate,
    required this.isRunning,
    this.size = TimecodeDisplaySize.large,
  });

  final int frames;
  final int framerate;
  final bool isRunning;
  final TimecodeDisplaySize size;

  @override
  Widget build(BuildContext context) {
    final tc = Timecode.framesToString(frames, framerate);
    final isLarge = size == TimecodeDisplaySize.large;
    final fontSize = isLarge ? 50.0 : 26.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 24 : 16,
        vertical: isLarge ? 20 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 12),
        border: Border.all(
          color: isRunning
              ? AppColors.primary.withOpacity(0.55)
              : AppColors.border,
          width: isRunning ? 1.5 : 1,
        ),
        boxShadow: isRunning
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Framerate label
          if (isLarge)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${framerate}fps  SMPTE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          // Timecode digits
          Text(
            tc,
            style: GoogleFonts.spaceMono(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color:
                  isRunning ? AppColors.primaryLight : AppColors.textSecondary,
              letterSpacing: isLarge ? 3 : 1,
            ),
          ),
          const SizedBox(height: 8),
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? AppColors.success : AppColors.textMuted,
                  boxShadow: isRunning
                      ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.6),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                isRunning ? 'RUNNING' : 'STOPPED',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color:
                      isRunning ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
