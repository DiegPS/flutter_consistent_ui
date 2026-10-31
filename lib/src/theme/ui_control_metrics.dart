import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ui_theme.dart';

/// Matches painted borders, not outer boxes containing helpers and validation.
abstract final class UiControlMetrics {
  static double textHeight(BuildContext context) {
    final config = UiThemeData.of(context);
    return MediaQuery.textScalerOf(context).scale(config.fontSize) *
        config.lineHeight /
        config.fontSize;
  }

  static double height(BuildContext context) {
    final config = UiThemeData.of(context);
    final base = MediaQuery.sizeOf(context).width < config.compactBreakpoint
        ? config.compactControlHeight
        : config.controlHeight;
    return base +
        math.max(
              0,
              MediaQuery.textScalerOf(context).scale(config.fontSize) /
                      config.fontSize -
                  1,
            ) *
            config.lineHeight;
  }

  static TextStyle textStyle(BuildContext context) {
    final config = UiThemeData.of(context);
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: config.fontSize,
      height: config.lineHeight / config.fontSize,
    );
  }

  static InputDecoration decoration(
    BuildContext context,
    InputDecoration value, {
    bool select = false,
  }) {
    final config = UiThemeData.of(context);
    final target = height(context);
    final content = select
        ? math.max(24.0, textHeight(context))
        : textHeight(context);
    return value.copyWith(
      isDense: true,
      visualDensity: VisualDensity.standard,
      hintStyle: textStyle(context)
          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)
          .merge(Theme.of(context).inputDecorationTheme.hintStyle)
          .merge(value.hintStyle)
          .copyWith(
            fontSize: config.fontSize,
            height: config.lineHeight / config.fontSize,
          ),
      helperMaxLines: value.helperMaxLines ?? 4,
      errorMaxLines: value.errorMaxLines ?? 4,
      contentPadding: EdgeInsets.symmetric(
        horizontal: config.fieldHorizontalPadding,
        vertical: math.max(0, (target - content) / 2),
      ),
      prefixIconConstraints: BoxConstraints.tightFor(
        width: target,
        height: target,
      ),
      suffixIconConstraints: BoxConstraints.tightFor(
        width: target,
        height: target,
      ),
    );
  }

  static ButtonStyle action(BuildContext context) {
    final config = UiThemeData.of(context);
    return FilledButton.styleFrom(
      fixedSize: Size.infinite,
      maximumSize: Size.infinite,
      minimumSize: Size(0, height(context)),
      padding: EdgeInsets.symmetric(
        horizontal: config.actionHorizontalPadding,
        vertical: math.max(0, (height(context) - textHeight(context)) / 2),
      ),
      textStyle: textStyle(context).copyWith(fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.standard,
    );
  }
}

/// Opt-in geometry for native actions supplied to a toolbar.
class UiControlScope extends StatelessWidget {
  const UiControlScope({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final geometry = UiControlMetrics.action(context);
    return Theme(
      data: theme.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: geometry.merge(theme.filledButtonTheme.style),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: geometry.merge(theme.elevatedButtonTheme.style),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: geometry.merge(theme.outlinedButtonTheme.style),
        ),
        textButtonTheme: TextButtonThemeData(
          style: geometry.merge(theme.textButtonTheme.style),
        ),
      ),
      child: child,
    );
  }
}
