import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/contacts/domain/entities/contact.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorite_contacts_repository.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/repositories/favorites_unavailable_exception.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/domain/usecases/get_favorite_contacts.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/cubit/favorite_contacts_cubit.dart';
import 'package:tuclasetupais_prueba_tecnica/features/favorites/presentation/cubit/favorite_contacts_state.dart';

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
  _FakeRepository({this.error});
  final Object? error;

  @override
  Future<List<Contact>> getContacts(Set<int> ids) async {
    if (error != null) throw error!;
    return [for (final id in ids) _named(id)];
  }
}

FavoriteContactsCubit _cubit({Object? error}) =>
    FavoriteContactsCubit(GetFavoriteContacts(_FakeRepository(error: error)));

void main() {
  test('starts loading', () {
    expect(_cubit().state, const FavoriteContactsLoading());
  });

  test('load emits the contacts of the ids', () async {
    final cubit = _cubit();

    await cubit.load({1, 2});

    expect(cubit.state, FavoriteContactsData([_named(1), _named(2)]));
  });

  test('no ids is the empty state', () async {
    final cubit = _cubit();

    await cubit.load({});

    expect(cubit.state, const FavoriteContactsEmpty());
  });

  test('removing the last favorite goes from data to empty', () async {
    final cubit = _cubit();
    await cubit.load({1});

    await cubit.load({});

    expect(cubit.state, const FavoriteContactsEmpty());
  });

  test('a failed list load is an error, not an empty state', () async {
    final cubit = _cubit(error: const FavoritesUnavailableException());

    await cubit.load({1});

    expect(cubit.state, isA<FavoriteContactsError>());
    expect(
      (cubit.state as FavoriteContactsError).message,
      contains('no se cargó'),
    );
  });

  test('other failures are an error with their cause', () async {
    final cubit = _cubit(error: const FormatException('bad data'));

    await cubit.load({1});

    expect(
      (cubit.state as FavoriteContactsError).message,
      contains('bad data'),
    );
  });

  test(
    'reloading keeps the contacts on screen instead of flashing loading',
    () async {
      final cubit = _cubit();
      await cubit.load({1});
      final states = <FavoriteContactsState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.load({1, 2});
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, [
        FavoriteContactsData([_named(1), _named(2)]),
      ]);
    },
  );

  test('does not emit after the cubit is closed', () async {
    final cubit = _cubit();
    final pending = cubit.load({1});
    await cubit.close();

    await pending;

    expect(cubit.state, const FavoriteContactsLoading());
  });
}
