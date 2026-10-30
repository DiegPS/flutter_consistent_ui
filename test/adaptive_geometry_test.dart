import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/geometry.dart';

void main() {
  testWidgets('expanded select keeps natural menu rows and emits selection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(ThemeData()),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(3)),
          child: child!,
        ),
        home: Scaffold(
          body: UiControls.select<String>(
            initialValue: 'a',
            items: const [
              DropdownMenuItem(value: 'a', child: Text('Alpha')),
              DropdownMenuItem(value: 'b', child: Text('Beta')),
            ],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    final dropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(dropdown.isExpanded, isTrue);
    expect(dropdown.itemHeight, isNull);
    await tester.tap(find.text('Alpha').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();
    expect(selected, 'b');
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit statistic remains vertical on a compact window', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UiStatCard(
            label: 'Orders',
            value: '12',
            category: 'DETAIL',
            icon: Icons.build,
          ),
        ),
      ),
    );
    expect(find.byType(UiMetricCard), findsNothing);
    expect(find.text('DETAIL'), findsOneWidget);
  });
  for (final width in [320.0, 599.0, 600.0]) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final dpr in [1.0, 1.25]) {
        testWidgets('visible geometry $width / scale $scale / dpr $dpr', (
          tester,
        ) async {
          tester.view.devicePixelRatio = dpr;
          tester.view.physicalSize = Size(width * dpr, 2400 * dpr);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: UiTheme.apply(ThemeData()),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: UiFormFields(
                      children: [
                        UiControls.formInput(
                          key: const Key('field'),
                          initialValue: 'A',
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            helperText:
                                'Help must occupy its own vertical space.',
                            prefixIcon: Icon(Icons.person),
                            suffixIcon: Icon(Icons.check),
                          ),
                        ),
                        UiControls.select<String>(
                          key: const Key('select'),
                          initialValue: 'a',
                          decoration: const InputDecoration(labelText: 'State'),
                          items: const [
                            DropdownMenuItem(value: 'a', child: Text('Active')),
                          ],
                          onChanged: (_) {},
                        ),
                        UiControls.primary(
                          key: const Key('button'),
                          onPressed: () {},
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          final expected = (width < 600 ? 48 : 40) + (scale - 1) * 20;
          final field = visibleField(tester, find.byKey(const Key('field')));
          final select = visibleField(tester, find.byKey(const Key('select')));
          final button = tester.getRect(
            find
                .descendant(
                  of: find.byKey(const Key('button')),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(field.height, closeTo(expected, .6));
          expect(select.height, closeTo(expected, .6));
          expect(button.height, closeTo(expected, .6));
          final fullField = tester.getRect(find.byKey(const Key('field')));
          expect(fullField.height, greaterThan(field.height));
          expect(select.top - fullField.bottom, greaterThanOrEqualTo(19.9));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final scenario in [
    (window: 390.0, local: 350.0, scale: 1.0, horizontal: true),
    (window: 1400.0, local: 220.0, scale: 1.0, horizontal: true),
    (window: 1400.0, local: 400.0, scale: 1.0, horizontal: false),
    (window: 1400.0, local: 400.0, scale: 2.0, horizontal: true),
  ]) {
    testWidgets('adaptive statistic uses local space $scenario', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(scenario.window, 1200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData()),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scenario.scale)),
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: scenario.local,
                child: const UiStatCard.adaptive(
                  label: 'Orders',
                  value: '12',
                  category: 'OPERATIONS',
                  icon: Icons.build,
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        find.byType(UiMetricCard),
        scenario.horizontal ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('split resize keeps text, focus and exact instance state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UiSplitView(
            primary: UiControls.input(
              key: const Key('capture'),
              focusNode: focus,
            ),
            secondary: const Text('Other panel'),
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('capture')), 'Keep this draft');
    final before = tester.state<EditableTextState>(find.byType(EditableText));
    for (final width in [390.0, 1200.0, 600.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pump();
      expect(
        tester.state<EditableTextState>(find.byType(EditableText)),
        same(before),
      );
      expect(find.text('Keep this draft'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    }
  });
}
