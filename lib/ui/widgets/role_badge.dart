import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({
    super.key,
    required this.permission,
    this.isMaster = false,
    this.small = false,
  });

  final Permission permission;
  final bool isMaster;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _style();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _style() {
    if (isMaster) return ('MASTER', AppColors.primary);
    return switch (permission) {
      Permission.directEdit => ('EDITOR', AppColors.primaryLight),
      Permission.propose => ('PROPOSE', AppColors.warning),
      Permission.view => ('VIEWER', AppColors.textSecondary),
    };
  }
}
