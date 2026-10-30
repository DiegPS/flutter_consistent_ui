import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:consistent_ui_example/main.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('ExampleInter');
    font.addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    font.addFont(rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final width in [390.0, 1280.0]) {
    testWidgets('consumer example validates and changes identity at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ConsistentUiExample());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/example-${width.toInt()}.png'),
      );
      await tester.tap(find.byTooltip('Cambiar identidad y medidas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nuevo registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Captura el nombre.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('name')),
        'Proyecto independiente',
      );
      await tester.tap(find.text('Probar aviso sobre el formulario'));
      await tester.pumpAndSettle();
      expect(
        find.text('El aviso está encima del diálogo, no detrás.').hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Cerrar aviso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Validación correcta. No se envían datos.').hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Formulario adaptable'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
