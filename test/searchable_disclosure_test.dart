import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

import 'helpers/geometry.dart';

void main() {
  testWidgets(
    'search retains caller controller, focus, draft and explicit styles',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      final selections = <String?>[];
      Widget app() => MaterialApp(
        theme: UiTheme.apply(
          ThemeData(
            dropdownMenuTheme: const DropdownMenuThemeData(
              inputDecorationTheme: InputDecorationThemeData(
                fillColor: Colors.yellow,
                filled: true,
              ),
            ),
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: UiControls.searchableSelect<String>(
              key: const Key('search'),
              controller: controller,
              focusNode: focus,
              errorText: 'An explanation longer than the control itself must remain visible below the border.',
              entries: const [DropdownMenuEntry(value: 'a', label: 'Alpha')],
              onSelected: selections.add,
            ),
          ),
        ),
      );
      await tester.pumpWidget(app());
      await tester.enterText(find.byType(TextField), 'Al');
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isTrue);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(controller.text, 'Al');
      expect(focus.hasFocus, isTrue);
      expect(
        tester
            .widget<DropdownMenu<String>>(find.byType(DropdownMenu<String>))
            .inputDecorationTheme!
            .fillColor,
        Colors.yellow,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(selections, ['a']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Caller still owns this controller';
    },
  );

  testWidgets('disabled searchable select cannot open or select', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UiControls.searchableSelect<String>(
            enabled: false,
            entries: const [DropdownMenuEntry(value: 'a', label: 'Alpha')],
            onSelected: (_) => changes++,
          ),
        ),
      ),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(changes, 0);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('expanded disclosure keeps long labels at 200 percent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(ThemeData()),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: UiDisclosure(
              title: Text(
                'A long heading that must wrap without being clipped',
              ),
              subtitle: Text('A detailed explanation beneath the heading.'),
              initiallyExpanded: true,
              children: [Text('Expanded content')],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Expanded content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [360.0, 1200.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('select borders and search agree at $width / $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData()),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    UiControls.input(
                      key: const Key('input'),
                      decoration: const InputDecoration(labelText: 'Input'),
                    ),
                    const SizedBox(height: 20),
                    UiControls.select<String>(
                      key: const Key('select'),
                      initialValue: 'a',
                      decoration: const InputDecoration(labelText: 'Select'),
                      items: const [
                        DropdownMenuItem(value: 'a', child: Text('Alpha')),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 20),
                    UiControls.searchableSelect<String>(
                      key: const Key('search'),
                      label: const Text('Search'),
                      helperText: 'Help stays outside the field border.',
                      entries: const [
                        DropdownMenuEntry(value: 'a', label: 'Alpha'),
                        DropdownMenuEntry(value: 'b', label: 'Beta'),
                      ],
                      onSelected: (value) => selected = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final heights = [
          for (final key in ['input', 'select', 'search'])
            visibleField(tester, find.byKey(Key(key))).height,
        ];
        expect(heights, hasLength(3));
        expect(heights[1], closeTo(heights[0], 1));
        expect(heights[2], closeTo(heights[0], 1));
        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('search')),
            matching: find.byType(TextField),
          ),
          'Beta',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Beta').last);
        await tester.pumpAndSettle();
        expect(selected, 'b');
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'disclosure preserves draft focus and callbacks across expansion',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      final changes = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData()),
          home: Scaffold(
            body: SingleChildScrollView(
              child: UiDisclosure(
                title: const Text('Options'),
                subtitle: const Text('Description'),
                initiallyExpanded: true,
                onExpansionChanged: changes.add,
                children: [
                  UiControls.input(controller: controller, focusNode: focus),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Draft');
      await tester.tap(find.text('Options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Options'));
      await tester.pumpAndSettle();
      expect(controller.text, 'Draft');
      expect(changes, [false, true]);
      expect(find.text('Draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('disclosure respects explicit theme and large text', (
    tester,
  ) async {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(
          ThemeData(
            expansionTileTheme: const ExpansionTileThemeData(
              shape: shape,
              collapsedShape: shape,
              backgroundColor: Colors.yellow,
              collapsedBackgroundColor: Colors.yellow,
              textColor: Colors.red,
            ),
          ),
        ),
        home: const Scaffold(
          body: UiDisclosure(title: Text('Options'), children: [Text('Body')]),
        ),
      ),
    );
    final tile = tester.widget<ExpansionTile>(find.byType(ExpansionTile));
    expect(tile.shape, shape);
    expect(tile.backgroundColor, Colors.yellow);
    expect(tile.textColor, Colors.red);
  });
}
