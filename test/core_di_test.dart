import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/di/injection.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';

import 'features/contacts/support/contacts_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => sl.reset());

  test('the simulated back call takes 800ms', () {
    expect(contactsLatency, const Duration(milliseconds: 800));
  });

  test(
    'startup loads the bundled contacts and the use case serves them',
    () async {
      await initDependencies();
      await sl.unregister<DiceRoller>();
      sl.registerSingleton<DiceRoller>(FixedDice(2));
      await startServices();

      final contacts = await sl<GetContacts>()();

      expect(contacts, hasLength(18));
    },
  );
}
