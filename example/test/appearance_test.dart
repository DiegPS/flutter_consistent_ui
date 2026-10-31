import 'package:consistent_ui_example/appearance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'appearance example validates and retains drafts through theme changes',
    (tester) async {
      await tester.pumpWidget(const AppearanceExample());
      await tester.ensureVisible(find.text('Validar'));
      await tester.tap(find.text('Validar'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un nombre.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Persistent draft');
      await tester.scrollUntilVisible(
        find.text('Subrayado'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Subrayado'));
      await tester.pumpAndSettle();
      var field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, 'Persistent draft');
      var theme = Theme.of(tester.element(find.byType(TextFormField)));
      expect(theme.inputDecorationTheme.border, isA<UnderlineInputBorder>());
      await tester.tap(find.text('Tema oscuro'));
      await tester.pumpAndSettle();
      theme = Theme.of(tester.element(find.byType(TextFormField)));
      expect(theme.brightness, Brightness.dark);
      await tester.tap(find.text('Borde de superficies'));
      await tester.pumpAndSettle();
      expect(theme.extension<UiSurfaceStyle>(), isNotNull);
      field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, 'Persistent draft');
      expect(tester.takeException(), isNull);
    },
  );
}
