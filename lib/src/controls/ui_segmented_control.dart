import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ui_control_metrics.dart';

class UiSegment<T> {
  const UiSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class UiSegmentedControl<T> extends StatelessWidget {
  const UiSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.disabled = false,
    super.key,
  });

  final List<UiSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final segment in segments) ...[
              _SegmentItem<T>(
                segment: segment,
                isSelected: segment.value == selected,
                onTap:
                    (disabled || segment.value == selected || onChanged == null)
                    ? null
                    : () => onChanged!(segment.value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentItem<T> extends StatelessWidget {
  const _SegmentItem({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final UiSegment<T> segment;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? colors.surfaceContainerLowest : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: math.max(
                0,
                (UiControlMetrics.height(context) -
                        8 -
                        UiControlMetrics.textHeight(context)) /
                    2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  Icon(
                    segment.icon,
                    size: 15,
                    color: isSelected
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  segment.label,
                  style: UiControlMetrics.textStyle(context).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
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
