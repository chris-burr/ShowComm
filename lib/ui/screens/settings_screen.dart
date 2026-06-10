import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(appStateProvider);
    _nameCtrl = TextEditingController(text: s.userName ?? '');
    _roleCtrl = TextEditingController(text: s.userRole ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await ref
        .read(appStateProvider.notifier)
        .saveProfile(_nameCtrl.text.trim(), _roleCtrl.text.trim());
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        actions: [
          if (_editing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save',
                  style: TextStyle(color: AppColors.primaryLight)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => setState(() => _editing = true),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader('YOUR PROFILE'),
          _SettingsCard(
            children: [
              _editing
                  ? _EditField(label: 'Name', controller: _nameCtrl)
                  : _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: appState.userName ?? '—',
                    ),
              const _Divider(),
              _editing
                  ? _EditField(label: 'Role', controller: _roleCtrl)
                  : _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Role',
                      value: appState.userRole?.isNotEmpty == true
                          ? appState.userRole!
                          : '—',
                    ),
            ],
          ),
          _SectionHeader('NETWORK'),
          _SettingsCard(
            children: [
              _InfoRow(
                icon: Icons.wifi_outlined,
                label: 'Protocol',
                value: 'mDNS + WebSocket',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.podcasts_outlined,
                label: 'Timecode port',
                value: 'UDP 5004',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.lan_outlined,
                label: 'Session port',
                value: 'TCP 8080',
              ),
            ],
          ),
          _SectionHeader('TIMECODE'),
          _SettingsCard(
            children: [
              _InfoRow(
                icon: Icons.speed_outlined,
                label: 'Source',
                value: 'ETC Response SMPTE Gateway',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.audiotrack_outlined,
                label: 'Format',
                value: 'MIDI Timecode (MTC)',
              ),
            ],
          ),
          _SectionHeader('ABOUT'),
          _SettingsCard(
            children: [
              _InfoRow(
                icon: Icons.info_outline_rounded,
                label: 'Version',
                value: '1.0.0 (build 1)',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.code_rounded,
                label: 'Framework',
                value: 'Flutter',
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.cloud_off_outlined,
                label: 'Architecture',
                value: 'Local network, no cloud',
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 45),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }
}
