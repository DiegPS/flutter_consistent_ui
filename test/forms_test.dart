import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() {
  for (final width in [320.0, 600.0, 760.0, 1200.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('natural grid uses available width $width and scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData(useMaterial3: true)),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1600),
                  textScaler: TextScaler.linear(scale),
                ),
                child: SingleChildScrollView(
                  child: UiFormGrid(
                    children: [
                      UiControls.formInput(
                        key: const Key('first'),
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          helperText: 'Ayuda que ocupa espacio natural debajo del borde.',
                          helperMaxLines: 4,
                        ),
                      ),
                      UiControls.input(
                        key: const Key('second'),
                        decoration: const InputDecoration(
                          labelText: 'Económico',
                        ),
                      ),
                      UiControls.input(
                        key: const Key('third'),
                        decoration: const InputDecoration(labelText: 'VIN'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final first = tester.getRect(find.byKey(const Key('first')));
        final second = tester.getRect(find.byKey(const Key('second')));
        final third = tester.getRect(find.byKey(const Key('third')));
        if (width >= 560 * scale + 20) {
          expect(second.top, first.top);
          expect(second.left - first.right, closeTo(20, .1));
          expect(third.top - first.bottom, greaterThanOrEqualTo(20));
        } else {
          expect(second.top - first.bottom, greaterThanOrEqualTo(20));
          expect(second.width, width);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'resize preserves uncontrolled capture and focus across columns',
    (tester) async {
      tester.view.physicalSize = const Size(760, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData(useMaterial3: true)),
          home: Scaffold(
            body: UiFormGrid(
              children: [
                UiControls.input(key: const Key('capture'), focusNode: focus),
                UiControls.input(),
              ],
            ),
          ),
        ),
      );
      await tester.enterText(find.byKey(const Key('capture')), 'ABC-123');
      tester.view.physicalSize = const Size(390, 900);
      await tester.pump();
      expect(find.text('ABC-123'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      tester.view.physicalSize = const Size(760, 900);
      await tester.pump();
      expect(find.text('ABC-123'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
