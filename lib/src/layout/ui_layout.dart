import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/ui_theme.dart';

/// The only window breakpoints used by Ui.
///
/// Layout decisions are based on the logical width available to a widget, not
/// on the operating system. Do not duplicate these values in feature views.
abstract final class UiBreakpoints {
  static const double medium = 600;
  static const double operationalToolbar = 840;
  static const double expanded = 1024;
  static const double wide = 1440;
}

enum UiWindowClass { compact, medium, expanded, wide }

enum UiPlatform { android, ios, windows, macos, linux, web, unknown }

@immutable
class UiLayout {
  const UiLayout({
    required this.availableSize,
    required this.windowClass,
    required this.platform,
  });

  factory UiLayout.fromSize(
    Size size, {
    UiThemeData theme = const UiThemeData(),
  }) => UiLayout(
    availableSize: size,
    windowClass: classifyWidth(
      size.width,
      compactBreakpoint: theme.compactBreakpoint,
    ),
    platform: detectPlatform(),
  );

  final Size availableSize;
  final UiWindowClass windowClass;
  final UiPlatform platform;

  double get width => availableSize.width;
  double get height => availableSize.height;

  bool get isCompact => windowClass == UiWindowClass.compact;
  bool get isMedium => windowClass == UiWindowClass.medium;
  bool get isExpanded =>
      windowClass == UiWindowClass.expanded ||
      windowClass == UiWindowClass.wide;
  bool get isWide => windowClass == UiWindowClass.wide;

  /// The phone shell uses bottom navigation. Medium and larger windows use a
  /// navigation rail. Platform does not affect this decision.
  bool get usesBottomNavigation => isCompact;

  /// Labels are shown when the content window is large enough for a full rail.
  bool get usesExtendedNavigation => isExpanded;

  /// Search, filters and commands share one band when an operational view has
  /// enough local width. Narrower panes reflow without inventing thresholds in
  /// individual features.
  bool get usesSingleBandOperationalToolbar =>
      width >= UiBreakpoints.operationalToolbar;

  int columns({int compact = 1, int medium = 2, int expanded = 4, int? wide}) =>
      switch (windowClass) {
        UiWindowClass.compact => compact,
        UiWindowClass.medium => medium,
        UiWindowClass.expanded => expanded,
        UiWindowClass.wide => wide ?? expanded,
      };

  static UiWindowClass classifyWidth(
    double width, {
    double compactBreakpoint = UiBreakpoints.medium,
  }) {
    if (width < compactBreakpoint) return UiWindowClass.compact;
    if (width < UiBreakpoints.expanded) return UiWindowClass.medium;
    if (width < UiBreakpoints.wide) return UiWindowClass.expanded;
    return UiWindowClass.wide;
  }

  static UiPlatform detectPlatform() {
    if (kIsWeb) return UiPlatform.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => UiPlatform.android,
      TargetPlatform.iOS => UiPlatform.ios,
      TargetPlatform.windows => UiPlatform.windows,
      TargetPlatform.macOS => UiPlatform.macos,
      TargetPlatform.linux => UiPlatform.linux,
      TargetPlatform.fuchsia => UiPlatform.unknown,
    };
  }
}

typedef UiLayoutWidgetBuilder = Widget Function(
  BuildContext context,
  UiLayout layout,
);

/// Gives a view the Ui layout contract using its actual local constraints.
///
/// Use this instead of reading the full screen through MediaQuery whenever the
/// component can be placed beside navigation or inside another container.
class UiLayoutBuilder extends StatelessWidget {
  const UiLayoutBuilder({required this.builder, super.key});

  final UiLayoutWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : mediaSize.height;
        return builder(
          context,
          UiLayout.fromSize(
            Size(width, height),
            theme: UiThemeData.of(context),
          ),
        );
      },
    );
  }
}

/// Shared viewport calculation for operational dialogs.
///
/// Feature dialogs may choose their own maximum useful content size, but they
/// must not invent breakpoints or subtract arbitrary values from the screen.
@immutable
class UiDialogViewport {
  const UiDialogViewport({
    required this.layout,
    required this.contentSize,
    required this.fullscreen,
  });

  factory UiDialogViewport.resolve(
    BuildContext context, {
    required double maxWidth,
    required double maxHeight,
  }) {
    final media = MediaQuery.of(context);
    final layout = UiLayout.fromSize(media.size);
    const horizontalSafeSpace = 48.0;
    const verticalSafeSpace = 144.0;
    final availableWidth = (media.size.width - horizontalSafeSpace).clamp(
      0.0,
      maxWidth,
    );
    final availableHeight = (media.size.height - verticalSafeSpace).clamp(
      0.0,
      maxHeight,
    );
    return UiDialogViewport(
      layout: layout,
      contentSize: Size(availableWidth, availableHeight),
      fullscreen: layout.isCompact,
    );
  }

  final UiLayout layout;
  final Size contentSize;
  final bool fullscreen;
}
