import 'package:flutter/material.dart';

/// Optional presentation for [Material] surfaces, independent of layout.
///
/// Supply either [shape] (including its own sides) or [border], not both.
/// Null properties inherit from the theme. BorderSide.none and elevation zero
/// explicitly remove an inherited border or elevation.
@immutable
class UiSurfaceStyle extends ThemeExtension<UiSurfaceStyle> {
  const UiSurfaceStyle({
    this.shape,
    this.border,
    this.elevation,
    this.shadowColor,
    this.clipBehavior,
  }) : assert(shape == null || border == null),
       assert(
         elevation == null || (elevation >= 0 && elevation < double.infinity),
       );

  final ShapeBorder? shape;
  final BorderSide? border;
  final double? elevation;
  final Color? shadowColor;
  final Clip? clipBehavior;

  static UiSurfaceStyle of(BuildContext context) =>
      Theme.of(context).extension<UiSurfaceStyle>() ?? const UiSurfaceStyle();

  /// Applies only supplied properties; a shape replaces an inherited border
  /// and a border replaces an inherited shape to avoid ambiguous combinations.
  UiSurfaceStyle merge(UiSurfaceStyle? other) => other == null
      ? this
      : copyWith(
          shape: other.shape,
          border: other.border,
          elevation: other.elevation,
          shadowColor: other.shadowColor,
          clipBehavior: other.clipBehavior,
        );

  @override
  UiSurfaceStyle copyWith({
    ShapeBorder? shape,
    BorderSide? border,
    double? elevation,
    Color? shadowColor,
    Clip? clipBehavior,
  }) {
    assert(shape == null || border == null);
    return UiSurfaceStyle(
      shape: shape ?? (border != null ? null : this.shape),
      border: border ?? (shape != null ? null : this.border),
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      clipBehavior: clipBehavior ?? this.clipBehavior,
    );
  }

  @override
  UiSurfaceStyle lerp(UiSurfaceStyle? other, double t) {
    if (other == null) return this;
    final chosen = t < .5 ? this : other;
    return UiSurfaceStyle(
      shape: shape != null && other.shape != null
          ? ShapeBorder.lerp(shape, other.shape, t)
          : chosen.shape,
      border:
          shape == null &&
              other.shape == null &&
              border != null &&
              other.border != null
          ? BorderSide.lerp(border!, other.border!, t)
          : chosen.border,
      elevation: elevation != null && other.elevation != null
          ? elevation! + (other.elevation! - elevation!) * t
          : chosen.elevation,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      clipBehavior: chosen.clipBehavior,
    );
  }
}
