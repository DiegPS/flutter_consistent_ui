import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/ui_theme.dart';

/// Responsive, sustainable card grid that behaves like CSS Grid (auto-fit / stretch).
///
/// If [itemHeight] is null, cards in the same row dynamically match the height of
/// the tallest card in that row using a bounded two-pass layout, ensuring no blank gaps
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
            _EqualHeightRow(
              columns: columns,
              spacing: spacing,
              minimumHeight: itemHeight ?? 0,
              children: rows[r],
            ),
          ],
        ],
      );
    },
  );
}

class _EqualHeightRow extends MultiChildRenderObjectWidget {
  const _EqualHeightRow({
    required this.columns,
    required this.spacing,
    required this.minimumHeight,
    required super.children,
  });
  final int columns;
  final double spacing, minimumHeight;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(
        columns,
        spacing,
        minimumHeight,
        Directionality.of(context),
      );
  @override
  void updateRenderObject(
    BuildContext context,
    _RenderEqualHeightRow renderObject,
  ) => renderObject.configure(
    columns,
    spacing,
    minimumHeight,
    Directionality.of(context),
  );
}

class _GridData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridData> {
  _RenderEqualHeightRow(
    this.columns,
    this.spacing,
    this.minimumHeight,
    this.direction,
  );
  int columns;
  double spacing, minimumHeight;
  TextDirection direction;

  void configure(
    int nextColumns,
    double nextSpacing,
    double nextMinimum,
    TextDirection nextDirection,
  ) {
    if (columns == nextColumns &&
        spacing == nextSpacing &&
        minimumHeight == nextMinimum &&
        direction == nextDirection) {
      return;
    }
    columns = nextColumns;
    spacing = nextSpacing;
    minimumHeight = nextMinimum;
    direction = nextDirection;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridData) child.parentData = _GridData();
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth, 'UiMetricGrid requires bounded width.');
    final width = constraints.maxWidth;
    final itemWidth = ((width - spacing * (columns - 1)) / columns).clamp(
      0.0,
      double.infinity,
    );
    var height = minimumHeight;
    var child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: itemWidth),
        parentUsesSize: true,
      );
      if (child.size.height > height) height = child.size.height;
      child = (child.parentData! as _GridData).nextSibling;
    }
    child = firstChild;
    var index = 0;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: itemWidth, height: height),
        parentUsesSize: true,
      );
      final data = child.parentData! as _GridData;
      final x = index * (itemWidth + spacing);
      data.offset = Offset(
        direction == TextDirection.ltr ? x : width - itemWidth - x,
        0,
      );
      index++;
      child = data.nextSibling;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
