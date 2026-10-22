import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/repositories/contact_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/domain/usecases/get_contacts.dart';

const _contact = Contact(
  id: 1,
  name: 'Camila Reyes',
  role: 'Product Designer',
  department: 'Diseño',
  email: 'camila.reyes@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

class _FakeRepository implements ContactRepository {
  _FakeRepository(this.contacts);
  final List<Contact> contacts;

  @override
  Future<List<Contact>> getContacts() async => contacts;
}

void main() {
  test('returns the contacts the repository provides', () async {
    final useCase = GetContacts(_FakeRepository([_contact]));
    expect(await useCase(), [_contact]);
  });

  test('returns an empty list when the repository has none', () async {
    final useCase = GetContacts(_FakeRepository([]));
    expect(await useCase(), isEmpty);
  });
}
