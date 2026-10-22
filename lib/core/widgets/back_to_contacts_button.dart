import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Secondary action that returns to the contacts list.
class BackToContactsButton extends StatelessWidget {
  const BackToContactsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go(AppRoutes.contacts),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        foregroundColor: AppColors.darkTeal,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.darkTeal, width: 2),
        textStyle: appText(size: 15, weight: 700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Volver a contactos'),
    );
  }
}
