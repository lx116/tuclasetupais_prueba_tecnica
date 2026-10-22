import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await startServices();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialLocation = AppRoutes.contacts});

  /// Only used when the platform does not provide a location (on web the
  /// browser URL wins).
  final String initialLocation;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Contactos',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
