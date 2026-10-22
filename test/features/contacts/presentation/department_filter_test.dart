import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_colors.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/features/contacts/presentation/ui/department_filter.dart';

Widget _host(String selected, ValueChanged<String> onChanged) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: DepartmentFilter(selected: selected, onChanged: onChanged),
  ),
);

Color? _chipColor(WidgetTester tester, String key) => tester
    .widget<Material>(
      find
          .descendant(
            of: find.byKey(ValueKey('department-chip-$key')),
            matching: find.byType(Material),
          )
          .first,
    )
    .color;

void main() {
  testWidgets('shows Todos and every catalog department', (tester) async {
    await tester.pumpWidget(_host('', (_) {}));

    for (final label in [
      'Todos',
      'Comercial',
      'Diseño',
      'Ingeniería',
      'Personas',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('Todos is selected when there is no department', (tester) async {
    await tester.pumpWidget(_host('', (_) {}));

    expect(_chipColor(tester, 'all'), AppColors.strongCyan);
    expect(_chipColor(tester, 'ingenieria'), AppColors.surface);
  });

  testWidgets('selects the chip of the URL form, ignoring case', (
    tester,
  ) async {
    await tester.pumpWidget(_host('INGENIERIA', (_) {}));

    expect(_chipColor(tester, 'ingenieria'), AppColors.strongCyan);
    expect(_chipColor(tester, 'all'), AppColors.surface);
  });

  testWidgets('an unknown department selects no chip', (tester) async {
    await tester.pumpWidget(_host('marketing', (_) {}));

    expect(_chipColor(tester, 'all'), AppColors.surface);
    expect(_chipColor(tester, 'diseno'), AppColors.surface);
  });

  testWidgets('tapping a chip reports its URL form, Todos reports empty', (
    tester,
  ) async {
    final picked = <String>[];
    await tester.pumpWidget(_host('diseno', picked.add));

    await tester.tap(find.text('Ingeniería'));
    await tester.tap(find.text('Todos'));

    expect(picked, ['ingenieria', '']);
  });
}
