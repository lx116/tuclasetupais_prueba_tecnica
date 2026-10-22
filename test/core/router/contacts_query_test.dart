import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/app_routes.dart';
import 'package:tuclasetupais_prueba_tecnica/core/router/contacts_query.dart';

void main() {
  group('ContactsQuery', () {
    test('is empty by default and has no params', () {
      const query = ContactsQuery();
      expect(query.isEmpty, isTrue);
      expect(query.toParams(), isNull);
    });

    test('reads search and department from a URI', () {
      final query = ContactsQuery.fromUri(
        Uri.parse('/contacts/3?search=ana&department=ingenieria&x=1'),
      );

      expect(query.search, 'ana');
      expect(query.department, 'ingenieria');
    });

    test('a URI without params is empty', () {
      expect(ContactsQuery.fromUri(Uri.parse('/contacts')).isEmpty, isTrue);
    });

    test('writes only the params that are set', () {
      expect(const ContactsQuery(search: 'ana').toParams(), {'search': 'ana'});
      expect(const ContactsQuery(department: 'diseno').toParams(), {
        'department': 'diseno',
      });
      expect(
        const ContactsQuery(search: 'ana', department: 'diseno').toParams(),
        {'search': 'ana', 'department': 'diseno'},
      );
    });

    test('copyWith changes one field and can clear it', () {
      const query = ContactsQuery(search: 'ana', department: 'diseno');

      expect(query.copyWith(search: 'bruno').department, 'diseno');
      expect(query.copyWith(department: '').toParams(), {'search': 'ana'});
    });

    test('compares by value', () {
      expect(
        const ContactsQuery(search: 'a'),
        const ContactsQuery(search: 'a'),
      );
      expect(
        const ContactsQuery(search: 'a'),
        isNot(const ContactsQuery(search: 'b')),
      );
    });
  });

  group('AppRoutes', () {
    test('locations without a query are plain paths', () {
      expect(AppRoutes.contactsLocation(), '/contacts');
      expect(AppRoutes.contactDetail(7), '/contacts/7');
    });

    test('locations carry search and department', () {
      const query = ContactsQuery(search: 'ana pé', department: 'diseno');

      final list = Uri.parse(AppRoutes.contactsLocation(query: query));
      final detail = Uri.parse(AppRoutes.contactDetail(7, query: query));

      expect(list.path, '/contacts');
      expect(list.queryParameters, {
        'search': 'ana pé',
        'department': 'diseno',
      });
      expect(detail.path, '/contacts/7');
      expect(detail.queryParameters, list.queryParameters);
    });
  });
}
