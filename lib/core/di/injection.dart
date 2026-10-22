import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../features/contact_detail/data/datasources/contact_detail_local_datasource.dart';
import '../../features/contact_detail/data/repositories/contact_detail_repository_impl.dart';
import '../../features/contact_detail/domain/repositories/contact_detail_repository.dart';
import '../../features/contact_detail/domain/usecases/get_contact_by_id.dart';
import '../../features/contact_detail/presentation/cubit/contact_detail_cubit.dart';
import '../../features/contacts/data/datasources/contacts_local_datasource.dart';
import '../../features/contacts/data/datasources/dice_roller.dart';
import '../contacts/data/contacts_availability.dart';
import '../contacts/data/service_get_contacts.dart';
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
  // shared
  sl.registerLazySingleton<ContactsAvailability>(ContactsAvailability.new);

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
      availability: sl<ContactsAvailability>(),
    ),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl<ContactsLocalDataSource>()),
  );
  sl.registerLazySingleton<GetContacts>(
    () => GetContacts(sl<ContactRepository>()),
  );
  sl.registerFactory<ContactsCubit>(() => ContactsCubit(sl<GetContacts>()));

  // contact detail
  sl.registerLazySingleton<ContactDetailLocalDataSource>(
    () => ContactDetailLocalDataSource(
      sl<ServiceGetContacts>(),
      sl<ContactsAvailability>(),
    ),
  );
  sl.registerLazySingleton<ContactDetailRepository>(
    () => ContactDetailRepositoryImpl(sl<ContactDetailLocalDataSource>()),
  );
  sl.registerLazySingleton<GetContactById>(
    () => GetContactById(sl<ContactDetailRepository>()),
  );
  sl.registerFactory<ContactDetailCubit>(
    () => ContactDetailCubit(sl<GetContactById>()),
  );
}

/// Starts the services that must have their data ready before `runApp`.
/// Called from `main()` right after [initDependencies].
Future<void> startServices() async {
  await sl<ServiceGetContacts>().load();
}
