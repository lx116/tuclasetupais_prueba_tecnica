import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/favorites_unavailable_exception.dart';
import '../../domain/usecases/get_favorite_contacts.dart';
import 'favorite_contacts_state.dart';

const String _unavailableMessage =
    'La lista de contactos no se cargó. Vuelve a la lista e inténtalo de nuevo.';

class FavoriteContactsCubit extends Cubit<FavoriteContactsState> {
  FavoriteContactsCubit(this._getFavoriteContacts)
    : super(const FavoriteContactsLoading());

  final GetFavoriteContacts _getFavoriteContacts;

  /// Shows the contacts of [ids]. Called again whenever the favorites change;
  /// the previous contacts stay on screen until the new ones are ready.
  Future<void> load(Set<int> ids) async {
    final FavoriteContactsState next;
    try {
      final contacts = await _getFavoriteContacts(ids);
      next = contacts.isEmpty
          ? const FavoriteContactsEmpty()
          : FavoriteContactsData(contacts);
    } catch (error) {
      if (isClosed) return;
      emit(FavoriteContactsError(_describe(error)));
      return;
    }

    if (!isClosed) emit(next);
  }

  String _describe(Object error) => switch (error) {
    FavoritesUnavailableException() => _unavailableMessage,
    _ => '$error',
  };
}
