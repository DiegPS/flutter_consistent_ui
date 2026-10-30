import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consistent_ui_example/recipes/collection_recipe.dart';
import 'package:consistent_ui_example/recipes/form_recipe.dart';
import 'package:consistent_ui_example/recipes/dashboard_recipe.dart';
import 'package:consistent_ui_example/recipes/main.dart';

void main() {
  testWidgets(
    'recipe runner opens a fullscreen form and surfaces validation above it',
    (tester) async {
      await tester.pumpWidget(const RecipeExample());
      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Runner record');
      await tester.tap(find.text('Validar captura'));
      await tester.pumpAndSettle();
      expect(
        find.text('Validated: Runner record').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [360.0, 1280.0]) {
    testWidgets('compiled recipes search, open, validate and adapt at $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1100);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var creates = 0;
      String? opened, validated;
      Widget app(Widget child) => MaterialApp(
        theme: UiTheme.apply(ThemeData()),
        home: Scaffold(body: child),
      );
      await tester.pumpWidget(
        app(
          CollectionRecipe(
            onCreate: () => creates++,
            onOpen: (value) => opened = value,
          ),
        ),
      );
      await tester.tap(find.text('Crear'));
      expect(creates, 1);
      await tester.enterText(find.byType(TextField), 'beta');
      await tester.pump();
      expect(find.text('Alpha'), findsNothing);
      await tester.tap(find.text('Beta'));
      expect(opened, 'Beta');
      await tester.enterText(find.byType(TextField), 'not found');
      await tester.pump();
      expect(find.text('Sin coincidencias'), findsOneWidget);
      await tester.pumpWidget(
        app(FormRecipe(onValidated: (value) => validated = value)),
      );
      await tester.tap(find.text('Validar captura'));
      await tester.pump();
      expect(find.text('Captura el nombre.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        '  Actual name  ',
      );
      await tester.tap(find.text('Validar captura'));
      expect(validated, 'Actual name');
      await tester.pumpWidget(app(DashboardRecipe(onOpen: () => creates++)));
      await tester.tap(find.text('Abrir registros'));
      expect(creates, 2);
      expect(tester.takeException(), isNull);
    });
  }
}
