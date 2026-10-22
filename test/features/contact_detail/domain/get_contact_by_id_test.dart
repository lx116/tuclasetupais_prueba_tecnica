import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/usecases/contact_not_found_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/usecases/get_contact_by_id.dart';

const _contact = Contact(
  id: 3,
  name: 'Valentina Cid',
  role: 'QA Lead',
  department: 'Ingeniería',
  email: 'valentina.cid@empresa.cl',
  phone: '+56 9 3333 4444',
  active: false,
);

class _FakeRepository implements ContactDetailRepository {
  _FakeRepository(this.contact);
  final Contact? contact;

  @override
  Future<Contact?> getContactById(int id) async => contact;
}

void main() {
  test('returns the contact when it exists', () async {
    final useCase = GetContactById(_FakeRepository(_contact));
    expect(await useCase(3), _contact);
  });

  test('throws not found, carrying the id, when it does not exist', () {
    final useCase = GetContactById(_FakeRepository(null));
    expect(
      () => useCase(99),
      throwsA(isA<ContactNotFoundException>().having((e) => e.id, 'id', 99)),
    );
  });
}
