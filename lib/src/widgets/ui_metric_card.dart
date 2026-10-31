import 'package:flutter/material.dart';

import '../layout/ui_layout.dart';
import '../theme/ui_semantic_colors.dart';
import '../theme/ui_typography.dart';
import '../theme/ui_theme.dart';
import 'ui_animated_counter.dart';
import 'ui_sparkline.dart';

class UiMetricCard extends StatelessWidget {
  const UiMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.accent,
    this.deltaPercent,
    this.sparklineData,
    this.animated = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accent;
  final double? deltaPercent;
  final List<double>? sparklineData;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final baseAccent = accent ?? colors.primary;

    final layout = UiLayout.fromSize(
      MediaQuery.sizeOf(context),
      theme: UiThemeData.of(context),
    );
    final showSparkline =
        sparklineData != null && sparklineData!.isNotEmpty && !layout.isCompact;

    return Card(
      clipBehavior: Theme.of(context).cardTheme.clipBehavior ?? Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: baseAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: baseAccent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        animated
                            ? UiCountUpText(
                                value: value,
                                style: TextStyle(
                                  fontSize: UiTypography.metric,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: colors.onSurface,
                                ),
                              )
                            : Text(
                                value,
                                style: TextStyle(
                                  fontSize: UiTypography.metric,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: colors.onSurface,
                                ),
                              ),
                        if (deltaPercent != null) ...[
                          _buildDeltaBadge(context, deltaPercent!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: UiTypography.caption,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSparkline) ...[
                const SizedBox(width: 6),
                UiSparkline(
                  data: sparklineData!,
                  color: baseAccent,
                  height: 24,
                  width: 46,
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeltaBadge(BuildContext context, double delta) {
    final colors = Theme.of(context).colorScheme;
    final semantic = UiSemanticColors.of(context);
    final isPositive = delta >= 0;
    final bgColor = isPositive
        ? semantic.success.container
        : colors.errorContainer;
    final fgColor = isPositive
        ? semantic.success.onContainer
        : colors.onErrorContainer;
    final icon = isPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final prefix = isPositive ? '+' : '';
    final formattedDelta = '$prefix${delta.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fgColor),
          const SizedBox(width: 2),
          Text(
            formattedDelta,
            style: TextStyle(
              fontSize: UiTypography.badge,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
