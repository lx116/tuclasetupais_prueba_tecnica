import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'contact_detail_cubit.dart';

/// Creates the [ContactDetailCubit] from DI and loads [contactId].
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
      create: (_) => sl<ContactDetailCubit>()..load(contactId),
      child: child,
    );
  }
}
