import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'contact_detail_cubit.dart';

/// Creates the [ContactDetailCubit] from DI and loads [contactId].
///
/// Keyed by [contactId]: going from one contact to another reuses this widget,
/// so without the key the first cubit would stay and the detail would remain
/// pinned to the first contact.
class ContactDetailProvider extends StatelessWidget {
  const ContactDetailProvider({
    super.key,
    required this.contactId,
    required this.child,
  });

  final int contactId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactDetailCubit>(
      key: ValueKey(contactId),
      create: (_) => sl<ContactDetailCubit>()..load(contactId),
      child: child,
    );
  }
}
