import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/timecode/timecode.dart';
import '../../models/cue.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/timecode_display.dart';
import '../widgets/cue_tile.dart';
import 'cue_editor_screen.dart';
import 'user_management_screen.dart';

class CueListScreen extends ConsumerWidget {
  const CueListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final tc = ref.watch(timecodeProvider);
    final appState = ref.watch(appStateProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No session selected')),
      );
    }

    final currentUser = session.users.firstWhere(
      (u) => u.name == appState.userName,
      orElse: () => const UserModel(
          name: '', role: '', permission: Permission.view),
    );
    final canEdit = currentUser.isMaster ||
        currentUser.permission == Permission.directEdit ||
        currentUser.permission == Permission.propose;

    final sortedCues = List<Cue>.from(session.cues)
      ..sort((a, b) =>
          a.toFrames(session.framerate)
              .compareTo(b.toFrames(session.framerate)));

    final nextCueIndex = sortedCues.indexWhere(
        (c) => c.toFrames(session.framerate) > tc.frames);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _CueListAppBar(
        session: session,
        onUsers: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const UserManagementScreen()),
        ),
      ),
      body: Column(
        children: [
          // Connection status bar
          _ConnectionBar(session: session),
          // Timecode display
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TimecodeDisplay(
              frames: tc.frames,
              framerate: session.framerate,
              isRunning: tc.isRunning,
            ),
          ),
          // Next cue preview
          if (nextCueIndex >= 0)
            _NextCuePreview(
              cue: sortedCues[nextCueIndex],
              currentFrames: tc.frames,
              framerate: session.framerate,
            ),
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.queue_outlined,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'CUE LIST',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${sortedCues.length} cues',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ),
                const Spacer(),
                Text(
                  'v${session.version}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Cue list
          Expanded(
            child: sortedCues.isEmpty
                ? _EmptyCueList(canEdit: canEdit)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    itemCount: sortedCues.length,
                    itemBuilder: (context, i) {
                      final cue = sortedCues[i];
                      return CueTile(
                        cue: cue,
                        currentFrames: tc.frames,
                        framerate: session.framerate,
                        isNext: i == nextCueIndex,
                        canEdit: canEdit,
                        onTap: canEdit
                            ? () => _editCue(context, ref, session, cue)
                            : null,
                        onLongPress: canEdit
                            ? () => _deleteCue(context, ref, session, cue)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _addCue(context, ref, session),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Cue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
    );
  }

  void _addCue(
      BuildContext context, WidgetRef ref, SessionModel session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CueEditorScreen(
        session: session,
        onSave: (newCue) {
          final updated = session.copyWith(
            cues: [...session.cues, newCue],
            version: session.version + 1,
          );
          ref.read(currentSessionProvider.notifier).state = updated;
        },
      ),
    );
  }

  void _editCue(BuildContext context, WidgetRef ref, SessionModel session,
      Cue cue) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CueEditorScreen(
        session: session,
        existingCue: cue,
        onSave: (updated) {
          final newCues = session.cues
              .map((c) => c.id == cue.id ? updated : c)
              .toList();
          ref.read(currentSessionProvider.notifier).state =
              session.copyWith(cues: newCues, version: session.version + 1);
        },
      ),
    );
  }

  void _deleteCue(BuildContext context, WidgetRef ref, SessionModel session,
      Cue cue) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Cue?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '"${cue.label}" will be removed from the cue list.',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: Size.zero,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final newCues =
                  session.cues.where((c) => c.id != cue.id).toList();
              ref.read(currentSessionProvider.notifier).state =
                  session.copyWith(
                      cues: newCues, version: session.version + 1);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CueListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CueListAppBar({required this.session, required this.onUsers});
  final SessionModel session;
  final VoidCallback onUsers;

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final connected = session.users.where((u) => u.isConnected).length;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${session.framerate}fps · ${session.cues.length} cues',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onUsers,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  '$connected',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }
}

class _ConnectionBar extends StatelessWidget {
  const _ConnectionBar({required this.session});
  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
              boxShadow: [
                BoxShadow(
                    color: AppColors.success.withOpacity(0.5),
                    blurRadius: 5)
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Connected to ${session.hostAddress ?? 'local'}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            'ver. ${session.version}',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _NextCuePreview extends StatelessWidget {
  const _NextCuePreview({
    required this.cue,
    required this.currentFrames,
    required this.framerate,
  });
  final Cue cue;
  final int currentFrames;
  final int framerate;

  @override
  Widget build(BuildContext context) {
    final delta = cue.toFrames(framerate) - currentFrames;
    final countdown = Timecode.formatCountdown(delta, framerate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.keyboard_double_arrow_right_rounded,
                size: 16, color: AppColors.primaryLight),
            const SizedBox(width: 10),
            const Text(
              'NEXT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cue.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              countdown,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCueList extends StatelessWidget {
  const _EmptyCueList({required this.canEdit});
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_outlined,
              size: 52, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No cues yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          if (canEdit) ...[
            const SizedBox(height: 8),
            const Text(
              'Tap + Add Cue to get started',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
