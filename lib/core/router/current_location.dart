import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// The location the router is at right now, wherever the widget lives (a
/// `GoRouterState` is only available inside route builders).
Uri currentUriOf(BuildContext context) =>
    GoRouter.of(context).routeInformationProvider.value.uri;

/// The `?search=` text of the current location, empty when there is none.
String currentSearchOf(BuildContext context) =>
    currentUriOf(context).queryParameters[AppRoutes.searchParam] ?? '';
