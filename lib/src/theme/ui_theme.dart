import 'package:flutter/material.dart';

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

/// Installs shapes and geometry without replacing a product's color scheme/fonts.
abstract final class UiTheme {
  static ThemeData apply(
    ThemeData base, {
    UiThemeData geometry = const UiThemeData(),
  }) {
    final colors = base.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(geometry.controlRadius),
    );
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(geometry.controlRadius),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      extensions: [
        ...base.extensions.values.where((e) => e is! UiThemeData),
        geometry,
      ],
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: border(colors.outline),
        enabledBorder: border(colors.outline),
        focusedBorder: border(colors.primary, 1.5),
        errorBorder: border(colors.error),
        focusedErrorBorder: border(colors.error, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: (base.filledButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: WidgetStatePropertyAll(shape),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: (base.outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: WidgetStatePropertyAll(shape),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (base.textButtonTheme.style ?? const ButtonStyle()).copyWith(
          shape: WidgetStatePropertyAll(shape),
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(geometry.panelRadius),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: colors.surfaceContainerLowest,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(geometry.panelRadius),
        ),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(geometry.panelRadius),
          ),
        ),
      ),
      popupMenuTheme: base.popupMenuTheme.copyWith(
        color: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(geometry.controlRadius),
        ),
      ),
      tooltipTheme: base.tooltipTheme.copyWith(
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(geometry.controlRadius),
        ),
        textStyle: base.textTheme.bodySmall?.copyWith(
          color: colors.onInverseSurface,
        ),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        shape: shape,
      ),
      navigationRailTheme: base.navigationRailTheme.copyWith(
        backgroundColor: colors.surfaceContainerLowest,
        indicatorColor: colors.primaryContainer,
        selectedIconTheme: IconThemeData(color: colors.primary),
        unselectedIconTheme: IconThemeData(color: colors.onSurfaceVariant),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: colors.primary,
        unselectedLabelColor: colors.onSurfaceVariant,
        indicatorColor: colors.primary,
        dividerColor: colors.outlineVariant,
      ),
      dividerTheme: base.dividerTheme.copyWith(color: colors.outlineVariant),
    );
  }
}
