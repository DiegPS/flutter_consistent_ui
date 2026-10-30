import 'package:flutter/material.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

import 'collection_recipe.dart';
import 'dashboard_recipe.dart';
import 'form_recipe.dart';

void main() => runApp(const RecipeExample());

/// Runs one recipe locally without hosting a catalog or requiring an API.
class RecipeExample extends StatelessWidget {
  const RecipeExample({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: UiTheme.apply(ThemeData(useMaterial3: true)),
    home: Builder(
      builder: (context) {
        void report(String value) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(value)));
        const recipe = String.fromEnvironment(
          'UI_RECIPE',
          defaultValue: 'collection',
        );
        return Scaffold(
          appBar: AppBar(title: Text('Recipe · $recipe')),
          body: switch (recipe) {
            'collection' => CollectionRecipe(
              onOpen: (value) => report('Selected: $value'),
              onCreate: () => showUiFullscreenDialog<void>(
                context: context,
                builder: (dialogContext) => FormRecipe(
                  onValidated: (value) => ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('Validated: $value'))),
                ),
              ),
            ),
            'form' => FormRecipe(
              onValidated: (value) => report('Validated: $value'),
            ),
            'dashboard' => DashboardRecipe(
              onOpen: () => report('Open callback received'),
            ),
            _ => const Center(
              child: Text('UI_RECIPE: collection | form | dashboard'),
            ),
          },
        );
      },
    ),
  );
}
