import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorite_contacts_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/usecases/get_favorite_contacts.dart';

Contact _named(int id) => Contact(
  id: id,
  name: 'Contacto $id',
  role: 'QA Lead',
  department: 'Ingeniería',
  email: 'x$id@empresa.cl',
  phone: '+56 9 1111 2222',
  active: true,
);

class _FakeRepository implements FavoriteContactsRepository {
  _FakeRepository(this.contacts);
  final List<Contact> contacts;
  int calls = 0;

  @override
  Future<List<Contact>> getContacts(Set<int> ids) async {
    calls++;
    return contacts.where((c) => ids.contains(c.id)).toList();
  }
}

void main() {
  test('returns the contacts of the favorite ids', () async {
    final useCase = GetFavoriteContacts(
      _FakeRepository([_named(1), _named(2), _named(3)]),
    );

    final contacts = await useCase({1, 3});

    expect(contacts.map((c) => c.id), [1, 3]);
  });

  test(
    'no favorites means no contacts, without asking the repository',
    () async {
      final repository = _FakeRepository([_named(1)]);

      final contacts = await GetFavoriteContacts(repository)({});

      expect(contacts, isEmpty);
      expect(repository.calls, 0);
    },
  );

  test('a favorite that is not in the contacts is left out', () async {
    final useCase = GetFavoriteContacts(_FakeRepository([_named(1)]));

    expect((await useCase({1, 99})).map((c) => c.id), [1]);
  });
}
