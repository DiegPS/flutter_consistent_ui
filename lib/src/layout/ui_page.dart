import 'package:flutter/material.dart';

import 'ui_layout.dart';
import '../theme/ui_control_metrics.dart';

abstract final class UiPageInsets {
  static const EdgeInsets standard = EdgeInsets.fromLTRB(24, 12, 24, 24);
  static EdgeInsets of(BuildContext context) => EdgeInsets.fromLTRB(
    MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
    12,
    MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
    24,
  );
}

/// Structural wrapper for every full Ui feature view.
///
/// Feature spacing is composed here; colors and type come from UiTheme.
class UiPage extends StatelessWidget {
  const UiPage({
    required this.child,
    this.scrollable = false,
    this.padding,
    super.key,
  });

  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? UiPageInsets.of(context),
      child: child,
    );
    if (!scrollable) return content;
    return SingleChildScrollView(child: content);
  }
}

/// A shared structural header. It preserves existing widget styling and only
/// standardizes how title and actions reflow.
class UiPageHeader extends StatelessWidget {
  const UiPageHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [title, ?subtitle],
    );
    return UiControlScope(
      child: UiLayoutBuilder(
        builder: (context, layout) {
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          if (layout.isCompact || layout.width < 600 * textScale) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: heading),
              if (actions.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          );
        },
      ),
    );
  }
}

/// Feature-level actions shown below the shell-owned page heading.
///
/// Full feature screens do not repeat the primary title rendered by the shell.
class UiPageToolbar extends StatelessWidget {
  const UiPageToolbar({required this.actions, super.key});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => UiControlScope(
    child: Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: actions,
      ),
    ),
  );
}
