import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'changing grid spacing and minimum height relayouts without a fixed maximum',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      Future<void> mount(
        double spacing,
        double minimum,
        TextDirection direction,
      ) => tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: UiMetricGrid(
                spacing: spacing,
                itemHeight: minimum,
                maximumColumns: 2,
                children: [
                  LayoutBuilder(
                    builder: (_, size) =>
                        const SizedBox(key: Key('a'), height: 80),
                  ),
                  LayoutBuilder(
                    builder: (_, size) =>
                        const SizedBox(key: Key('b'), height: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await mount(16, 100, TextDirection.ltr);
      expect(tester.getSize(find.byKey(const Key('a'))).height, 100);
      await mount(32, 180, TextDirection.rtl);
      final first = tester.getRect(find.byKey(const Key('a')));
      final second = tester.getRect(find.byKey(const Key('b')));
      expect(first.height, 180);
      expect(second.height, first.height);
      expect(first.left - second.right, closeTo(32, .1));
      expect(tester.takeException(), isNull);
    },
  );
  for (final direction in TextDirection.values) {
    testWidgets(
      'equal height supports LayoutBuilder, callbacks and $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        var tapped = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData()),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: UiMetricGrid(
                    maximumColumns: 2,
                    itemHeight: 100,
                    children: [
                      LayoutBuilder(
                        builder: (context, size) => SizedBox(
                          key: const Key('first'),
                          height: 150,
                          child: UiControls.primary(
                            onPressed: () => tapped++,
                            child: const Text('Tap first'),
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, size) =>
                            const SizedBox(key: Key('second'), height: 50),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final first = tester.getRect(find.byKey(const Key('first')));
        final second = tester.getRect(find.byKey(const Key('second')));
        expect(first.height, 150);
        expect(second.height, first.height);
        expect(first.width, closeTo((1200 - 16) / 2, .1));
        expect(
          direction == TextDirection.ltr
              ? first.left < second.left
              : first.left > second.left,
          isTrue,
        );
        await tester.tap(find.text('Tap first'));
        expect(tapped, 1);
      },
    );
  }
}
