import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    for (final inverse in [false, true]) {
      testWidgets(
        'surface contrast $brightness inverse=$inverse with explicit inherited button colors',
        (tester) async {
          var tapped = 0;
          final scheme = ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: brightness,
          );
          final outer = UiTheme.apply(
            ThemeData(
              colorScheme: scheme,
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ),
          );
          late ThemeData scoped;
          final content = Builder(
            builder: (context) {
              scoped = Theme.of(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Readable text'),
                  const Icon(Icons.restore),
                  UiControls.secondaryIcon(
                    onPressed: () => tapped++,
                    icon: const Icon(Icons.restore),
                    label: const Text('Recover'),
                  ),
                  UiControls.secondary(
                    onPressed: null,
                    child: const Text('Disabled'),
                  ),
                  UiControls.quiet(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  UiControls.primary(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  UiControls.tonal(
                    onPressed: () {},
                    child: const Text('Tonal'),
                  ),
                ],
              );
            },
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: outer,
              home: Scaffold(
                body: inverse
                    ? UiSurface.inverse(child: content)
                    : UiSurface(child: content),
              ),
            ),
          );
          final bg = inverse
              ? scheme.inverseSurface
              : scheme.surfaceContainerLowest;
          final expected = inverse ? scheme.onInverseSurface : scheme.onSurface;
          final textContext = tester.element(find.text('Readable text'));
          expect(DefaultTextStyle.of(textContext).style.color, expected);
          expect(contrast(expected, bg), greaterThanOrEqualTo(4.5));
          final recoverContext = tester.element(find.text('Recover'));
          expect(DefaultTextStyle.of(recoverContext).style.color, expected);
          final iconContext = tester.element(find.byIcon(Icons.restore).last);
          expect(IconTheme.of(iconContext).color, expected);
          final disabled = DefaultTextStyle.of(
            tester.element(find.text('Disabled')),
          ).style.color!;
          expect(
            contrast(Color.alphaBlend(disabled, bg), bg),
            greaterThanOrEqualTo(3),
          );
          expect(
            scoped.extension<UiThemeData>(),
            same(outer.extension<UiThemeData>()),
          );
          for (final label in ['Primary', 'Tonal']) {
            final context = tester.element(find.text(label));
            final fg = DefaultTextStyle.of(context).style.color!;
            final material = tester.widget<Material>(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(Material),
                  )
                  .first,
            );
            expect(
              contrast(fg, material.color!),
              greaterThanOrEqualTo(4.5),
              reason: label,
            );
          }
          await tester.tap(find.text('Recover'));
          expect(tapped, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
