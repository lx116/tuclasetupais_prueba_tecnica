import 'dart:developer' as developer;

import '../../../../core/contacts/data/models/contact_model.dart';
import 'contacts_calls/call_empty.dart';
import 'contacts_calls/call_error.dart';
import 'contacts_calls/call_ok.dart';
import 'contacts_calls/contacts_call.dart';
import 'dice_roller.dart';
import '../../../../core/contacts/data/service_get_contacts.dart';

/// Serves the contacts that [ServiceGetContacts] loaded into memory, behind a
/// simulated back call: after [latency], a die roll picks the outcome.
///
/// 1, 3, 5 -> [CallError] (broken connection)
/// 2, 4    -> [CallOk] (contacts)
/// 6       -> [CallEmpty] (no contacts)
class ContactsLocalDataSource {
  ContactsLocalDataSource(
    this._service, {
    required this.dice,
    required this.latency,
  });

  final ServiceGetContacts _service;
  final DiceRoller dice;
  final Duration latency;

  Future<List<ContactModel>> getContacts() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    final roll = dice.roll();
    final call = _callFor(roll);
    developer.log(
      'Simulated contacts call: rolled $roll -> ${call.runtimeType}',
      name: 'ContactsLocalDataSource',
    );
    return call.execute();
  }

  ContactsCall _callFor(int roll) => switch (roll) {
    1 || 3 || 5 => CallError(),
    2 || 4 => CallOk(_service),
    6 => CallEmpty(),
    _ => throw RangeError.range(roll, 1, 6, 'roll'),
  };
}
