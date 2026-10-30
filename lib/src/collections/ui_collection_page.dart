import 'package:flutter/material.dart';

import '../controls/ui_controls.dart';
import '../theme/ui_control_metrics.dart';
import '../theme/ui_theme.dart';
import '../layout/ui_page.dart';

class UiSearchField extends StatefulWidget {
  const UiSearchField({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.submitLabel = 'Search',
    super.key,
  });
  final String hintText, submitLabel;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged, onSubmitted;
  @override
  State<UiSearchField> createState() => _UiSearchFieldState();
}

class _UiSearchFieldState extends State<UiSearchField> {
  final _owned = TextEditingController();
  TextEditingController get _controller => widget.controller ?? _owned;
  @override
  void dispose() {
    _owned.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiControls.input(
    controller: _controller,
    textInputAction: TextInputAction.search,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: widget.onSubmitted == null
          ? null
          : IconButton(
              tooltip: widget.submitLabel,
              onPressed: () => widget.onSubmitted!(_controller.text),
              icon: const Icon(Icons.arrow_forward),
            ),
    ),
  );
}

/// Filters stay on one horizontally scrollable band in narrow panes.
/// The consumer supplies the actual controls, actions and their authorization.
class UiCollectionToolbar extends StatelessWidget {
  const UiCollectionToolbar({
    this.search,
    this.filters = const [],
    this.actions = const [],
    super.key,
  });
  final Widget? search;
  final List<Widget> filters, actions;
  @override
  Widget build(BuildContext context) => UiControlScope(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final config = UiThemeData.of(context);
        final scale =
            MediaQuery.textScalerOf(context).scale(config.fontSize) /
            config.fontSize;
        final commands = [...actions, ...filters];
        if (constraints.maxWidth >= 1000 * scale && commands.length <= 3) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (search != null) Expanded(child: search!),
              if (search != null && commands.isNotEmpty)
                const SizedBox(width: 12),
              for (var i = 0; i < commands.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 5,
                  ),
                  child: commands[i],
                ),
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ?search,
            if (search != null && commands.isNotEmpty)
              const SizedBox(height: 8),
            if (commands.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < commands.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: commands[i],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    ),
  );
}

/// Supplies layout only. Loading/errors, paging state and data belong to the app.
class UiCollectionPage extends StatelessWidget {
  const UiCollectionPage({
    required this.content,
    this.search,
    this.filters = const [],
    this.actions = const [],
    this.footer,
    super.key,
  });
  final Widget content;
  final Widget? search, footer;
  final List<Widget> filters, actions;
  @override
  Widget build(BuildContext context) => Padding(
    padding: UiPageInsets.of(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiCollectionToolbar(search: search, filters: filters, actions: actions),
        const SizedBox(height: 12),
        Expanded(child: content),
        if (footer != null) ...[const SizedBox(height: 8), footer!],
      ],
    ),
  );
}

/// Zero-based pagination; all text can be supplied by the app's localization.
class UiPagination extends StatelessWidget {
  const UiPagination({
    required this.page,
    required this.pageCount,
    required this.label,
    required this.onChanged,
    this.previousLabel = 'Previous page',
    this.nextLabel = 'Next page',
    super.key,
  }) : assert(page >= 0),
       assert(pageCount > 0),
       assert(page < pageCount);
  final int page, pageCount;
  final String label, previousLabel, nextLabel;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
      if (pageCount > 1) ...[
        IconButton(
          tooltip: previousLabel,
          onPressed: page > 0 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: nextLabel,
          onPressed: page + 1 < pageCount ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    ],
  );
}
