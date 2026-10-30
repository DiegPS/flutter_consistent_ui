import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() {
  testWidgets(
    'search owns capture when an external controller is not supplied',
    (tester) async {
      var submitted = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiSearchField(
              hintText: 'Search',
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Document 42');
      await tester.tap(find.byTooltip('Search'));
      expect(submitted, 'Document 42');
    },
  );
  testWidgets(
    'large collections use a lazy builder and reserve the scrollbar gutter',
    (tester) async {
      var built = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UiCollectionList.builder(
              itemCount: 1000,
              itemBuilder: (_, index) {
                built++;
                return SizedBox(height: 60, child: Text('Item $index'));
              },
            ),
          ),
        ),
      );
      expect(built, lessThan(30));
      expect(
        tester.widget<ListView>(find.byType(ListView)).padding,
        isA<EdgeInsetsDirectional>(),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'selection and pagination callbacks are independent of a backend',
    (tester) async {
      var selected = 0, page = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UiSegmentedControl<int>(
                  segments: const [
                    UiSegment(value: 1, label: 'One'),
                    UiSegment(value: 2, label: 'Two'),
                  ],
                  selected: 1,
                  onChanged: (value) => selected = value,
                ),
                UiPagination(
                  page: 0,
                  pageCount: 2,
                  label: '1 / 2',
                  onChanged: (value) => page = value,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Two'));
      expect(selected, 2);
      await tester.tap(find.byTooltip('Next page'));
      expect(page, 1);
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [360.0, 1200.0]) {
    testWidgets(
      'fullscreen messenger and global notice stay above the form at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = UiNoticeController();
        addTearDown(controller.dispose);
        var action = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(ThemeData()),
            builder: (context, child) =>
                UiNoticeHost(controller: controller, child: child!),
            home: Scaffold(
              body: Builder(
                builder: (context) => UiControls.primary(
                  onPressed: () => showUiFullscreenDialog<void>(
                    context: context,
                    builder: (context) => UiFullscreenDialog(
                      title: const Text('Editor'),
                      content: UiControls.secondary(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                content: Text('Validation failed'),
                              ),
                            ),
                        child: const Text('Validate'),
                      ),
                      actions: [
                        UiControls.primary(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();
        expect(find.text('Validation failed').hitTestable(), findsOneWidget);
        controller.show(
          UiNotice(
            message: 'Capture retained',
            actionLabel: 'Retry',
            onAction: () => action++,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retry'));
        expect(action, 1);
        expect(find.text('Editor'), findsOneWidget);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(find.text('Editor'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'notice replacement does not let an old timer dismiss the new notice',
    (tester) async {
      final controller = UiNoticeController();
      addTearDown(controller.dispose);
      controller.show(
        const UiNotice(message: 'First'),
        duration: const Duration(seconds: 1),
      );
      await tester.pump(const Duration(milliseconds: 900));
      controller.show(
        const UiNotice(message: 'Second'),
        duration: const Duration(seconds: 2),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.value!.message, 'Second');
      await tester.pump(const Duration(seconds: 2));
      expect(controller.value, isNull);
    },
  );
}
