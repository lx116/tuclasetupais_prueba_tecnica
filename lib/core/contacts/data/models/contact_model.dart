import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_validators.dart';
import 'phone_number_validator.dart';

/// DTO for [Contact]: parses and serializes JSON and maps to the entity.
class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.active,
  });

  final int id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final bool active;

  /// Throws a [FormatException] when a field is missing, has the wrong type
  /// or breaks a contact rule.
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final model = ContactModel(
      id: _field<int>(json, 'id'),
      name: _field<String>(json, 'name'),
      role: _field<String>(json, 'role'),
      department: _field<String>(json, 'department'),
      email: _field<String>(json, 'email'),
      phone: _field<String>(json, 'phone'),
      active: _field<bool>(json, 'active'),
    );

    final error =
        ContactValidators.role(model.role) ??
        ContactValidators.department(model.department) ??
        ContactValidators.email(model.email) ??
        PhoneNumberValidator.validate(model.phone);
    if (error != null) {
      throw FormatException('Invalid contact ${model.id}: $error');
    }
    return model;
  }

  factory ContactModel.fromEntity(Contact contact) => ContactModel(
    id: contact.id,
    name: contact.name,
    role: contact.role,
    department: contact.department,
    email: contact.email,
    phone: contact.phone,
    active: contact.active,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'department': department,
    'email': email,
    'phone': phone,
    'active': active,
  };

  Contact toEntity() => Contact(
    id: id,
    name: name,
    role: role,
    department: department,
    email: email,
    phone: phone,
    active: active,
  );

  static T _field<T>(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! T) {
      throw FormatException(
        'Field "$key" must be a $T but was ${value == null ? 'missing' : value.runtimeType}',
      );
    }
    return value;
  }
}
