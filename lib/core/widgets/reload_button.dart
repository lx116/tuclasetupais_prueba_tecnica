import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Primary action of the error and empty states: loads the data again.
class ReloadButton extends StatelessWidget {
  const ReloadButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: AppColors.darkTeal,
        foregroundColor: AppColors.mintCream,
        textStyle: appText(size: 15, weight: 700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
