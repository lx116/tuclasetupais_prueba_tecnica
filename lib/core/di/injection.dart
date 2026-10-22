import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../features/contacts/data/datasources/contacts_local_datasource.dart';
import '../../features/contacts/data/datasources/dice_roller.dart';
import '../../features/contacts/data/datasources/service_get_contacts.dart';
import '../../features/contacts/data/repositories/contact_repository_impl.dart';
import '../../features/contacts/domain/repositories/contact_repository.dart';
import '../../features/contacts/domain/usecases/get_contacts.dart';
import '../../features/contacts/presentation/cubit/contacts_cubit.dart';

final sl = GetIt.instance;

/// Simulated back-call latency for the contacts list.
const Duration contactsLatency = Duration(milliseconds: 800);

/// Single entry point for dependency registration. Called from `main()`.
///
/// Registration order per feature: datasources -> repositories -> use cases
/// -> cubits (as factories).
Future<void> initDependencies() async {
  // contacts
  sl.registerLazySingleton<ServiceGetContacts>(
    () => ServiceGetContacts(bundle: rootBundle),
  );
  sl.registerLazySingleton<DiceRoller>(DiceRoller.new);
  sl.registerLazySingleton<ContactsLocalDataSource>(
    () => ContactsLocalDataSource(
      sl<ServiceGetContacts>(),
      dice: sl<DiceRoller>(),
      latency: contactsLatency,
    ),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl<ContactsLocalDataSource>()),
  );
  sl.registerLazySingleton<GetContacts>(
    () => GetContacts(sl<ContactRepository>()),
  );
  sl.registerFactory<ContactsCubit>(() => ContactsCubit(sl<GetContacts>()));
}

/// Starts the services that must have their data ready before `runApp`.
/// Called from `main()` right after [initDependencies].
Future<void> startServices() async {
  await sl<ServiceGetContacts>().load();
}
