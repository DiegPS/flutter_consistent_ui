import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/geometry.dart';

void main() {
  test('explicit application styles are not overwritten by defaults', () {
    const border = UnderlineInputBorder(borderSide: BorderSide(width: 3));
    const shape = BeveledRectangleBorder();
    const decoration = BoxDecoration(color: Colors.orange);
    final buttons = ButtonStyle(
      shape: const WidgetStatePropertyAll(shape),
      side: const WidgetStatePropertyAll(BorderSide(width: 4)),
    );
    final base = ThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        disabledBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
      ),
      filledButtonTheme: FilledButtonThemeData(style: buttons),
      outlinedButtonTheme: OutlinedButtonThemeData(style: buttons),
      textButtonTheme: TextButtonThemeData(style: buttons),
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttons),
      cardTheme: const CardThemeData(
        shape: shape,
        elevation: 3,
        margin: EdgeInsets.all(7),
        shadowColor: Colors.orange,
        clipBehavior: Clip.none,
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: Colors.red,
        elevation: 4,
      ),
      dialogTheme: const DialogThemeData(
        shape: shape,
        backgroundColor: Colors.blue,
      ),
      bottomSheetTheme: const BottomSheetThemeData(shape: shape),
      popupMenuTheme: const PopupMenuThemeData(shape: shape),
      tooltipTheme: const TooltipThemeData(decoration: decoration),
      snackBarTheme: const SnackBarThemeData(
        shape: shape,
        behavior: SnackBarBehavior.fixed,
      ),
      dividerTheme: const DividerThemeData(color: Colors.red),
    );
    final theme = UiTheme.apply(base);
    final input = theme.inputDecorationTheme;
    expect([
      input.border,
      input.enabledBorder,
      input.focusedBorder,
      input.disabledBorder,
      input.errorBorder,
      input.focusedErrorBorder,
    ], everyElement(same(border)));
    expect(theme.filledButtonTheme.style!.shape, same(buttons.shape));
    expect(theme.outlinedButtonTheme.style!.side, same(buttons.side));
    expect(theme.textButtonTheme.style!.shape, same(buttons.shape));
    expect(theme.elevatedButtonTheme.style!.shape, same(buttons.shape));
    expect(theme.cardTheme, base.cardTheme);
    expect(theme.appBarTheme.backgroundColor, Colors.red);
    expect(theme.appBarTheme.elevation, 4);
    expect(theme.dialogTheme.shape, shape);
    expect(theme.dialogTheme.backgroundColor, Colors.blue);
    expect(theme.bottomSheetTheme.shape, shape);
    expect(theme.popupMenuTheme.shape, shape);
    expect(theme.tooltipTheme.decoration, decoration);
    expect(theme.snackBarTheme.shape, shape);
    expect(theme.snackBarTheme.behavior, SnackBarBehavior.fixed);
    expect(theme.dividerTheme.color, Colors.red);
  });

  test(
    'missing state borders inherit the explicit shape, not a forced outline',
    () {
      const border = UnderlineInputBorder(borderSide: BorderSide(width: 3));
      final theme = UiTheme.apply(
        ThemeData(
          inputDecorationTheme: const InputDecorationTheme(border: border),
        ),
      );
      expect(theme.inputDecorationTheme.enabledBorder, border);
      expect(
        theme.inputDecorationTheme.focusedBorder,
        isA<UnderlineInputBorder>(),
      );
      expect(theme.inputDecorationTheme.focusedBorder!.borderSide.width, 1.5);
    },
  );

  test('border states, copying and interpolation have explicit precedence', () {
    const policy = UiBorderTheme(
      width: 2,
      focusedWidth: 4,
      errorWidth: 3,
      focusedErrorWidth: 5,
    );
    final colors = ThemeData().colorScheme;
    expect(policy.side(colors, {}).width, 2);
    expect(policy.side(colors, {WidgetState.focused}).width, 4);
    expect(policy.side(colors, {WidgetState.error}).width, 3);
    expect(
      policy.side(colors, {WidgetState.focused, WidgetState.error}).width,
      5,
    );
    final disabled = policy.side(colors, {
      WidgetState.disabled,
      WidgetState.error,
      WidgetState.focused,
    });
    expect(disabled.width, 2);
    expect(disabled.color, colors.onSurface.withValues(alpha: .38));
    final other = policy.copyWith(kind: UiBorderKind.none, width: 4);
    expect(policy.lerp(other, .5).width, 3);
    expect(policy.lerp(other, .5).kind, UiBorderKind.none);
    expect(policy.lerp(null, .5), same(policy));
    expect(() => UiBorderTheme(width: -1), throwsAssertionError);
    expect(() => UiBorderTheme(focusedWidth: double.nan), throwsAssertionError);
  });

  for (final kind in UiBorderKind.values) {
    for (final scale in [1.0, 2.0, 3.0]) {
      for (final width in [360.0, 1280.0]) {
        testWidgets('painted $kind geometry and states at $width / $scale', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1.25;
          tester.view.physicalSize = Size(width * 1.25, 2400 * 1.25);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final form = GlobalKey<FormState>();
          final focus = FocusNode();
          final controller = TextEditingController();
          addTearDown(focus.dispose);
          addTearDown(controller.dispose);
          final theme = UiTheme.apply(
            ThemeData(),
            borders: UiBorderTheme(
              kind: kind,
              width: 3,
              focusedWidth: 5,
              errorWidth: 4,
              focusedErrorWidth: 6,
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Form(
                    key: form,
                    child: UiFormFields(
                      children: [
                        UiControls.formInput(
                          key: const Key('input'),
                          controller: controller,
                          focusNode: focus,
                          decoration: const InputDecoration(
                            hintText: 'Nombre',
                            helperText:
                                'Ayuda que debe conservar todo su espacio.',
                          ),
                          validator: (_) =>
                              'Revisa esta captura antes de continuar.',
                        ),
                        UiControls.select<String>(
                          key: const Key('select'),
                          initialValue: 'a',
                          items: const [
                            DropdownMenuItem(
                              value: 'a',
                              child: Text('Opción A'),
                            ),
                          ],
                          decoration: const InputDecoration(hintText: 'Tipo'),
                          onChanged: (_) {},
                        ),
                        UiControls.primary(
                          key: const Key('action'),
                          onPressed: () {},
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          final expected = (width < 600 ? 48 : 40) + (scale - 1) * 20;
          final initial = visibleField(tester, find.byKey(const Key('input')));
          expect(initial.height, closeTo(expected, .6));
          expect(
            visibleField(tester, find.byKey(const Key('select'))).height,
            closeTo(expected, .6),
          );
          final material = find
              .descendant(
                of: find.byKey(const Key('action')),
                matching: find.byType(Material),
              )
              .first;
          expect(tester.getSize(material).height, closeTo(expected, .6));
          focus.requestFocus();
          await tester.pumpAndSettle();
          expect(
            visibleField(tester, find.byKey(const Key('input'))).height,
            initial.height,
          );
          form.currentState!.validate();
          await tester.pumpAndSettle();
          expect(
            visibleField(tester, find.byKey(const Key('input'))).height,
            initial.height,
          );
          final error = tester.getRect(
            find.text('Revisa esta captura antes de continuar.'),
          );
          expect(
            error.bottom,
            lessThanOrEqualTo(
              tester.getTopLeft(find.byKey(const Key('select'))).dy,
            ),
          );
          expect(focus.hasFocus, isTrue);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('local input border overrides the application theme', (
    tester,
  ) async {
    const local = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.orange, width: 3),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(ThemeData()),
        home: Scaffold(
          body: UiControls.input(
            decoration: const InputDecoration(
              enabledBorder: local,
              focusedBorder: local,
            ),
          ),
        ),
      ),
    );
    final input = tester.widget<InputDecorator>(find.byType(InputDecorator));
    expect(input.decoration.enabledBorder, local);
    expect(input.decoration.focusedBorder, local);
  });

  testWidgets('hint styling survives while geometry remains centrally owned', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(
          ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              hintStyle: TextStyle(
                color: Colors.purple,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        home: Scaffold(
          body: UiControls.input(
            decoration: const InputDecoration(
              hintText: 'Custom hint',
              hintStyle: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 99,
                height: 9,
              ),
            ),
          ),
        ),
      ),
    );
    final hint = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration
        .hintStyle!;
    expect(hint.color, Colors.orange);
    expect(hint.fontStyle, FontStyle.italic);
    expect(hint.fontWeight, FontWeight.w700);
    expect(hint.fontSize, 14);
    expect(hint.height, 20 / 14);
  });

  testWidgets(
    'native elevated actions join shared geometry without losing shape',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(
            ThemeData(
              elevatedButtonTheme: const ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(BeveledRectangleBorder()),
                ),
              ),
            ),
          ),
          home: Scaffold(
            body: UiControlScope(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
            ),
          ),
        ),
      );
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ElevatedButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.shape, isA<BeveledRectangleBorder>());
      expect(
        tester
            .getSize(
              find
                  .descendant(
                    of: find.byType(ElevatedButton),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .height,
        40,
      );
    },
  );
}
