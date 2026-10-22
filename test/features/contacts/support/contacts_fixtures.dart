import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/data/datasources/dice_roller.dart';

Map<String, dynamic> contactJson({
  int id = 1,
  Map<String, dynamic>? overrides,
}) => {
  'id': id,
  'name': 'Camila Reyes',
  'role': 'Product Designer',
  'department': 'Diseño',
  'email': 'camila.reyes@empresa.cl',
  'phone': '+56 9 1111 2222',
  'active': true,
  ...?overrides,
};

/// In-memory bundle that throws like the platform bundle for missing assets.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

/// Dice that always lands on [value].
class FixedDice implements DiceRoller {
  FixedDice(this.value);

  final int value;

  @override
  int roll() => value;
}
