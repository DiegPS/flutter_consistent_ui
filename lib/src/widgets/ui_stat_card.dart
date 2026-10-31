import 'package:flutter/material.dart';

import 'ui_metric_card.dart';
import '../theme/ui_theme.dart';

/// A vertical dashboard statistic with a natural height and an optional action.
/// Values are formatted by the consumer; this widget never invents a trend.
class UiStatCard extends StatelessWidget {
  const UiStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.category,
    this.description,
    this.accent,
    this.onTap,
    this.compact = false,
    super.key,
  }) : _adaptive = false,
       _minimumExpandedWidth = 240;

  /// Creates a statistic that chooses its composition from available space.
  ///
  /// Uses the horizontal composition in compact windows or when the local
  /// width is below [minimumExpandedWidth] adjusted for text scaling.
  /// Requires bounded horizontal constraints. Use [UiStatCard.new] to force
  /// either composition explicitly without changing existing consumers.
  const UiStatCard.adaptive({
    required this.label,
    required this.value,
    required this.icon,
    this.category,
    this.description,
    this.accent,
    this.onTap,
    double minimumExpandedWidth = 240,
    super.key,
  }) : assert(minimumExpandedWidth > 0),
       compact = false,
       _adaptive = true,
       _minimumExpandedWidth = minimumExpandedWidth;

  final String label, value;
  final IconData icon;
  final String? category, description;
  final Color? accent;
  final VoidCallback? onTap;

  /// Whether the explicit constructor uses the horizontal composition.
  final bool compact;
  final bool _adaptive;
  final double _minimumExpandedWidth;

  @override
  Widget build(BuildContext context) {
    if (_adaptive) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final config = UiThemeData.of(context);
          final scale =
              MediaQuery.textScalerOf(context).scale(config.fontSize) /
              config.fontSize;
          final horizontal =
              MediaQuery.sizeOf(context).width < config.compactBreakpoint ||
              constraints.maxWidth < _minimumExpandedWidth * scale;
          return _content(context, horizontal);
        },
      );
    }
    return _content(context, compact);
  }

  Widget _content(BuildContext context, bool compact) {
    if (compact) {
      return UiMetricCard(
        label: label,
        value: value,
        icon: icon,
        accent: accent,
        onTap: onTap,
      );
    }
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    return Card(
      clipBehavior: Theme.of(context).cardTheme.clipBehavior ?? Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(icon, size: 20, color: color),
                    ),
                  ),
                  if (category != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category!,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(label, style: theme.textTheme.titleSmall),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(description!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
