import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'contacts_query.dart';

/// The location the router is at right now, wherever the widget lives (a
/// `GoRouterState` is only available inside route builders).
Uri currentUriOf(BuildContext context) =>
    GoRouter.of(context).routeInformationProvider.value.uri;

/// The search and filter of the current location.
ContactsQuery currentQueryOf(BuildContext context) =>
    ContactsQuery.fromUri(currentUriOf(context));
