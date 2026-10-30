import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

import 'helpers/geometry.dart';

void main() {
  testWidgets('keyed fields retain native text and focus when reordered', (
    tester,
  ) async {
    var reverse = false;
    late StateSetter update;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(ThemeData(useMaterial3: true)),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              final fields = [
                UiControls.input(key: const Key('first'), focusNode: focus),
                UiControls.input(key: const Key('second')),
              ];
              return Column(
                children: reverse ? fields.reversed.toList() : fields,
              );
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('first')), 'Conservar captura');
    expect(focus.hasFocus, isTrue);
    update(() => reverse = true);
    await tester.pump();
    expect(find.text('Conservar captura'), findsOneWidget);
    expect(focus.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 1200.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('form borders and actions agree at $width / $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = TextEditingController(text: 'Unidad 42');
        addTearDown(controller.dispose);
        var pressed = 0;
        var selected = '';
        var changed = '';
        late double expectedHeight;
        final fields = [
          UiControls.input(
            key: const Key('plain'),
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              helperText: 'Texto de ayuda',
            ),
            onChanged: (value) => changed = value,
          ),
          UiControls.formInput(
            key: const Key('form'),
            initialValue: '42',
            decoration: const InputDecoration(
              labelText: 'Kilometraje',
              prefixIcon: Icon(Icons.speed),
            ),
          ),
          UiControls.select<String>(
            key: const Key('select'),
            initialValue: 'a',
            items: const [
              DropdownMenuItem(value: 'a', child: Text('Activo')),
              DropdownMenuItem(value: 'b', child: Text('Baja')),
            ],
            decoration: const InputDecoration(labelText: 'Estado'),
            onChanged: (value) => selected = value!,
          ),
        ];
        final actions = [
          UiControls.primary(
            onPressed: () => pressed++,
            child: const Text('Guardar'),
          ),
          UiControls.primaryIcon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Crear'),
          ),
          UiControls.tonal(onPressed: () {}, child: const Text('Consultar')),
          UiControls.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.check),
            label: const Text('Aplicar'),
          ),
          UiControls.secondary(onPressed: () {}, child: const Text('Cancelar')),
          UiControls.secondaryIcon(
            onPressed: () {},
            icon: const Icon(Icons.upload),
            label: const Text('Adjuntar'),
          ),
          UiControls.quiet(onPressed: null, child: const Text('Inactivo')),
          UiControls.quietIcon(
            onPressed: () {},
            icon: const Icon(Icons.help_outline),
            label: const Text('Ayuda'),
          ),
        ];
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData(useMaterial3: true)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  expectedHeight = UiControlMetrics.height(context);
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: UiFormFields(children: [...fields, ...actions]),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        for (final key in ['plain', 'form', 'select']) {
          expect(
            visibleField(tester, find.byKey(Key(key))).height,
            closeTo(expectedHeight, 0.6),
            reason: key,
          );
        }
        for (final action
            in find
                .byWidgetPredicate((w) => w is ButtonStyleButton)
                .evaluate()) {
          final material = find
              .descendant(
                of: find.byWidget(action.widget),
                matching: find.byType(Material),
              )
              .first;
          expect(
            tester.getSize(material).height,
            closeTo(expectedHeight, 0.6),
            reason: action.widget.runtimeType.toString(),
          );
        }
        await tester.enterText(find.byKey(const Key('plain')), 'Actualizada');
        expect(changed, 'Actualizada');
        expect(controller.text, 'Actualizada');
        await tester.tap(find.text('Guardar'));
        expect(pressed, 1);
        await tester.tap(find.byKey(const Key('select')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Baja').last);
        await tester.pumpAndSettle();
        expect(selected, 'b');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('long action labels grow instead of clipping enlarged text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.apply(ThemeData(useMaterial3: true)),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: SizedBox(
              width: 200,
              child: UiControls.primary(
                onPressed: () {},
                child: const Text('Guardar todos los cambios del formulario'),
              ),
            ),
          ),
        ),
      ),
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
      greaterThan(68),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'multiline, helpers and validation retain their full natural height',
    (tester) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.apply(ThemeData(useMaterial3: true)),
          home: Scaffold(
            body: Form(
              key: form,
              child: UiFormFields(
                children: [
                  UiControls.formInput(
                    key: const Key('notes'),
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Evidencia',
                      helperText: 'Describe lo que se observa',
                    ),
                    validator: (_) => 'Agrega una descripción',
                  ),
                  UiControls.input(
                    key: const Key('next'),
                    decoration: const InputDecoration(labelText: 'Siguiente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final before = visibleField(tester, find.byKey(const Key('notes')));
      expect(before.height, greaterThan(40));
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      final error = tester.getRect(find.text('Agrega una descripción'));
      final next = visibleField(tester, find.byKey(const Key('next')));
      expect(next.top, greaterThan(error.bottom + 10));
      expect(
        visibleField(tester, find.byKey(const Key('notes'))).height,
        before.height,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
