import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() => runApp(const AppearanceExample());

@Preview(name: 'Appearance policies', size: Size(760, 900))
@Preview(
  name: 'Appearance · scaled',
  size: Size(390, 1000),
  textScaleFactor: 1.5,
)
Widget appearancePreview() => const AppearanceExample();

/// An executable customization example without networking or native plugins.
class AppearanceExample extends StatefulWidget {
  const AppearanceExample({super.key});
  @override
  State<AppearanceExample> createState() => _AppearanceExampleState();
}

class _AppearanceExampleState extends State<AppearanceExample> {
  final _form = GlobalKey<FormState>();
  final _text = TextEditingController();
  UiBorderKind _kind = UiBorderKind.outline;
  bool _dark = false, _bordered = true, _raised = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: _dark ? Brightness.dark : Brightness.light,
    );
    final theme = UiTheme.apply(
      ThemeData(colorScheme: colors),
      borders: UiBorderTheme(kind: _kind, focusedWidth: 3),
      surfaces: UiSurfaceStyle(
        border: _bordered
            ? BorderSide(color: colors.outlineVariant)
            : BorderSide.none,
        elevation: _raised ? 3 : 0,
      ),
    );
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Personalización sin copiar widgets')),
        body: UiControlScope(
          child: UiPage(
            child: ListView(
              children: [
                const Text(
                  'Los estilos explícitos tienen prioridad. La política completa lo que falta.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (kind, label) in [
                      (UiBorderKind.outline, 'Contorno'),
                      (UiBorderKind.underline, 'Subrayado'),
                      (UiBorderKind.none, 'Sin borde'),
                    ])
                      UiControls.secondary(
                        onPressed: () => setState(() => _kind = kind),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            _kind == kind ? colors.primaryContainer : null,
                          ),
                        ),
                        child: Text(label),
                      ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Tema oscuro'),
                  value: _dark,
                  onChanged: (value) => setState(() => _dark = value),
                ),
                SwitchListTile(
                  title: const Text('Borde de superficies'),
                  value: _bordered,
                  onChanged: (value) => setState(() => _bordered = value),
                ),
                SwitchListTile(
                  title: const Text('Elevación'),
                  value: _raised,
                  onChanged: (value) => setState(() => _raised = value),
                ),
                UiSurface(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: UiFormFields(
                      children: [
                        UiControls.formInput(
                          controller: _text,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            helperText: 'La captura se conserva al cambiar la apariencia.',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Escribe un nombre.'
                              : null,
                        ),
                        UiControls.select<String>(
                          initialValue: 'a',
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: const [
                            DropdownMenuItem(
                              value: 'a',
                              child: Text('Opción A'),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                        UiControls.primary(
                          onPressed: () => _form.currentState!.validate(),
                          child: const Text('Validar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                UiSurface.inverse(
                  padding: const EdgeInsets.all(20),
                  child: UiFormFields(
                    children: [
                      const Text(
                        'Superficie inversa: mismo estilo, colores legibles.',
                      ),
                      UiControls.secondary(
                        onPressed: () {},
                        child: const Text('Acción inversa'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
