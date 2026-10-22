class Contact {
  const Contact({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          other.id == id &&
          other.name == name &&
          other.role == role &&
          other.department == department &&
          other.email == email &&
          other.phone == phone &&
          other.active == active;

  @override
  int get hashCode =>
      Object.hash(id, name, role, department, email, phone, active);
}
