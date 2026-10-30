import 'dart:convert';
import 'dart:io';

import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('agent index matches every exported declaration and recipe path', () {
    final contract = jsonDecode(
      File('ai/UI_CONTRACT.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final sources = contract['sources'] as Map<String, dynamic>;
    final barrel = File('lib/flutter_consistent_ui.dart').readAsStringSync();
    final exports = RegExp("export '([^']+)';")
        .allMatches(barrel)
        .map((match) => match[1]!)
        .toSet();
    expect(sources.keys.toSet(), exports);
    for (final entry in sources.entries) {
      final text = File('lib/${entry.key}').readAsStringSync();
      final symbols = RegExp(r'\b(?:class|enum|typedef)\s+(Ui\w+)')
          .allMatches(text)
          .map((match) => match[1]!)
          .toSet();
      if (text.contains('Future<T?> showUiFullscreenDialog')) {
        symbols.add('showUiFullscreenDialog');
      }
      expect(
        (entry.value as List<dynamic>).cast<String>().toSet(),
        symbols,
        reason: entry.key,
      );
    }
    final recipes = contract['recipes'] as Map<String, dynamic>;
    for (final path in recipes.values.cast<String>()) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(File(contract['migration'] as String).existsSync(), isTrue);
    expect(File(contract['recipe_entrypoint'] as String).existsSync(), isTrue);
    const config = UiThemeData();
    expect(contract['geometry_defaults'], {
      'controlHeight': config.controlHeight,
      'compactControlHeight': config.compactControlHeight,
      'compactBreakpoint': config.compactBreakpoint,
      'fontSize': config.fontSize,
      'lineHeight': config.lineHeight,
      'formSpacing': config.formSpacing,
    });
    final dependencyBlock = File('pubspec.yaml')
        .readAsStringSync()
        .replaceAll('\r\n', '\n')
        .split('\ndependencies:\n')
        .last
        .split('\ndev_dependencies:')
        .first;
    expect(contract['runtime_dependencies'], ['flutter']);
    expect(
      RegExp(
        r'^  (\w+):',
        multiLine: true,
      ).allMatches(dependencyBlock).map((match) => match[1]!).toList(),
      ['flutter'],
    );
  });
}
