import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  static const _suggestedRoles = [
    'Stage Manager',
    'Deputy Stage Manager',
    'Lighting Op',
    'Sound Op',
    'Director',
    'Production Manager',
    'Follow Spot Op',
    'Fly Op',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await ref
        .read(appStateProvider.notifier)
        .saveProfile(_nameCtrl.text.trim(), _roleCtrl.text.trim());
    // Navigation is driven automatically by appStateProvider in app.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.2, -0.6),
            radius: 0.9,
            colors: [Color(0xFF1A0A2E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _Logo(),
                  const SizedBox(height: 56),
                  _SectionLabel('YOUR NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Sarah Chen',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('YOUR ROLE'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Stage Manager',
                      prefixIcon: Icon(Icons.badge_outlined,
                          color: AppColors.textSecondary),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  // Quick-pick role chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedRoles
                        .map((r) => _RoleChip(
                              label: r,
                              onTap: () =>
                                  setState(() => _roleCtrl.text = r),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 48),
                  _GetStartedButton(saving: _saving, onTap: _submit),
                  const SizedBox(height: 24),
                  const Text(
                    'No account needed. Everything stays on your local network.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon mark
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.queue_music_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.textPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'ShowComm',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Live Production Cue Manager',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.saving, required this.onTap});
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: saving
                ? [AppColors.primaryDark, AppColors.primaryDark]
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: saving
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
