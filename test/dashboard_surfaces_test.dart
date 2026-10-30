import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'compact statistic keeps the value and action without vertical chrome',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiStatCard(
              compact: true,
              label: 'Orders',
              value: '12',
              category: 'OPERATIONS',
              icon: Icons.build,
              onTap: () => taps++,
            ),
          ),
        ),
      );
      expect(find.byType(UiMetricCard), findsOneWidget);
      expect(find.text('OPERATIONS'), findsNothing);
      await tester.tap(find.text('Orders'));
      expect(taps, 1);
    },
  );
  for (final width in [360.0, 1200.0]) {
    testWidgets('statistic and split view adapt at $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData()),
          home: Scaffold(
            body: SingleChildScrollView(
              child: UiSplitView(
                primary: UiStatCard(
                  label: 'Active orders',
                  value: '12',
                  category: 'OPERATIONS',
                  description: 'Real current orders',
                  icon: Icons.build,
                  onTap: () => taps++,
                ),
                secondary: const Text('Secondary'),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Active orders'));
      expect(taps, 1);
      final first = tester.getRect(find.byType(UiStatCard));
      final second = tester.getRect(find.text('Secondary'));
      expect(
        width < 1000 ? second.top >= first.bottom : second.left > first.right,
        isTrue,
      );
    });
  }
}
