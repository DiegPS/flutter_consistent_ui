import 'package:flutter/widgets.dart';

abstract interface class UiPaginationFooter {
  bool get hasMultiplePages;
}

class UiCollectionViewport extends InheritedWidget {
  const UiCollectionViewport({
    required this.bottomOverlayInset,
    required super.child,
    super.key,
  });

  final double bottomOverlayInset;

  static double bottomOverlayInsetOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<UiCollectionViewport>()
          ?.bottomOverlayInset ??
      0;

  @override
  bool updateShouldNotify(UiCollectionViewport oldWidget) =>
      bottomOverlayInset != oldWidget.bottomOverlayInset;
}
