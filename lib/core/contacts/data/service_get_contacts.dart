import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/entities/contact_validators.dart';
import 'models/contact_model.dart';

const String contactsAssetPath = 'lib/assets/contacs.json';

enum ContactsLoadStatus { notLoaded, loaded, missing, invalid }

typedef AuditLog =
    void Function(String message, {required int level, Object? error});

const int _warning = 900;
const int _severe = 1000;

void _developerLog(String message, {required int level, Object? error}) {
  developer.log(
    message,
    name: 'ServiceGetContacts',
    level: level,
    error: error,
  );
}

/// Loads the bundled contacts JSON once at startup and keeps it in memory so
/// the local datasource can serve it.
///
/// Bad paths never throw from [load]: they leave an empty list, record the
/// [status] and write an audit log.
class ServiceGetContacts {
  ServiceGetContacts({
    required this.bundle,
    this.assetPath = contactsAssetPath,
    this.log = _developerLog,
  });

  final AssetBundle bundle;
  final String assetPath;
  final AuditLog log;

  ContactsLoadStatus _status = ContactsLoadStatus.notLoaded;
  List<ContactModel> _contacts = const [];
  Object? _error;

  ContactsLoadStatus get status => _status;
  List<ContactModel> get contacts => _contacts;

  /// The [FormatException] that made the data invalid, if any.
  Object? get error => _error;

  Future<void> load() async {
    _contacts = const [];
    _error = null;

    final String raw;
    try {
      raw = await bundle.loadString(assetPath);
    } on FlutterError {
      _status = ContactsLoadStatus.missing;
      log(
        'Contacts asset not found at "$assetPath": '
        'loading cancelled, the contacts list will be empty.',
        level: _warning,
      );
      return;
    }

    try {
      _contacts = List.unmodifiable(_parse(raw));
      _status = ContactsLoadStatus.loaded;
    } on FormatException catch (e) {
      _status = ContactsLoadStatus.invalid;
      _error = e;
      log(
        'Contacts asset "$assetPath" does not match the contact model: '
        '${e.message}',
        level: _severe,
        error: e,
      );
    }
  }

  List<ContactModel> _parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON list of contacts');
    }

    final models = decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Every contact must be a JSON object');
      }
      return ContactModel.fromJson(item);
    }).toList();

    final repeated = ContactValidators.uniqueIds(
      models.map((m) => m.toEntity()).toList(),
    );
    if (repeated != null) throw FormatException(repeated);
    return models;
  }
}
