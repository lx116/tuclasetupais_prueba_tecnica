import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'contacts_cubit.dart';

/// Creates the [ContactsCubit] from DI and starts loading the contacts.
class ContactsProvider extends StatelessWidget {
  const ContactsProvider({
    super.key,
    required this.child,
    this.initialSearch = '',
  });

  final Widget child;

  /// The search text from the URL, applied as soon as the data arrives.
  final String initialSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactsCubit>(
      create: (_) => sl<ContactsCubit>()
        ..search(initialSearch)
        ..load(),
      child: child,
    );
  }
}
