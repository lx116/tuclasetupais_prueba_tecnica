import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/usecases/get_favorite_ids.dart';
import '../domain/usecases/save_favorite_ids.dart';
import '../domain/usecases/toggle_favorite.dart';
import 'favorites_state.dart';

typedef FavoritesLog = void Function(String message, {Object? error});

void _developerLog(String message, {Object? error}) =>
    developer.log(message, name: 'FavoritesCubit', level: 1000, error: error);

/// The favorites of the whole app: shared by the list, the detail, the header
/// and the favorites page, and kept for as long as the app runs.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(
    this._getFavoriteIds,
    this._toggleFavorite,
    this._saveFavoriteIds, {
    this.log = _developerLog,
  }) : super(const FavoritesState());

  final GetFavoriteIds _getFavoriteIds;
  final ToggleFavorite _toggleFavorite;
  final SaveFavoriteIds _saveFavoriteIds;
  final FavoritesLog log;

  // Saves run one after another so the last toggle is the last one stored.
  Future<void> _saving = Future.value();

  /// Reads the stored favorites. A storage failure must not break the app: it
  /// starts with no favorites and leaves a log.
  Future<void> load() async {
    Set<int> ids;
    try {
      ids = await _getFavoriteIds();
    } catch (error) {
      log('Could not read the favorites; starting with none', error: error);
      ids = const {};
    }
    if (!isClosed) {
      emit(FavoritesState(ids: Set.unmodifiable(ids), loaded: true));
    }
  }

  /// Adds or removes [contactId]. The state changes right away and the change
  /// is saved afterwards; if saving fails the previous favorites come back.
  Future<void> toggle(int contactId) {
    final previous = state.ids;
    final next = Set<int>.unmodifiable(_toggleFavorite(previous, contactId));
    emit(FavoritesState(ids: next, loaded: true));

    return _saving = _saving.then((_) async {
      try {
        await _saveFavoriteIds(next);
      } catch (error) {
        log('Could not save the favorites; undoing the change', error: error);
        if (!isClosed && state.ids == next) {
          emit(FavoritesState(ids: previous, loaded: true));
        }
      }
    });
  }
}
