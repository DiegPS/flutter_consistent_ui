import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

/// A titled group inside an operational form.
class UiFormSection extends StatelessWidget {
  const UiFormSection({
    required this.title,
    required this.child,
    this.description,
    super.key,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (description case final description?) ...[
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
      const SizedBox(height: 12),
      child,
    ],
  );
}

/// A stable, naturally sized field grid: columns depend on available width and
/// text scale, never on device type. No intrinsic passes or fixed field heights.
/// The same Wrap/SizedBox tree survives breakpoint changes, preserving capture.
class UiFormGrid extends StatelessWidget {
  const UiFormGrid({required this.children, this.rowSpacing, super.key});

  final List<Widget> children;

  /// Fact groups can already own their bottom spacing; fields normally do not.
  final double? rowSpacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gap = UiThemeData.of(context).formSpacing;
      final config = UiThemeData.of(context);
      final scale =
          MediaQuery.textScalerOf(context).scale(config.fontSize) /
          config.fontSize;
      final twoColumns =
          constraints.hasBoundedWidth &&
          constraints.maxWidth >= 2 * config.minimumFieldWidth * scale + gap;
      final width = constraints.hasBoundedWidth
          ? (constraints.maxWidth - (twoColumns ? gap : 0)) /
                (twoColumns ? 2 : 1)
          : null;
      return Wrap(
        spacing: gap,
        runSpacing: rowSpacing ?? gap,
        children: [
          for (final child in children)
            SizedBox(
              key: child.key == null ? null : ValueKey<Key>(child.key!),
              width: width,
              child: child,
            ),
        ],
      );
    },
  );
}

/// Canonical vertical composition for form controls.
///
/// Every child keeps its intrinsic height, including floating labels, helper
/// text, counters and validation errors. The gap is added after that complete
/// height, so the next control can never overlap decoration content.
class UiFormFields extends StatelessWidget {
  const UiFormFields({
    required this.children,
    this.spacing,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  });

  final List<Widget> children;
  final double? spacing;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: mainAxisSize,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    children: [
      for (var index = 0; index < children.length; index++) ...[
        children[index],
        if (index < children.length - 1)
          SizedBox(height: spacing ?? UiThemeData.of(context).formSpacing),
      ],
    ],
  );
}
