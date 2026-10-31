import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [360.0, 680.0, 1440.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('descendant updates resize grid at $width / $scale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1.25;
        tester.view.physicalSize = Size(width * 1.25, 1500 * 1.25);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final content = ValueNotifier<double>(60);
        addTearDown(content.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: UiMetricGrid(
                    children: List.generate(
                      4,
                      (index) => Material(
                        key: ValueKey('card-$index'),
                        child: ValueListenableBuilder<double>(
                          valueListenable: content,
                          builder: (context, height, child) => LayoutBuilder(
                            builder: (context, constraints) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: index == 0 ? height : 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        for (final height in [180.0, 60.0, 240.0, 50.0]) {
          content.value = height;
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byKey(const ValueKey('card-0'))).height,
            height,
          );
          if (width >= (240 * scale * 2 + 16)) {
            expect(
              tester.getSize(find.byKey(const ValueKey('card-1'))).height,
              height,
            );
          }
        }
      });
    }
  }
}
