import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

/// Responsive, sustainable card grid that behaves like CSS Grid (auto-fit / stretch).
///
/// If [itemHeight] is null, cards in the same row dynamically match the height of
/// the tallest card in that row using [IntrinsicHeight], ensuring no blank gaps
/// or overflow.
class UiMetricGrid extends StatelessWidget {
  const UiMetricGrid({
    required this.children,
    this.itemHeight,
    this.minimumItemWidth = 240,
    this.maximumColumns = 4,
    this.spacing = 16,
    super.key,
  });

  final List<Widget> children;
  final double? itemHeight;
  final double minimumItemWidth;
  final int maximumColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final font = UiThemeData.of(context).fontSize;
      final scale = MediaQuery.textScalerOf(context).scale(font) / font;
      final effectiveMinimum = minimumItemWidth * scale;
      final fourColumnMinimum = effectiveMinimum * 4 + spacing * 3;
      final twoColumnMinimum = effectiveMinimum * 2 + spacing;
      final columns = maximumColumns >= 4 && availableWidth >= fourColumnMinimum
          ? 4
          : maximumColumns >= 2 && availableWidth >= twoColumnMinimum
          ? 2
          : 1;

      if (columns == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              if (itemHeight != null)
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: itemHeight!),
                  child: children[i],
                )
              else
                children[i],
            ],
          ],
        );
      }

      final rows = <List<Widget>>[];
      for (var i = 0; i < children.length; i += columns) {
        rows.add(
          children.sublist(
            i,
            (i + columns > children.length) ? children.length : i + columns,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: spacing),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) SizedBox(width: spacing),
                    Expanded(
                      child: c < rows[r].length
                          ? (itemHeight != null
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: itemHeight!,
                                    ),
                                    child: rows[r][c],
                                  )
                                : rows[r][c])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}
