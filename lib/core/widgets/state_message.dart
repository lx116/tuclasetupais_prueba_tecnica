import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Centered message used for the error, empty and not-found states.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError ? AppColors.errorTint : AppColors.tint,
              ),
              child: Icon(
                icon,
                size: 34,
                color: isError ? AppColors.error : AppColors.darkTeal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: appText(size: 20, weight: 800, color: AppColors.darkTeal),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: appText(size: 15, color: AppColors.muted),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
