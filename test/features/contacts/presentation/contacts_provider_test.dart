import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_provider.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/cubit/contacts_state.dart';

class _EmptyRepository implements ContactRepository {
  @override
  Future<List<Contact>> getContacts() async => const [];
}

void main() {
  tearDown(() => sl.reset());

  testWidgets('provides a cubit from DI and starts loading contacts', (
    tester,
  ) async {
    sl.registerFactory<ContactsCubit>(
      () => ContactsCubit(GetContacts(_EmptyRepository())),
    );
    late ContactsState seen;

    await tester.pumpWidget(
      ContactsProvider(
        child: BlocBuilder<ContactsCubit, ContactsState>(
          builder: (context, state) {
            seen = state;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();

    expect(seen, const ContactsEmpty());
  });

  test('DI registers a new ContactsCubit per request', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initDependencies();

    expect(sl<ContactsCubit>(), isNot(same(sl<ContactsCubit>())));
  });
}
