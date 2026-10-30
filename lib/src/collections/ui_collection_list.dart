import 'package:flutter/material.dart';

import '../layout/ui_layout.dart';
import '../theme/ui_semantic_colors.dart';
import 'ui_collection_viewport.dart';

enum UiCollectionBadgeTone { neutral, info, success, warning, danger }

/// Canonical result list for Ui collections.
///
/// Use [scrollable] when the list owns the remaining page viewport. Use the
/// default column mode when the collection page itself scrolls.
class UiCollectionList extends StatelessWidget {
  const UiCollectionList({
    required this.children,
    this.scrollable = false,
    super.key,
  }) : itemBuilder = null,
       _itemCount = null;

  const UiCollectionList.builder({
    required IndexedWidgetBuilder this.itemBuilder,
    required int itemCount,
    this.scrollable = true,
    super.key,
  }) : assert(itemCount >= 0),
       _itemCount = itemCount,
       children = const [];

  final List<Widget> children;
  final bool scrollable;
  final IndexedWidgetBuilder? itemBuilder;
  final int? _itemCount;

  /// Space reserved inside an owned scroll viewport so the platform scrollbar
  /// never overlays card content or trailing actions.
  static const double scrollbarGutter = 12;

  @override
  Widget build(BuildContext context) {
    final count = _itemCount ?? children.length;
    Widget item(int index) =>
        itemBuilder?.call(context, index) ?? children[index];
    if (scrollable) {
      final bottomInset = UiCollectionViewport.bottomOverlayInsetOf(context);
      return ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(
          0,
          2,
          scrollbarGutter,
          2 + bottomInset,
        ),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => item(index),
      );
    }
    return Column(
      children: [
        for (var index = 0; index < count; index++) ...[
          item(index),
          if (index < count - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// A colored, compact classification attached to a collection item.
class UiCollectionBadge extends StatelessWidget {
  const UiCollectionBadge({
    required this.label,
    this.tone = UiCollectionBadgeTone.neutral,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    super.key,
  });

  final String label;
  final UiCollectionBadgeTone tone;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = UiSemanticColors.of(context);
    final resolved = switch (tone) {
      UiCollectionBadgeTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      UiCollectionBadgeTone.info => (
        semantic.info.container,
        semantic.info.onContainer,
      ),
      UiCollectionBadgeTone.success => (
        semantic.success.container,
        semantic.success.onContainer,
      ),
      UiCollectionBadgeTone.warning => (
        semantic.warning.container,
        semantic.warning.onContainer,
      ),
      UiCollectionBadgeTone.danger => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };
    final badgeBackground = backgroundColor ?? resolved.$1;
    final badgeForeground = foregroundColor ?? resolved.$2;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: 13, color: badgeForeground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: badgeForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One labeled fact displayed below a collection item's title.
class UiCollectionDetail extends StatelessWidget {
  const UiCollectionDetail({
    required this.icon,
    required this.text,
    this.prominent = false,
    this.monospace = false,
    super.key,
  });

  final IconData icon;
  final String text;
  final bool prominent;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                (prominent
                        ? theme.textTheme.bodyMedium
                        : theme.textTheme.bodySmall)
                    ?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: monospace
                          ? const [FontFeature.tabularFigures()]
                          : null,
                    ),
          ),
        ),
      ],
    );
  }
}

/// Canonical card for one result in an Ui collection.
class UiCollectionItem extends StatelessWidget {
  const UiCollectionItem({
    required this.title,
    this.leadingIcon,
    this.leadingBackgroundColor,
    this.leadingForegroundColor,
    this.badges = const [],
    this.details = const [],
    this.secondaryActions = const [],
    this.trailingAction,
    this.accentColor,
    this.onOpen,
    this.semanticsLabel,
    super.key,
  });

  final Widget title;
  final IconData? leadingIcon;
  final Color? leadingBackgroundColor;
  final Color? leadingForegroundColor;
  final List<Widget> badges;
  final List<Widget> details;

  /// Commands that operate on this item without opening its primary detail.
  /// They stack below the content on compact windows and move to the trailing
  /// side when horizontal space is available.
  final List<Widget> secondaryActions;

  /// A compact utility command such as an overflow or download button.
  /// Unlike the old generic trailing slot, this never replaces the navigation
  /// indicator of an item that also has [onOpen].
  final Widget? trailingAction;
  final Color? accentColor;

  /// Opens the canonical detail for this entity. Null means that the item is
  /// informational and must not advertise navigation.
  final VoidCallback? onOpen;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget content({required bool includeActions}) {
      final description = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DefaultTextStyle.merge(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                child: title,
              ),
              ...badges,
            ],
          ),
          for (final detail in details) ...[const SizedBox(height: 5), detail],
        ],
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              excluding: semanticsLabel != null,
              child: description,
            ),
            if (includeActions && secondaryActions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: secondaryActions),
            ],
          ],
        ),
      );
    }

    Widget leading() {
      final icon = leadingIcon;
      if (icon == null) return const SizedBox(width: 14);
      return ExcludeSemantics(
        excluding: semanticsLabel != null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: leadingBackgroundColor ?? colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 20,
                  color: leadingForegroundColor ?? colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget trailing() {
      if (trailingAction == null && onOpen == null) {
        return const SizedBox(width: 14);
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingAction case final action?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: action,
            ),
          if (onOpen != null)
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 2, end: 10),
                child: Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    }

    final card = Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpen,
        excludeFromSemantics: semanticsLabel != null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: accentColor == null
                ? null
                : Border(left: BorderSide(color: accentColor!, width: 3)),
          ),
          child: UiLayoutBuilder(
            builder: (context, layout) {
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              final stackedActions =
                  layout.isCompact || layout.width < 720 * scale;
              return Row(
                children: [
                  leading(),
                  Expanded(child: content(includeActions: stackedActions)),
                  if (!stackedActions && secondaryActions.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: secondaryActions,
                      ),
                    ),
                  ],
                  trailing(),
                ],
              );
            },
          ),
        ),
      ),
    );
    if (semanticsLabel == null) return card;
    return Semantics(
      container: true,
      explicitChildNodes: secondaryActions.isNotEmpty || trailingAction != null,
      button: onOpen != null,
      label: semanticsLabel,
      onTap: onOpen,
      child: card,
    );
  }
}
