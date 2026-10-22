/// Allowed values for [Contact.role].
class ContactRoles {
  const ContactRoles._();

  static const List<String> all = [
    'Account Manager',
    'Backend Engineer',
    'Data Analyst',
    'DevOps Engineer',
    'Frontend Engineer',
    'HR Business Partner',
    'People Ops',
    'Product Designer',
    'Product Manager',
    'QA Lead',
    'Recruiter',
    'Sales Rep',
    'UX Researcher',
  ];

  static bool contains(String value) => all.contains(value);
}

/// Allowed values for [Contact.department].
class ContactDepartments {
  const ContactDepartments._();

  static const List<String> all = [
    'Comercial',
    'Diseño',
    'Ingeniería',
    'Personas',
  ];

  static bool contains(String value) => all.contains(value);
}
