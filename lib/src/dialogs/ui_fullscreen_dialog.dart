import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

/// The route owns its messenger: use the builder's context for messages.
Future<T?> showUiFullscreenDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) => showDialog<T>(
  context: context,
  useSafeArea: false,
  barrierDismissible: barrierDismissible,
  builder: (routeContext) =>
      ScaffoldMessenger(child: Builder(builder: builder)),
);

class UiFullscreenDialog extends StatelessWidget {
  const UiFullscreenDialog({
    required this.title,
    required this.content,
    this.description,
    this.actions = const [],
    this.scrollable = true,
    this.maxContentWidth = 840,
    this.closeLabel = 'Close',
    this.onClose,
    super.key,
  });
  final Widget title, content;
  final String? description;
  final List<Widget> actions;
  final bool scrollable;
  final double maxContentWidth;
  final String closeLabel;
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = UiThemeData.of(context);
    final compact = MediaQuery.sizeOf(context).width < config.compactBreakpoint;
    final horizontal = compact ? 16.0 : 24.0;
    final scale = MediaQuery.textScalerOf(context);
    double line(TextStyle? style) =>
        scale.scale(style?.fontSize ?? config.fontSize) *
        (style?.height ?? 1.2);
    final headerHeight = math.max(
      kToolbarHeight,
      line(theme.textTheme.titleLarge) +
          (description == null ? 0 : line(theme.textTheme.bodySmall)) +
          8,
    );
    Widget surface(Widget child) => compact
        ? child
        : Material(
            color: theme.colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(config.panelRadius),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          );
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: compact
            ? theme.colorScheme.surfaceContainerLowest
            : theme.colorScheme.surface,
        appBar: AppBar(
          toolbarHeight: headerHeight,
          leading: IconButton(
            tooltip: closeLabel,
            onPressed: onClose ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.close),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
              if (description != null)
                Tooltip(
                  message: description!,
                  child: Text(
                    description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: scrollable
              ? SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: surface(content),
                    ),
                  ),
                )
              : Padding(padding: EdgeInsets.all(horizontal), child: content),
        ),
        bottomNavigationBar: actions.isEmpty
            ? null
            : Material(
                color: theme.colorScheme.surfaceContainerLowest,
                shape: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontal,
                      vertical: 12,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: actions,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
