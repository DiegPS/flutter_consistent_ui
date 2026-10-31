import 'package:flutter/material.dart';

import 'ui_theme.dart';
import 'ui_surface_style.dart';

/// A normal or inverse Material panel with coherent inherited foregrounds.
///
/// Rebinds text, icons and button colors, including explicit button colors
/// inherited from the outer theme. Geometry, fonts and theme extensions remain
/// unchanged. Use a Builder below this widget when resolving local ThemeData.
/// Explicit colors on descendants remain the consumer's responsibility.
class UiSurface extends StatelessWidget {
  const UiSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.style,
    super.key,
  }) : inverse = false;
  const UiSurface.inverse({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.style,
    super.key,
  }) : inverse = true;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final UiSurfaceStyle? style;

  /// Whether the panel uses the outer scheme's inverse surface pair.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final appearance = UiSurfaceStyle.of(context).merge(style);
    final colors = base.colorScheme;
    final background = inverse
        ? colors.inverseSurface
        : colors.surfaceContainerLowest;
    final foreground = inverse ? colors.onInverseSurface : colors.onSurface;
    final local = colors.copyWith(
      surface: background,
      onSurface: foreground,
      onSurfaceVariant: foreground,
      surfaceContainerLowest: background,
    );
    final neutralForeground = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled)
          ? foreground.withValues(alpha: .65)
          : foreground,
    );
    ButtonStyle neutral(ButtonStyle? original) =>
        (original ?? const ButtonStyle()).copyWith(
          foregroundColor: neutralForeground,
          iconColor: neutralForeground,
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStatePropertyAll(
            foreground.withValues(alpha: .1),
          ),
        );
    // Null-valued properties deliberately restore native defaults: primary and
    // tonal FilledButtons use different scheme pairs and must not share a fixed
    // foreground/background inherited from the parent product theme.
    ButtonStyle native(ButtonStyle? original) =>
        (original ?? const ButtonStyle()).copyWith(
          foregroundColor: const WidgetStatePropertyAll<Color?>(null),
          backgroundColor: const WidgetStatePropertyAll<Color?>(null),
          iconColor: const WidgetStatePropertyAll<Color?>(null),
          overlayColor: const WidgetStatePropertyAll<Color?>(null),
        );
    final theme = base.copyWith(
      colorScheme: local,
      textTheme: base.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      iconTheme: base.iconTheme.copyWith(color: foreground),
      filledButtonTheme: FilledButtonThemeData(
        style: native(base.filledButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: native(base.elevatedButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: neutral(base.outlinedButtonTheme.style).copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) =>
                (base.outlinedButtonTheme.style?.side?.resolve(states) ??
                        const BorderSide())
                    .copyWith(
                      color: foreground.withValues(
                        alpha: states.contains(WidgetState.disabled) ? .25 : .6,
                      ),
                    ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: neutral(base.textButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: native(base.iconButtonTheme.style),
      ),
    );
    return Theme(
      data: theme,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: Material(
            color: background,
            elevation: appearance.elevation ?? 0,
            shadowColor: appearance.shadowColor,
            surfaceTintColor: Colors.transparent,
            clipBehavior: appearance.clipBehavior ?? Clip.antiAlias,
            shape:
                appearance.shape ??
                RoundedRectangleBorder(
                  side: appearance.border ?? BorderSide.none,
                  borderRadius: BorderRadius.circular(
                    UiThemeData.of(context).panelRadius,
                  ),
                ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
