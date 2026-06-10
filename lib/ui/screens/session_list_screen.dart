import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/session_card.dart';
import 'cue_list_screen.dart';
import 'settings_screen.dart';

class SessionListScreen extends ConsumerWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(discoveredSessionsProvider);
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.textPrimary],
              ).createShader(bounds),
              child: const Text(
                'ShowComm',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // User identity banner
          _UserBanner(name: appState.userName ?? '', role: appState.userRole ?? ''),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                // mDNS refresh will go here
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _HostNewSessionCard(
                        onTap: () => _hostNewSession(context, ref),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      icon: Icons.wifi_rounded,
                      label: 'NEARBY SESSIONS',
                      trailing: sessions.isEmpty
                          ? null
                          : '${sessions.length} found',
                    ),
                  ),
                  if (sessions.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptySessionsState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverList.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) => SessionCard(
                          session: sessions[i],
                          onJoin: () => _joinSession(context, ref, sessions[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _joinSession(BuildContext ctx, WidgetRef ref, SessionModel session) {
    ref.read(currentSessionProvider.notifier).state = session;
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => const CueListScreen()),
    );
  }

  void _hostNewSession(BuildContext ctx, WidgetRef ref) {
    _showHostDialog(ctx, ref);
  }

  void _showHostDialog(BuildContext ctx, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog<void>(
      context: ctx,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Session',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Give your session a name so other devices can find it.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'e.g. Show A — Tuesday Night'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size.zero),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final appState = ref.read(appStateProvider);
              final newSession = SessionModel(
                id: 'host-local',
                name: nameCtrl.text.trim(),
                framerate: 25,
                version: 1,
                masterDeviceId: 'this-device',
                users: [
                  UserModel(
                    name: appState.userName ?? 'Host',
                    role: appState.userRole ?? '',
                    permission: Permission.directEdit,
                    isMaster: true,
                    isConnected: true,
                  ),
                ],
                cues: const [],
                created: DateTime.now(),
              );
              ref.read(currentSessionProvider.notifier).state = newSession;
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => const CueListScreen()),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _UserBanner extends StatelessWidget {
  const _UserBanner({required this.name, required this.role});
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              if (role.isNotEmpty)
                Text(role,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Text(
              'VIEWER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostNewSessionCard extends StatelessWidget {
  const _HostNewSessionCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark.withOpacity(0.6),
              AppColors.surfaceHighlight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              child: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primaryLight, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Host New Session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Broadcast a session for others to join',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                trailing!,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySessionsState extends StatelessWidget {
  const _EmptySessionsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_find_rounded,
              size: 56, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No sessions found',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull to refresh · make sure you\'re on the same WiFi',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
