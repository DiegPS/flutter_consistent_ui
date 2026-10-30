import 'dart:async';

import 'package:flutter/material.dart';

import '../controls/ui_controls.dart';
import '../theme/ui_theme.dart';

@immutable
class UiNotice {
  const UiNotice({
    required this.message,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// One per application/window, not static global state shared between projects.
class UiNoticeController extends ChangeNotifier {
  UiNotice? _value;
  Timer? _timer;
  UiNotice? get value => _value;
  void show(UiNotice notice, {Duration duration = const Duration(seconds: 4)}) {
    assert(duration > Duration.zero);
    _timer?.cancel();
    _value = notice;
    notifyListeners();
    _timer = Timer(duration, dismiss);
  }

  void dismiss() {
    _timer?.cancel();
    if (_value == null) return;
    _value = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Mount in MaterialApp.builder, above the Navigator, to cover modal routes.
class UiNoticeHost extends StatelessWidget {
  const UiNoticeHost({
    required this.controller,
    required this.child,
    this.closeLabel = 'Dismiss notice',
    super.key,
  });
  final UiNoticeController controller;
  final Widget child;
  final String closeLabel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final notice = controller.value;
      final colors = Theme.of(context).colorScheme;
      final foreground = notice?.isError == true
          ? colors.onError
          : colors.onInverseSurface;
      return Overlay.wrap(
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (notice != null)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 16,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Semantics(
                      liveRegion: true,
                      container: true,
                      child: Material(
                        borderRadius: BorderRadius.circular(
                          UiThemeData.of(context).panelRadius,
                        ),
                        elevation: 4,
                        color: notice.isError
                            ? colors.error
                            : colors.inverseSurface,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Icon(
                                      notice.isError
                                          ? Icons.error_outline
                                          : Icons.check_circle_outline,
                                      color: foreground,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        notice.message,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: foreground,
                                              decoration: TextDecoration.none,
                                            ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: closeLabel,
                                    onPressed: controller.dismiss,
                                    icon: Icon(Icons.close, color: foreground),
                                  ),
                                ],
                              ),
                              if (notice.actionLabel != null &&
                                  notice.onAction != null)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: UiControls.quiet(
                                    onPressed: () {
                                      controller.dismiss();
                                      notice.onAction!();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: foreground,
                                    ),
                                    child: Text(notice.actionLabel!),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
