import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../router/current_location.dart';
import 'secondary_button.dart';

/// Secondary action that returns to the contacts list, keeping the search.
class BackToContactsButton extends StatelessWidget {
  const BackToContactsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: 'Volver a contactos',
      onPressed: () => context.go(
        AppRoutes.contactsLocation(query: currentQueryOf(context)),
      ),
    );
  }
}
