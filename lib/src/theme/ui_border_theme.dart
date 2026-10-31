import 'package:flutter/material.dart';

/// Field shape used when the application has not supplied an explicit border.
enum UiBorderKind { outline, underline, none }

/// Defaults for painted field borders and native outlined-button sides.
///
/// Explicit per-widget and application-theme borders take precedence. This
/// policy does not set field heights, padding, fonts or application colors.
@immutable
class UiBorderTheme extends ThemeExtension<UiBorderTheme> {
  const UiBorderTheme({
    this.kind = UiBorderKind.outline,
    this.width = 1,
    this.focusedWidth = 1.5,
    this.errorWidth = 1,
    this.focusedErrorWidth = 1.5,
  }) : assert(width >= 0 && width < double.infinity),
       assert(focusedWidth >= 0 && focusedWidth < double.infinity),
       assert(errorWidth >= 0 && errorWidth < double.infinity),
       assert(focusedErrorWidth >= 0 && focusedErrorWidth < double.infinity);

  final UiBorderKind kind;
  final double width, focusedWidth, errorWidth, focusedErrorWidth;

  static UiBorderTheme of(BuildContext context) =>
      Theme.of(context).extension<UiBorderTheme>() ?? const UiBorderTheme();

  /// Resolves disabled, error and focus states using the product's scheme.
  BorderSide side(ColorScheme colors, Set<WidgetState> states) {
    final enabled = !states.contains(WidgetState.disabled);
    final focused = states.contains(WidgetState.focused);
    final error = states.contains(WidgetState.error);
    return BorderSide(
      color: !enabled
          ? colors.onSurface.withValues(alpha: .38)
          : error
          ? colors.error
          : focused
          ? colors.primary
          : colors.outline,
      width: !enabled
          ? width
          : error
          ? (focused ? focusedErrorWidth : errorWidth)
          : (focused ? focusedWidth : width),
    );
  }

  /// Builds only a missing border; application-provided shapes remain intact.
  InputBorder inputBorder(double radius, BorderSide side) => switch (kind) {
    UiBorderKind.outline => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: side,
    ),
    UiBorderKind.underline => UnderlineInputBorder(borderSide: side),
    UiBorderKind.none => InputBorder.none,
  };

  @override
  UiBorderTheme copyWith({
    UiBorderKind? kind,
    double? width,
    double? focusedWidth,
    double? errorWidth,
    double? focusedErrorWidth,
  }) => UiBorderTheme(
    kind: kind ?? this.kind,
    width: width ?? this.width,
    focusedWidth: focusedWidth ?? this.focusedWidth,
    errorWidth: errorWidth ?? this.errorWidth,
    focusedErrorWidth: focusedErrorWidth ?? this.focusedErrorWidth,
  );

  @override
  UiBorderTheme lerp(UiBorderTheme? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return UiBorderTheme(
      kind: t < .5 ? kind : other.kind,
      width: mix(width, other.width),
      focusedWidth: mix(focusedWidth, other.focusedWidth),
      errorWidth: mix(errorWidth, other.errorWidth),
      focusedErrorWidth: mix(focusedErrorWidth, other.focusedErrorWidth),
    );
  }
}
