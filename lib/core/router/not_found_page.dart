import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/back_to_contacts_button.dart';
import '../widgets/state_message.dart';

/// Shown for unknown routes and for resources that do not exist.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.message = 'Página no encontrada'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mintCream,
      child: StateMessage(
        icon: Icons.search_off,
        title: '404',
        message: message,
        action: const BackToContactsButton(),
      ),
    );
  }
}
