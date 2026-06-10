import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../widgets/role_badge.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final appState = ref.watch(appStateProvider);

    if (session == null) return const SizedBox.shrink();

    final isMaster = session.users.any(
      (u) => u.name == appState.userName && u.isMaster,
    );

    final connected = session.users.where((u) => u.isConnected).toList();
    final offline = session.users.where((u) => !u.isConnected).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Join requests (placeholder for future WebSocket events)
          _JoinRequestsSection(isMaster: isMaster),
          if (connected.isNotEmpty) ...[
            _SectionHeader('ONLINE  ·  ${connected.length}'),
            ...connected.map((u) => _UserTile(
                  user: u,
                  isMaster: isMaster,
                  onChangePermission: isMaster && !u.isMaster
                      ? () => _changePermission(context, ref, u)
                      : null,
                )),
          ],
          if (offline.isNotEmpty) ...[
            _SectionHeader('OFFLINE  ·  ${offline.length}'),
            ...offline.map((u) => _UserTile(user: u, isMaster: isMaster)),
          ],
        ],
      ),
    );
  }

  void _changePermission(
      BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _PermissionSheet(
        user: user,
        onSelect: (perm) {
          Navigator.pop(context);
          final session = ref.read(currentSessionProvider);
          if (session == null) return;
          final updated = session.copyWith(
            users: session.users
                .map((u) =>
                    u.name == user.name ? u.copyWith(permission: perm) : u)
                .toList(),
          );
          ref.read(currentSessionProvider.notifier).state = updated;
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isMaster,
    this.onChangePermission,
  });

  final UserModel user;
  final bool isMaster;
  final VoidCallback? onChangePermission;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _Avatar(user: user),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (user.isMaster) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user.role,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                RoleBadge(
                  permission: user.permission,
                  isMaster: user.isMaster,
                  small: true,
                ),
              ],
            ),
          ),
          trailing: onChangePermission != null
              ? IconButton(
                  icon: const Icon(Icons.tune_rounded,
                      size: 18, color: AppColors.textSecondary),
                  onPressed: onChangePermission,
                )
              : user.isConnected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 5,
                          )
                        ],
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: user.isMaster
              ? [AppColors.primary, AppColors.primaryDark]
              : [AppColors.surfaceHighlight, AppColors.surfaceElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: user.isMaster
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: user.isMaster
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _JoinRequestsSection extends StatelessWidget {
  const _JoinRequestsSection({required this.isMaster});
  final bool isMaster;

  @override
  Widget build(BuildContext context) {
    if (!isMaster) return const SizedBox.shrink();
    // Placeholder — real join requests arrive via WebSocket
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_outlined,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Join requests will appear here when devices connect',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textMuted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet({required this.user, required this.onSelect});
  final UserModel user;
  final void Function(Permission) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Set permission for ${user.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...Permission.values.map((p) => _PermissionOption(
                permission: p,
                isCurrent: user.permission == p,
                onTap: () => onSelect(p),
              )),
        ],
      ),
    );
  }
}

class _PermissionOption extends StatelessWidget {
  const _PermissionOption({
    required this.permission,
    required this.isCurrent,
    required this.onTap,
  });
  final Permission permission;
  final bool isCurrent;
  final VoidCallback onTap;

  static const _descriptions = {
    Permission.directEdit: 'Changes apply immediately to all devices',
    Permission.propose: 'Changes sent to Master for approval before publishing',
    Permission.view: 'Read-only — can view cues and countdowns',
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Icon(
                isCurrent ? Icons.check_rounded : Icons.circle_outlined,
                size: 16,
                color: isCurrent
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? AppColors.primaryLight
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _descriptions[permission] ?? '',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
