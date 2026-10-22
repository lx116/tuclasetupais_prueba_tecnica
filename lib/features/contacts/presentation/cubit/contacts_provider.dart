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
    this.initialDepartment = '',
  });

  final Widget child;

  /// The search text from the URL, applied as soon as the data arrives.
  final String initialSearch;

  /// The department filter from the URL, applied like [initialSearch].
  final String initialDepartment;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactsCubit>(
      create: (_) => sl<ContactsCubit>()
        ..search(initialSearch)
        ..filterByDepartment(initialDepartment)
        ..load(),
      child: child,
    );
  }
}
