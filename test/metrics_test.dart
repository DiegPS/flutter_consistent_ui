import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() {
  for (final width in [360.0, 800.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('metric grid fills $width with readable text at $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData(useMaterial3: true)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: UiMetricGrid(
                  itemHeight: 96,
                  children: [
                    for (var i = 0; i < 4; i++)
                      UiMetricCard(
                        label: 'Saldo pendiente de autorización',
                        value: r'$1,234,567.89',
                        icon: Icons.payments_outlined,
                        deltaPercent: 100,
                        animated: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.byType(FittedBox), findsNothing);
        final cards = find.byType(UiMetricCard);
        final first = tester.getRect(cards.at(0));
        final second = tester.getRect(cards.at(1));
        final last = tester.getRect(cards.at(3));
        expect(first.left, 0);
        if (width >= 4 * 240 * scale + 48) {
          expect(last.right, width);
          expect(last.height, first.height);
        } else if (width >= 2 * 240 * scale + 16) {
          expect(second.right, width);
          expect(second.height, first.height);
        } else {
          expect(first.width, width);
          expect(second.top, greaterThan(first.bottom));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
