import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/state_message.dart';

/// Detail column content while no contact is selected.
class DetailPlaceholder extends StatelessWidget {
  const DetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB9DCD8), width: 2),
        ),
        child: const SizedBox.expand(
          child: StateMessage(
            icon: Icons.person_outline,
            title: 'Selecciona un contacto',
            message: 'Su detalle aparecerá aquí sin salir de la lista.',
          ),
        ),
      ),
    );
  }
}
