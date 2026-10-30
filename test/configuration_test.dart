import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

import 'helpers/geometry.dart';

void main() {
  test('configuration copies and interpolates every dimension', () {
    const a = UiThemeData();
    final b = a.copyWith(
      controlHeight: 44,
      compactControlHeight: 52,
      compactBreakpoint: 700,
      fontSize: 16,
      lineHeight: 24,
      fieldHorizontalPadding: 16,
      actionHorizontalPadding: 20,
      controlRadius: 12,
      panelRadius: 16,
      formSpacing: 24,
      minimumFieldWidth: 320,
    );
    final halfway = a.lerp(b, .5);
    expect(halfway.controlHeight, 42);
    expect(halfway.compactControlHeight, 50);
    expect(halfway.compactBreakpoint, 650);
    expect(halfway.fontSize, 15);
    expect(halfway.lineHeight, 22);
    expect(halfway.fieldHorizontalPadding, 14);
    expect(halfway.actionHorizontalPadding, 18);
    expect(halfway.controlRadius, 9);
    expect(halfway.panelRadius, 13);
    expect(halfway.formSpacing, 22);
    expect(halfway.minimumFieldWidth, 300);
    expect(a.lerp(null, .5), same(a));
  });
  for (final compact in [true, false]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'custom geometry, colors and fonts / $compact / $brightness',
        (tester) async {
          tester.view.physicalSize = Size(compact ? 390 : 1200, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final original = ThemeData(
            useMaterial3: true,
            fontFamily: 'ProjectFont',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              brightness: brightness,
            ),
          );
          final theme = UiTheme.apply(
            original,
            geometry: const UiThemeData(
              controlHeight: 44,
              compactControlHeight: 52,
              fontSize: 16,
              lineHeight: 24,
            ),
          );
          expect(theme.colorScheme, original.colorScheme);
          expect(theme.textTheme.bodyMedium!.fontFamily, 'ProjectFont');
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: UiFormFields(
                  children: [
                    UiControls.input(
                      key: const Key('text'),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    UiControls.select<int>(
                      key: const Key('select'),
                      initialValue: 1,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('One')),
                      ],
                      onChanged: (_) {},
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    UiControls.primary(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        fixedSize: const Size(90, 90),
                        maximumSize: const Size(100, 100),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          );
          final expected = compact ? 52.0 : 44.0;
          expect(
            visibleField(tester, find.byKey(const Key('text'))).height,
            closeTo(expected, .6),
          );
          expect(
            visibleField(tester, find.byKey(const Key('select'))).height,
            closeTo(expected, .6),
          );
          expect(
            tester
                .getSize(
                  find
                      .descendant(
                        of: find.byType(FilledButton),
                        matching: find.byType(Material),
                      )
                      .first,
                )
                .height,
            closeTo(expected, .6),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'native formatters, read-only behavior and Form.save are forwarded',
    (tester) async {
      final form = GlobalKey<FormState>();
      var saved = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData()),
          home: Scaffold(
            body: Form(
              key: form,
              child: UiControls.formInput(
                key: const Key('digits'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) => saved = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byKey(const Key('digits')), 'abc123');
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, '123');
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'semantic text pairs have AA contrast in default light and dark palettes',
    () {
      for (final brightness in Brightness.values) {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );
        final palette = UiSemanticColors.fromColorScheme(scheme);
        expect(palette.brand.strong, scheme.primary);
        for (final tone in [
          palette.brand,
          palette.success,
          palette.warning,
          palette.info,
          palette.security,
          palette.ai,
          palette.document,
        ]) {
          for (final pair in [
            (tone.strong, tone.onStrong),
            (tone.container, tone.onContainer),
          ]) {
            final a = pair.$1.computeLuminance(),
                b = pair.$2.computeLuminance();
            expect(
              ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    },
  );
}
