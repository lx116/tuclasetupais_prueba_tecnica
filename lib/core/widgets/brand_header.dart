import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Dark teal top bar with the app mark and name.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.compact = false, this.trailing});

  final bool compact;

  /// Shown at the right end, e.g. the navigation.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mark = compact ? 32.0 : 36.0;
    return Material(
      color: AppColors.darkTeal,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 24,
            vertical: compact ? 12 : 14,
          ),
          child: Row(
            children: [
              Container(
                width: mark,
                height: mark,
                decoration: BoxDecoration(
                  color: AppColors.strongCyan,
                  borderRadius: BorderRadius.circular(compact ? 9 : 10),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: compact ? 18 : 20,
                  color: AppColors.darkTeal,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Text(
                'Contactos',
                style: appText(
                  size: compact ? 20 : 19,
                  weight: 800,
                  color: AppColors.mintCream,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
