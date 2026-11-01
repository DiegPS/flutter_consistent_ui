import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_consistent_ui/flutter_consistent_ui.dart';

@Preview(name: 'Searchable selection and disclosure', size: Size(400, 600))
Widget selectionDisclosurePreview() => MaterialApp(
  theme: UiTheme.apply(ThemeData(useMaterial3: true)),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: UiDisclosure(
        title: const Text('Selection options'),
        initiallyExpanded: true,
        children: [
          UiControls.searchableSelect<String>(
            label: const Text('Option'),
            entries: const [
              DropdownMenuEntry(value: 'first', label: 'First option'),
              DropdownMenuEntry(value: 'second', label: 'Second option'),
            ],
            onSelected: (_) {},
          ),
        ],
      ),
    ),
  ),
);
