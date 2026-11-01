import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

class UiDisclosure extends StatelessWidget {
  const UiDisclosure({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.maintainState = true,
    this.onExpansionChanged,
    this.tilePadding,
    this.childrenPadding,
  });

  final Widget title;
  final Widget? subtitle, leading;
  final List<Widget> children;
  final bool initiallyExpanded, maintainState;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry? tilePadding, childrenPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final native = theme.expansionTileTheme;
    final geometry = UiThemeData.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(geometry.controlRadius),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
    return ExpansionTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      initiallyExpanded: initiallyExpanded,
      maintainState: maintainState,
      onExpansionChanged: onExpansionChanged,
      shape: native.shape ?? shape,
      collapsedShape: native.collapsedShape ?? shape,
      backgroundColor: native.backgroundColor ?? theme.colorScheme.surface,
      collapsedBackgroundColor:
          native.collapsedBackgroundColor ?? theme.colorScheme.surface,
      textColor: native.textColor ?? theme.colorScheme.onSurface,
      collapsedTextColor:
          native.collapsedTextColor ?? theme.colorScheme.onSurface,
      iconColor: native.iconColor ?? theme.colorScheme.onSurfaceVariant,
      collapsedIconColor:
          native.collapsedIconColor ?? theme.colorScheme.onSurfaceVariant,
      tilePadding:
          tilePadding ??
          native.tilePadding ??
          EdgeInsets.symmetric(horizontal: geometry.fieldHorizontalPadding),
      childrenPadding:
          childrenPadding ??
          native.childrenPadding ??
          EdgeInsets.all(geometry.formSpacing),
      clipBehavior: native.clipBehavior ?? Clip.antiAlias,
      children: children,
    );
  }
}
