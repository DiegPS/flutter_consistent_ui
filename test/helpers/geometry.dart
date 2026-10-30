import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Rect visibleField(WidgetTester tester, Finder field) {
  final decorator = find.descendant(
    of: field,
    matching: find.byType(InputDecorator),
  );
  final text = find
      .descendant(of: decorator, matching: find.byType(Text))
      .first;
  final box = InputDecorator.containerOf(tester.element(text))!;
  return box.localToGlobal(Offset.zero) & box.size;
}
