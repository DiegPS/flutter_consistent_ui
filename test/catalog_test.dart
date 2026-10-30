import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

void main() {
  test(
    'runtime code is independent of its source application and services',
    () {
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final source = file.readAsStringSync();
        for (final forbidden in [
          'package:onauto_app',
          'package:dio',
          'package:flutter_riverpod',
          "import 'dart:io'",
        ]) {
          expect(source, isNot(contains(forbidden)));
        }
      }
    },
  );
  for (final width in [390.0, 1200.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('public components render at $width / $brightness', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.apply(
              ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.teal,
                  brightness: brightness,
                ),
              ),
            ),
            home: Scaffold(
              body: UiPage(
                scrollable: true,
                child: UiFormFields(
                  children: [
                    UiPageHeader(
                      title: const Text('Header'),
                      subtitle: const Text('Description'),
                      actions: [
                        UiControls.primary(
                          onPressed: () {},
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                    UiPageToolbar(
                      actions: [
                        UiControls.secondary(
                          onPressed: () {},
                          child: const Text('Export'),
                        ),
                      ],
                    ),
                    UiFormSection(
                      title: 'Section',
                      description: 'Supporting text',
                      child: UiControls.input(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Read only',
                        ),
                      ),
                    ),
                    UiMetricCard(
                      value: r'$1,234.50',
                      label: 'Metric',
                      icon: Icons.analytics,
                      animated: true,
                      deltaPercent: -10,
                      sparklineData: const [1, 3, 2],
                      onTap: () {},
                    ),
                    const UiCountUpText(value: 'plain text'),
                    const UiCountUpText(value: '12'),
                    const UiSparkline(data: []),
                    const UiSparkline(data: [3]),
                    const UiSparkline(data: [4, 4], fill: false),
                    for (final tone in UiCollectionBadgeTone.values)
                      UiCollectionBadge(
                        label: tone.name,
                        tone: tone,
                        icon: Icons.info_outline,
                      ),
                    UiCollectionItem(
                      title: const Text('Item'),
                      leadingIcon: Icons.folder,
                      semanticsLabel: 'Open item',
                      onOpen: () {},
                      trailingAction: IconButton(
                        tooltip: 'More',
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                      secondaryActions: [
                        UiControls.secondary(
                          onPressed: () {},
                          child: const Text('Action'),
                        ),
                      ],
                      details: const [
                        UiCollectionDetail(
                          icon: Icons.info,
                          text: 'Detail',
                          prominent: true,
                          monospace: true,
                        ),
                      ],
                    ),
                    const UiCollectionItem(title: Text('Informational item')),
                    UiEmptyState(
                      icon: Icons.folder_open,
                      title: 'Empty',
                      description: 'No data yet',
                      actionLabel: 'Create',
                      onAction: () {},
                      secondaryActionLabel: 'Learn more',
                      onSecondaryAction: () {},
                    ),
                    UiPagination(
                      page: 1,
                      pageCount: 3,
                      label: 'Page 2',
                      onChanged: (_) {},
                    ),
                    UiBottomNavigation(
                      items: const [
                        UiBottomNavigationItem(label: 'Home', icon: Icons.home),
                        UiBottomNavigationItem(
                          label: 'Settings',
                          icon: Icons.settings,
                        ),
                      ],
                      selectedIndex: 0,
                      onDestinationSelected: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  test('semantic extensions can be copied and interpolated', () {
    const a = UiSemanticColors.light;
    final b = UiSemanticColors.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
    );
    final c = a.copyWith(
      brand: b.brand,
      success: b.success,
      warning: b.warning,
      info: b.info,
      security: b.security,
      ai: b.ai,
      document: b.document,
    );
    expect(c.brand, b.brand);
    expect(c.success, b.success);
    expect(a.lerp(b, 0).info.strong, a.info.strong);
    expect(a.lerp(b, 1).document.strong, b.document.strong);
    expect(a.lerp(null, .5), same(a));
  });
}
