import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Shown for unknown routes and for resources that do not exist.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.message = 'Page not found'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404', style: Theme.of(context).textTheme.displayMedium),
            Text(message),
            TextButton(
              onPressed: () => context.go(AppRoutes.contacts),
              child: const Text('Back to contacts'),
            ),
          ],
        ),
      ),
    );
  }
}
