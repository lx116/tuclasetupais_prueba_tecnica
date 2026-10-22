import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/data/contacts_availability.dart';

void main() {
  test('is available until a list call fails', () {
    expect(ContactsAvailability().isAvailable, isTrue);
  });

  test('a failure makes it unavailable and a success restores it', () {
    final availability = ContactsAvailability();

    availability.markFailed();
    expect(availability.isAvailable, isFalse);

    availability.markAvailable();
    expect(availability.isAvailable, isTrue);
  });
}
