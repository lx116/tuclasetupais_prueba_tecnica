import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuclasetupais_prueba_tecnica/core/theme/app_theme.dart';
import 'package:tuclasetupais_prueba_tecnica/shared/presentation/widgets/search_input.dart';

const _debounce = Duration(milliseconds: 300);

class _Host extends StatefulWidget {
  const _Host({required this.onChanged, this.initial = ''});

  final ValueChanged<String> onChanged;
  final String initial;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String value = widget.initial;

  void setValue(String next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SearchInput(
          value: value,
          hintText: 'Buscar contactos',
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

void main() {
  testWidgets('shows the hint and the initial value', (tester) async {
    await tester.pumpWidget(_Host(onChanged: (_) {}, initial: 'ana'));

    expect(find.widgetWithText(TextField, 'ana'), findsOneWidget);

    await tester.pumpWidget(_Host(onChanged: (_) {}));
    expect(find.text('Buscar contactos'), findsOneWidget);
  });

  testWidgets('reports the text once typing pauses, not on every key', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(_Host(onChanged: calls.add));

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'ana');
    expect(calls, isEmpty);

    await tester.pump(_debounce);

    expect(calls, ['ana']);
  });

  testWidgets('submitting reports immediately', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_Host(onChanged: calls.add));

    await tester.enterText(find.byType(TextField), 'ana');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(calls, ['ana']);
    await tester.pump(_debounce);
    expect(calls, ['ana'], reason: 'The pending debounce was cancelled.');
  });

  testWidgets('the clear button empties the field and reports right away', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(_Host(onChanged: calls.add, initial: 'ana'));

    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pump();

    expect(calls, ['']);
    expect(find.widgetWithText(TextField, ''), findsOneWidget);
    expect(find.byTooltip('Limpiar búsqueda'), findsNothing);
  });

  testWidgets('has no clear button while empty', (tester) async {
    await tester.pumpWidget(_Host(onChanged: (_) {}));

    expect(find.byTooltip('Limpiar búsqueda'), findsNothing);
  });

  testWidgets('follows an external value change', (tester) async {
    await tester.pumpWidget(_Host(onChanged: (_) {}, initial: 'ana'));

    tester.state<_HostState>(find.byType(_Host)).setValue('bruno');
    await tester.pump();

    expect(find.widgetWithText(TextField, 'bruno'), findsOneWidget);
  });

  testWidgets('an external change does not overwrite what is being typed', (
    tester,
  ) async {
    await tester.pumpWidget(_Host(onChanged: (_) {}, initial: 'ana'));

    await tester.enterText(find.byType(TextField), 'ana m');
    tester.state<_HostState>(find.byType(_Host)).setValue('ana');
    await tester.pump();

    expect(find.widgetWithText(TextField, 'ana m'), findsOneWidget);
    await tester.pump(_debounce);
  });

  testWidgets('does not leave a timer behind when removed while typing', (
    tester,
  ) async {
    await tester.pumpWidget(_Host(onChanged: (_) {}));
    await tester.enterText(find.byType(TextField), 'a');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
