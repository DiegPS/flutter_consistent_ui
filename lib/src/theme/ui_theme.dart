import 'package:flutter/material.dart';

import 'ui_border_theme.dart';
import 'ui_surface_style.dart';

/// Geometry policy. Colors and fonts remain owned by the consuming application.
@immutable
class UiThemeData extends ThemeExtension<UiThemeData> {
  const UiThemeData({
    this.controlHeight = 40,
    this.compactControlHeight = 48,
    this.compactBreakpoint = 600,
    this.fontSize = 14,
    this.lineHeight = 20,
    this.fieldHorizontalPadding = 12,
    this.actionHorizontalPadding = 16,
    this.controlRadius = 6,
    this.panelRadius = 10,
    this.formSpacing = 20,
    this.minimumFieldWidth = 280,
  }) : assert(controlHeight >= lineHeight),
       assert(compactControlHeight >= lineHeight),
       assert(fontSize > 0),
       assert(lineHeight > 0),
       assert(compactBreakpoint > 0),
       assert(fieldHorizontalPadding >= 0),
       assert(actionHorizontalPadding >= 0),
       assert(controlRadius >= 0),
       assert(panelRadius >= 0),
       assert(formSpacing >= 0),
       assert(minimumFieldWidth > 0);

  final double controlHeight, compactControlHeight, compactBreakpoint;
  final double fontSize,
      lineHeight,
      fieldHorizontalPadding,
      actionHorizontalPadding;
  final double controlRadius, panelRadius, formSpacing, minimumFieldWidth;

  static UiThemeData of(BuildContext context) =>
      Theme.of(context).extension<UiThemeData>() ?? const UiThemeData();

  @override
  UiThemeData copyWith({
    double? controlHeight,
    double? compactControlHeight,
    double? compactBreakpoint,
    double? fontSize,
    double? lineHeight,
    double? fieldHorizontalPadding,
    double? actionHorizontalPadding,
    double? controlRadius,
    double? panelRadius,
    double? formSpacing,
    double? minimumFieldWidth,
  }) => UiThemeData(
    controlHeight: controlHeight ?? this.controlHeight,
    compactControlHeight: compactControlHeight ?? this.compactControlHeight,
    compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    fieldHorizontalPadding:
        fieldHorizontalPadding ?? this.fieldHorizontalPadding,
    actionHorizontalPadding:
        actionHorizontalPadding ?? this.actionHorizontalPadding,
    controlRadius: controlRadius ?? this.controlRadius,
    panelRadius: panelRadius ?? this.panelRadius,
    formSpacing: formSpacing ?? this.formSpacing,
    minimumFieldWidth: minimumFieldWidth ?? this.minimumFieldWidth,
  );

  @override
  UiThemeData lerp(UiThemeData? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return UiThemeData(
      controlHeight: mix(controlHeight, other.controlHeight),
      compactControlHeight: mix(
        compactControlHeight,
        other.compactControlHeight,
      ),
      compactBreakpoint: mix(compactBreakpoint, other.compactBreakpoint),
      fontSize: mix(fontSize, other.fontSize),
      lineHeight: mix(lineHeight, other.lineHeight),
      fieldHorizontalPadding: mix(
        fieldHorizontalPadding,
        other.fieldHorizontalPadding,
      ),
      actionHorizontalPadding: mix(
        actionHorizontalPadding,
        other.actionHorizontalPadding,
      ),
      controlRadius: mix(controlRadius, other.controlRadius),
      panelRadius: mix(panelRadius, other.panelRadius),
      formSpacing: mix(formSpacing, other.formSpacing),
      minimumFieldWidth: mix(minimumFieldWidth, other.minimumFieldWidth),
    );
  }
}

