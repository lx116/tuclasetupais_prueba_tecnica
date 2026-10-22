import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import 'favorite_contacts_cubit.dart';

/// Creates the [FavoriteContactsCubit] from DI.
class FavoriteContactsProvider extends StatelessWidget {
  const FavoriteContactsProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoriteContactsCubit>(
      create: (_) => sl<FavoriteContactsCubit>(),
      child: child,
    );
  }
}
