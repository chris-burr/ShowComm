import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cue.dart';
import '../../theme/app_theme.dart';
import 'countdown_chip.dart';

class CueTile extends StatelessWidget {
  const CueTile({
    super.key,
    required this.cue,
    required this.currentFrames,
    required this.framerate,
    this.index,
    this.isNext = false,
    this.canEdit = false,
    this.onTap,
    this.onLongPress,
  });

  final Cue cue;
  final int currentFrames;
  final int framerate;
  final int? index;
  final bool isNext;
  final bool canEdit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cueFrames = cue.toFrames(framerate);
    final isPast = cueFrames < currentFrames;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isNext
              ? AppColors.surfaceHighlight
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNext
                ? AppColors.primary.withOpacity(0.55)
                : AppColors.border,
            width: isNext ? 1.5 : 1,
          ),
          boxShadow: isNext
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Cue number
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${cue.id}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isNext
                            ? AppColors.primaryLight
                            : isPast
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Label + timecode
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cue.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isNext
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isPast
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration: isPast
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          cue.timecode,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            color: isPast
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Countdown / past indicator
                  CountdownChip(
                    cueFrames: cueFrames,
                    currentFrames: currentFrames,
                    framerate: framerate,
                  ),
                  // Next cue arrow
                  if (isNext) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
