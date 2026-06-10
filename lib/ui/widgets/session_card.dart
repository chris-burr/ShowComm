import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../theme/app_theme.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onJoin,
  });

  final SessionModel session;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final connectedCount =
        session.users.where((u) => u.isConnected).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onJoin,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session name + online indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 6,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        session.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Meta row
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.movie_filter_outlined,
                      label: '${session.framerate}fps',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.queue_music_outlined,
                      label: '${session.cues.length} cues',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.people_outline,
                      label: '$connectedCount online',
                    ),
                    const Spacer(),
                    // Host address
                    if (session.hostAddress != null)
                      Text(
                        session.hostAddress!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                // Master name
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      _masterName(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Join button
                    _JoinButton(onTap: onJoin),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _masterName() {
    final master = session.users.where((u) => u.isMaster).firstOrNull;
    if (master == null) return 'Unknown host';
    return '${master.name} · ${master.role}';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Join',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
