import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/core/widgets/brand_header.dart';
import 'package:tuclasetupais_prueba_tecnica/core/widgets/reload_button.dart';
import 'package:tuclasetupais_prueba_tecnica/core/widgets/state_message.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('StateMessage shows title, message and its action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        StateMessage(
          icon: Icons.wifi_off,
          title: 'Título',
          message: 'Mensaje',
          action: ReloadButton(label: 'Reintentar', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Mensaje'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('ReloadButton reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(ReloadButton(label: 'Recargar', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Recargar'));

    expect(taps, 1);
  });

  testWidgets('BrandHeader shows the app name', (tester) async {
    await tester.pumpWidget(_host(const BrandHeader()));

    expect(find.text('Contactos'), findsOneWidget);
  });

  test('the theme uses the design palette and Manrope', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, const Color(0xFF1A535C));
    expect(theme.colorScheme.secondary, const Color(0xFF4ECDC4));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF7FFF7));
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
  });
}
