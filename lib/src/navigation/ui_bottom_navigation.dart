import 'package:flutter/material.dart';

@immutable
class UiBottomNavigationItem {
  const UiBottomNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
}

/// Compact navigation for the five highest-frequency Ui destinations.
///
/// The selected destination uses a large, unmistakable target instead of
/// Material's small pill indicator. Keep this component to five items or less.
class UiBottomNavigation extends StatelessWidget {
  const UiBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(items.length > 1 && items.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<UiBottomNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: SizedBox(
            height: MediaQuery.textScalerOf(context).scale(12) > 18 ? 100 : 68,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++)
                  Expanded(
                    child: _NavigationDestination(
                      item: items[index],
                      selected: index == selectedIndex,
                      onTap: () => onDestinationSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final UiBottomNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final activeBackground = colors.primaryContainer;
    final activeForeground = colors.onPrimaryContainer;
    final foreground = selected ? activeForeground : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? activeBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: ExcludeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.selectedIcon ?? item.icon : item.icon,
                    size: 24,
                    color: foreground,
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Tooltip(
                      message: item.label,
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines:
                            MediaQuery.textScalerOf(context).scale(12) > 18
                            ? 2
                            : 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
