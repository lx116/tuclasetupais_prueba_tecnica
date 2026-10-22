import 'package:shared_preferences/shared_preferences.dart';

const String favoriteIdsKey = 'favorite_contact_ids';

/// Keeps the favorite ids on the device. [preferences] is only called when a
/// read or write happens, so creating the datasource never touches storage.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._preferences);

  final Future<SharedPreferences> Function() _preferences;

  /// Stored values that are not ids are ignored.
  Future<Set<int>> read() async {
    final stored = (await _preferences()).getStringList(favoriteIdsKey);
    return {
      for (final value in stored ?? const <String>[]) ?int.tryParse(value),
    };
  }

  Future<void> write(Set<int> ids) async {
    final sorted = ids.toList()..sort();
    await (await _preferences()).setStringList(favoriteIdsKey, [
      for (final id in sorted) '$id',
    ]);
  }
}
