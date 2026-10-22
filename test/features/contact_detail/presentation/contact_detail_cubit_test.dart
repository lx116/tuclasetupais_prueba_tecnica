import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/repositories/contact_detail_unavailable_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/domain/usecases/get_contact_by_id.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/cubit/contact_detail_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contact_detail/presentation/cubit/contact_detail_state.dart';

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
  _FakeRepository(this.result);
  final Object? result;

  @override
  Future<Contact?> getContactById(int id) async {
    final value = result;
    if (value is Contact?) return value;
    throw value;
  }
}

ContactDetailCubit _cubit(Object? result) =>
    ContactDetailCubit(GetContactById(_FakeRepository(result)));

void main() {
  test('starts in the loading state', () {
    expect(_cubit(_contact).state, const ContactDetailLoading());
  });

  test('emits data when the contact exists', () async {
    final cubit = _cubit(_contact);
    final states = expectLater(
      cubit.stream,
      emitsInOrder([const ContactDetailData(_contact), emitsDone]),
    );

    await cubit.load(3);
    await cubit.close();
    await states;
  });

  test('emits not found when the id does not exist', () async {
    final cubit = _cubit(null);

    await cubit.load(99);

    expect(cubit.state, const ContactDetailNotFound());
  });

  test('a failed list load is an error, not a not found', () async {
    final cubit = _cubit(const ContactDetailUnavailableException());

    await cubit.load(1);

    expect(cubit.state, isA<ContactDetailError>());
    expect(
      (cubit.state as ContactDetailError).message,
      contains('list failed to load'),
    );
  });

  test('other failures are reported as an error with their cause', () async {
    final cubit = _cubit(const FormatException('bad data'));

    await cubit.load(1);

    expect((cubit.state as ContactDetailError).message, contains('bad data'));
  });

  test('does not emit after the cubit is closed', () async {
    final cubit = _cubit(_contact);
    final pending = cubit.load(3);
    await cubit.close();

    await pending;

    expect(cubit.state, const ContactDetailLoading());
  });

  test('states compare by value', () {
    expect(
      const ContactDetailData(_contact),
      const ContactDetailData(_contact),
    );
    expect(const ContactDetailError('x'), const ContactDetailError('x'));
    expect(const ContactDetailNotFound(), const ContactDetailNotFound());
  });
}
