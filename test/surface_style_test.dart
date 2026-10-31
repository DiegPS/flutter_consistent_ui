import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/geometry.dart';

void main() {
  test('installed appearance extensions remain available without restating policies', () {
    const borders = UiBorderTheme(kind: UiBorderKind.none);
    const surfaces = UiSurfaceStyle(elevation: 2);
    final theme = UiTheme.apply(
      ThemeData(extensions: const [borders, surfaces]),
    );
    expect(theme.extension<UiBorderTheme>(), same(borders));
    expect(theme.extension<UiSurfaceStyle>(), same(surfaces));
    expect(theme.inputDecorationTheme.border, InputBorder.none);
    expect(theme.cardTheme.elevation, 2);
  });

  for (final compact in [false, true]) {
    testWidgets(
      'statistic surfaces inherit native Card appearance compact=$compact',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(
              ThemeData(),
              surfaces: const UiSurfaceStyle(
                shape: BeveledRectangleBorder(),
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                shadowColor: Colors.orange,
              ),
            ),
            home: Scaffold(
              body: UiStatCard(
                label: 'Orders',
                value: '12',
                icon: Icons.list,
                compact: compact,
              ),
            ),
          ),
        );
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(Card),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(material.shape, isA<BeveledRectangleBorder>());
        expect(material.elevation, 2);
        expect(material.clipBehavior, Clip.hardEdge);
        expect(material.shadowColor, Colors.orange);
      },
    );
  }

  test(
    'surface styles merge, clear and interpolate without ambiguous sides',
    () {
      const a = UiSurfaceStyle(
        border: BorderSide(width: 2),
        elevation: 2,
        shadowColor: Colors.black,
        clipBehavior: Clip.hardEdge,
      );
      const shape = BeveledRectangleBorder();
      final shaped = a.copyWith(shape: shape);
      expect(shaped.border, isNull);
      expect(shaped.shape, shape);
      final bordered = shaped.merge(
        const UiSurfaceStyle(border: BorderSide.none, elevation: 0),
      );
      expect(bordered.shape, isNull);
      expect(bordered.border, BorderSide.none);
      expect(bordered.elevation, 0);
      expect(bordered.clipBehavior, Clip.hardEdge);
      expect(a.merge(null), same(a));
      expect(a.lerp(null, .5), same(a));
      final b = a.copyWith(border: const BorderSide(width: 4), elevation: 6);
      expect(a.lerp(b, .5).border!.width, 3);
      expect(a.lerp(b, .5).elevation, 4);
      expect(a.lerp(shaped, .25).border, a.border);
      expect(a.lerp(shaped, .75).shape, shape);
      expect(
        () => UiSurfaceStyle(shape: shape, border: BorderSide.none),
        throwsAssertionError,
      );
      expect(
        () => UiSurfaceStyle(elevation: double.infinity),
        throwsAssertionError,
      );
    },
  );

  for (final brightness in Brightness.values) {
    for (final inverse in [false, true]) {
      testWidgets(
        'surface overrides preserve content, focus and callbacks $brightness $inverse',
        (tester) async {
          final controller = TextEditingController();
          final focus = FocusNode();
          final appearance = ValueNotifier<UiSurfaceStyle>(
            const UiSurfaceStyle(),
          );
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          addTearDown(appearance.dispose);
          var taps = 0;
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiControls.input(
                key: const Key('input'),
                controller: controller,
                focusNode: focus,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              UiControls.secondary(
                onPressed: () => taps++,
                child: const Text('Action'),
              ),
            ],
          );
          final theme = UiTheme.apply(
            ThemeData(brightness: brightness),
            borders: const UiBorderTheme(focusedWidth: 4),
            surfaces: const UiSurfaceStyle(
              border: BorderSide(color: Colors.purple, width: 2),
              elevation: 3,
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: ValueListenableBuilder<UiSurfaceStyle>(
                  valueListenable: appearance,
                  builder: (context, style, child) => inverse
                      ? UiSurface.inverse(
                          key: const Key('surface'),
                          style: style,
                          child: content,
                        )
                      : UiSurface(
                          key: const Key('surface'),
                          style: style,
                          child: content,
                        ),
                ),
              ),
            ),
          );
          Material material() => tester.widget<Material>(
            find
                .descendant(
                  of: find.byKey(const Key('surface')),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(material().elevation, 3);
          expect((material().shape! as RoundedRectangleBorder).side.width, 2);
          expect(
            material().color,
            inverse
                ? theme.colorScheme.inverseSurface
                : theme.colorScheme.surfaceContainerLowest,
          );
          final buttonContext = tester.element(find.byType(OutlinedButton));
          expect(
            Theme.of(buttonContext).outlinedButtonTheme.style!.side!
                .resolve({WidgetState.focused})!
                .width,
            4,
          );
          await tester.enterText(find.byType(TextField), 'Draft survives');
          final height = visibleField(
            tester,
            find.byKey(const Key('input')),
          ).height;
          appearance.value = const UiSurfaceStyle(
            border: BorderSide.none,
            elevation: 0,
            shadowColor: Colors.orange,
            clipBehavior: Clip.none,
          );
          await tester.pump();
          expect(material().elevation, 0);
          expect(material().clipBehavior, Clip.none);
          expect(material().shadowColor, Colors.orange);
          expect(
            (material().shape! as RoundedRectangleBorder).side,
            BorderSide.none,
          );
          expect(controller.text, 'Draft survives');
          expect(focus.hasFocus, isTrue);
          expect(
            visibleField(tester, find.byKey(const Key('input'))).height,
            height,
          );
          appearance.value = const UiSurfaceStyle(
            shape: BeveledRectangleBorder(),
            elevation: 1,
          );
          await tester.pump();
          expect(material().shape, isA<BeveledRectangleBorder>());
          await tester.tap(find.text('Action'));
          expect(taps, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final kind in UiBorderKind.values) {
    testWidgets('scaled floating labels keep natural room with $kind', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.25;
      tester.view.physicalSize = const Size(450, 2000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(
            ThemeData(),
            borders: UiBorderTheme(kind: kind, focusedWidth: 5),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(3)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: form,
                child: UiFormFields(
                  children: [
                    UiControls.formInput(
                      key: const Key('field'),
                      focusNode: focus,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        helperText: 'Ayuda completa',
                      ),
                      validator: (_) => 'Captura requerida',
                    ),
                    const Text('Siguiente campo'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final before = visibleField(tester, find.byKey(const Key('field')));
      expect(before.height, greaterThanOrEqualTo(88));
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(
        visibleField(tester, find.byKey(const Key('field'))).height,
        before.height,
      );
      form.currentState!.validate();
      await tester.pumpAndSettle();
      expect(
        visibleField(tester, find.byKey(const Key('field'))).height,
        before.height,
      );
      expect(
        tester.getBottomLeft(find.text('Captura requerida')).dy,
        lessThan(tester.getTopLeft(find.text('Siguiente campo')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
