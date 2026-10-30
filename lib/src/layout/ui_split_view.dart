import 'package:flutter/material.dart';

/// Two natural-height columns that stack when their allocated width is narrow.
/// Keeps the same children mounted when resizing, preserving form state.
class UiSplitView extends StatelessWidget {
  const UiSplitView({
    required this.primary,
    required this.secondary,
    this.breakpoint = 1000,
    this.primaryFraction = .62,
    this.spacing = 24,
    super.key,
  }) : assert(primaryFraction > 0 && primaryFraction < 1),
       assert(breakpoint > 0),
       assert(spacing >= 0);
  final Widget primary, secondary;
  final double breakpoint, primaryFraction, spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final scaledBreakpoint =
          breakpoint * MediaQuery.textScalerOf(context).scale(14) / 14;
      final wide = size.maxWidth >= scaledBreakpoint;
      final available = size.maxWidth - spacing;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          SizedBox(
            width: wide ? available * primaryFraction : size.maxWidth,
            child: primary,
          ),
          SizedBox(
            width: wide ? available * (1 - primaryFraction) : size.maxWidth,
            child: secondary,
          ),
        ],
      );
    },
  );
}
