import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

/// A scrollable dashboard with preformatted, consumer-owned statistics.
class DashboardRecipe extends StatelessWidget {
  const DashboardRecipe({required this.onOpen, super.key});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => UiPage(
    scrollable: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiMetricGrid(
          children: [
            for (final value in [('Registros', '24'), ('Pendientes', '6')])
              UiStatCard.adaptive(
                label: value.$1,
                value: value.$2,
                icon: Icons.assignment_outlined,
                onTap: onOpen,
              ),
          ],
        ),
        const SizedBox(height: 24),
        UiSplitView(
          primary: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: UiControls.secondary(
                onPressed: onOpen,
                child: const Text('Abrir registros'),
              ),
            ),
          ),
          secondary: const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Panel secundario'),
            ),
          ),
        ),
      ],
    ),
  );
}

@Preview(name: 'Recipe / dashboard / compact', size: Size(390, 844))
@Preview(name: 'Recipe / dashboard / desktop', size: Size(1280, 900))
Widget dashboardRecipePreview() => MaterialApp(
  theme: UiTheme.apply(ThemeData()),
  home: Scaffold(body: DashboardRecipe(onOpen: () {})),
);
