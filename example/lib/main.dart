import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() => runApp(const ConsistentUiExample());

@Preview(name: 'Independent UI package · desktop', size: Size(1280, 900))
@Preview(name: 'Independent UI package · compact', size: Size(390, 844))
Widget consistentUiPreview() => const ConsistentUiExample();

class ConsistentUiExample extends StatefulWidget {
  const ConsistentUiExample({super.key});
  @override
  State<ConsistentUiExample> createState() => _ExampleState();
}

class _ExampleState extends State<ConsistentUiExample> {
  final notices = UiNoticeController();
  final search = TextEditingController();
  bool alternate = false;
  @override
  void dispose() {
    notices.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: UiTheme.apply(
      ThemeData(
        useMaterial3: true,
        fontFamily: 'ExampleInter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: alternate ? Colors.teal : Colors.indigo,
        ),
      ),
      geometry: alternate
          ? const UiThemeData(
              controlHeight: 44,
              compactControlHeight: 52,
              controlRadius: 12,
            )
          : const UiThemeData(),
    ),
    builder: (context, child) => UiNoticeHost(
      controller: notices,
      closeLabel: 'Cerrar aviso',
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Consistent UI'),
          actions: [
            IconButton(
              tooltip: 'Cambiar identidad y medidas',
              onPressed: () => setState(() => alternate = !alternate),
              icon: const Icon(Icons.palette_outlined),
            ),
            IconButton(
              tooltip: 'Aviso global',
              onPressed: () => notices.show(
                const UiNotice(message: 'Este aviso no depende de un backend.'),
              ),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        body: UiCollectionPage(
          search: UiSearchField(
            controller: search,
            hintText: 'Buscar en el ejemplo',
            submitLabel: 'Buscar',
            onSubmitted: (_) {},
          ),
          actions: [
            UiControls.primaryIcon(
              onPressed: () => showUiFullscreenDialog<void>(
                context: context,
                builder: (dialogContext) => _Editor(notices: notices),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo registro'),
            ),
          ],
          content: ListView(
            children: [
              UiMetricGrid(
                children: [
                  for (final item in [
                    ('Registros activos', '24'),
                    ('Por revisar', '6'),
                    ('Completados', '18'),
                    ('Total', r'$125,400.00'),
                  ])
                    UiMetricCard(
                      label: item.$1,
                      value: item.$2,
                      icon: Icons.analytics_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              UiCollectionList(
                children: [
                  for (var i = 0; i < 5; i++)
                    UiCollectionItem(
                      title: Text('Registro ${i + 1}'),
                      leadingIcon: Icons.inventory_2_outlined,
                      badges: const [
                        UiCollectionBadge(
                          label: 'Activo',
                          tone: UiCollectionBadgeTone.success,
                        ),
                      ],
                      details: const [
                        UiCollectionDetail(
                          icon: Icons.info_outline,
                          text: 'Datos de ejemplo; cada proyecto utiliza sus propios modelos.',
                        ),
                      ],
                      onOpen: () => showUiFullscreenDialog<void>(
                        context: context,
                        builder: (_) => _Editor(notices: notices),
                      ),
                    ),
                ],
              ),
            ],
          ),
          footer: UiPagination(
            page: 0,
            pageCount: 1,
            label: '5 resultados · Ejemplo sin servidor',
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}

class _Editor extends StatefulWidget {
  const _Editor({required this.notices});
  final UiNoticeController notices;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiFullscreenDialog(
    title: const Text('Formulario adaptable'),
    closeLabel: 'Cerrar',
    description: 'Redimensiona la ventana o cambia la escala de texto: la captura se conserva.',
    content: Form(
      key: form,
      child: UiFormFields(
        children: [
          UiFormSection(
            title: 'Identificación',
            description: 'Campos de una línea, selectores y botones comparten su borde visible.',
            child: UiFormGrid(
              children: [
                UiControls.formInput(
                  key: const Key('name'),
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    helperText: 'La ayuda forma parte de la altura natural.',
                  ),
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Captura el nombre.' : null,
                ),
                UiControls.select<String>(
                  initialValue: 'active',
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Activo')),
                  ],
                  onChanged: (_) {},
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          UiControls.input(
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Este campo puede crecer sin recortar su contenido.',
            ),
          ),
          UiControls.secondary(
            onPressed: () => widget.notices.show(
              const UiNotice(
                message: 'El aviso está encima del diálogo, no detrás.',
                isError: true,
              ),
            ),
            child: const Text('Probar aviso sobre el formulario'),
          ),
        ],
      ),
    ),
    actions: [
      UiControls.quiet(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      UiControls.primary(
        onPressed: () {
          if (form.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Validación correcta. No se envían datos.'),
              ),
            );
          }
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}