/// Installs geometry and missing visual defaults, preserving explicit styles.
///
/// Per-widget values win over the application theme; explicit application-theme
/// values win over these policies. To use a policy globally, omit conflicting
/// overrides from the base theme. Colors and fonts remain product-owned.
abstract final class UiTheme {
  static ThemeData apply(
    ThemeData base, {
    UiThemeData geometry = const UiThemeData(),
    UiBorderTheme? borders,
    UiSurfaceStyle? surfaces,
  }) {
    final colors = base.colorScheme;
    final borderPolicy =
        borders ?? base.extension<UiBorderTheme>() ?? const UiBorderTheme();
    final surfacePolicy =
        surfaces ?? base.extension<UiSurfaceStyle>() ?? const UiSurfaceStyle();
    final input = base.inputDecorationTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(geometry.controlRadius),
    );
    final inputShape =
        input.border ??
        borderPolicy.inputBorder(
          geometry.controlRadius,
          borderPolicy.side(colors, {}),
        );
    InputBorder border(Set<WidgetState> states) =>
        inputShape.copyWith(borderSide: borderPolicy.side(colors, states));
    final panelShape =
        surfacePolicy.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(geometry.panelRadius),
          side:
              surfacePolicy.border ?? BorderSide(color: colors.outlineVariant),
        );
    return base.copyWith(
      extensions: [
        ...base.extensions.values.where(
          (e) =>
              e is! UiThemeData && e is! UiBorderTheme && e is! UiSurfaceStyle,
        ),
        geometry,
        borderPolicy,
        surfacePolicy,
      ],
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: inputShape,
        enabledBorder: input.enabledBorder ?? inputShape,
        disabledBorder: input.disabledBorder ?? border({WidgetState.disabled}),
        focusedBorder: input.focusedBorder ?? border({WidgetState.focused}),
        errorBorder: input.errorBorder ?? border({WidgetState.error}),
        focusedErrorBorder:
            input.focusedErrorBorder ??
            border({WidgetState.error, WidgetState.focused}),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: (base.filledButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape:
              base.filledButtonTheme.style?.shape ??
              WidgetStatePropertyAll(shape),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape:
              base.elevatedButtonTheme.style?.shape ??
              WidgetStatePropertyAll(shape),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: (base.outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape:
              base.outlinedButtonTheme.style?.shape ??
              WidgetStatePropertyAll(shape),
          side:
              base.outlinedButtonTheme.style?.side ??
              WidgetStateProperty.resolveWith(
                (s) => borderPolicy.side(colors, s),
              ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (base.textButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape:
              base.textButtonTheme.style?.shape ??
              WidgetStatePropertyAll(shape),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: base.cardTheme.elevation ?? surfacePolicy.elevation ?? 0,
        shadowColor: base.cardTheme.shadowColor ?? surfacePolicy.shadowColor,
        clipBehavior: base.cardTheme.clipBehavior ?? surfacePolicy.clipBehavior,
        margin: base.cardTheme.margin ?? EdgeInsets.zero,
        shape: base.cardTheme.shape ?? panelShape,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor:
            base.appBarTheme.backgroundColor ?? colors.surfaceContainerLowest,
        foregroundColor: base.appBarTheme.foregroundColor ?? colors.onSurface,
        surfaceTintColor:
            base.appBarTheme.surfaceTintColor ?? Colors.transparent,
        elevation: base.appBarTheme.elevation ?? 0,
        scrolledUnderElevation: base.appBarTheme.scrolledUnderElevation ?? 0,
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor:
            base.dialogTheme.backgroundColor ?? colors.surfaceContainerLowest,
        surfaceTintColor:
            base.dialogTheme.surfaceTintColor ?? Colors.transparent,
        shape:
            base.dialogTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(geometry.panelRadius),
            ),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor:
            base.bottomSheetTheme.backgroundColor ??
            colors.surfaceContainerLowest,
        surfaceTintColor:
            base.bottomSheetTheme.surfaceTintColor ?? Colors.transparent,
        shape:
            base.bottomSheetTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(geometry.panelRadius),
              ),
            ),
      ),
      popupMenuTheme: base.popupMenuTheme.copyWith(
        color: base.popupMenuTheme.color ?? colors.surfaceContainerLowest,
        surfaceTintColor:
            base.popupMenuTheme.surfaceTintColor ?? Colors.transparent,
        shape:
            base.popupMenuTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(geometry.controlRadius),
            ),
      ),
      tooltipTheme: base.tooltipTheme.copyWith(
        decoration:
            base.tooltipTheme.decoration ??
            BoxDecoration(
              color: colors.inverseSurface,
              borderRadius: BorderRadius.circular(geometry.controlRadius),
            ),
        textStyle:
            base.tooltipTheme.textStyle ??
            base.textTheme.bodySmall?.copyWith(color: colors.onInverseSurface),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: base.snackBarTheme.behavior ?? SnackBarBehavior.floating,
        backgroundColor:
            base.snackBarTheme.backgroundColor ?? colors.inverseSurface,
        contentTextStyle:
            base.snackBarTheme.contentTextStyle ??
            base.textTheme.bodyMedium?.copyWith(color: colors.onInverseSurface),
        actionTextColor:
            base.snackBarTheme.actionTextColor ?? colors.inversePrimary,
        shape: base.snackBarTheme.shape ?? shape,
      ),
      navigationRailTheme: base.navigationRailTheme.copyWith(
        backgroundColor:
            base.navigationRailTheme.backgroundColor ??
            colors.surfaceContainerLowest,
        indicatorColor:
            base.navigationRailTheme.indicatorColor ?? colors.primaryContainer,
        selectedIconTheme:
            base.navigationRailTheme.selectedIconTheme ??
            IconThemeData(color: colors.primary),
        unselectedIconTheme:
            base.navigationRailTheme.unselectedIconTheme ??
            IconThemeData(color: colors.onSurfaceVariant),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: base.tabBarTheme.labelColor ?? colors.primary,
        unselectedLabelColor:
            base.tabBarTheme.unselectedLabelColor ?? colors.onSurfaceVariant,
        indicatorColor: base.tabBarTheme.indicatorColor ?? colors.primary,
        dividerColor: base.tabBarTheme.dividerColor ?? colors.outlineVariant,
      ),
      dividerTheme: base.dividerTheme.copyWith(
        color: base.dividerTheme.color ?? colors.outlineVariant,
      ),
    );
  }
}
