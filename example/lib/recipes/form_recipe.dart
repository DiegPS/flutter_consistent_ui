import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

/// A validated fullscreen capture whose consumer owns persistence and success.
class FormRecipe extends StatefulWidget {
  const FormRecipe({required this.onValidated, super.key});
  final ValueChanged<String> onValidated;
  @override
  State<FormRecipe> createState() => _FormRecipeState();
}

class _FormRecipeState extends State<FormRecipe> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiFullscreenDialog(
    title: const Text('Nuevo registro'),
    closeLabel: 'Cerrar',
    description:
        'Validar no significa que el servidor haya guardado la captura.',
    content: Form(
      key: form,
      child: UiFormFields(
        children: [
          UiControls.formInput(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nombre *',
              helperText: 'Nombre que identifica el registro.',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Captura el nombre.'
                : null,
          ),
          UiFormGrid(
            children: [
              UiControls.formInput(
                decoration: const InputDecoration(
                  labelText: 'Referencia (opcional)',
                ),
              ),
              UiControls.select<String>(
                initialValue: 'active',
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Activo')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      UiControls.primary(
        onPressed: () {
          if (form.currentState!.validate()) {
            widget.onValidated(name.text.trim());
          }
        },
        child: const Text('Validar captura'),
      ),
    ],
  );
}
