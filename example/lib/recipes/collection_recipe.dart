import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

/// A bounded, searchable collection with real callbacks and lazy rows.
class CollectionRecipe extends StatefulWidget {
  const CollectionRecipe({
    required this.onCreate,
    required this.onOpen,
    super.key,
  });
  final VoidCallback onCreate;
  final ValueChanged<String> onOpen;
  @override
  State<CollectionRecipe> createState() => _CollectionRecipeState();
}

class _CollectionRecipeState extends State<CollectionRecipe> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final rows = ['Alpha', 'Beta', 'Gamma']
        .where((value) => value.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return UiCollectionPage(
      search: UiSearchField(
        hintText: 'Buscar',
        onChanged: (value) => setState(() => query = value),
      ),
      actions: [
        UiControls.primaryIcon(
          onPressed: widget.onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Crear'),
        ),
      ],
      content: rows.isEmpty
          ? const UiEmptyState(
              icon: Icons.search_off,
              title: 'Sin coincidencias',
            )
          : UiCollectionList.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) => UiCollectionItem(
                title: Text(rows[index]),
                leadingIcon: Icons.description_outlined,
                badges: const [UiCollectionBadge(label: 'Ejemplo')],
                onOpen: () => widget.onOpen(rows[index]),
              ),
            ),
    );
  }
}
