# flutter_consistent_ui: agent entrypoint

Read `ai/UI_CONTRACT.json` first. It indexes the public API, constraints,
ownership, defaults and executable recipes. Read only the indexed source files
needed for the task; Dart declarations are authoritative for signatures.

- Use the public barrel, never private `src/` imports from consumers.
- Use `UiThemeData` for geometry, consumer ThemeData for font/brand, and
  UiSemanticColors for semantic roles. Do not copy widgets into applications.
- Do not put fixed outer heights around fields. Helpers/errors/multiline text
  and scaled labels must retain natural height. Never disable TextScaler to fit.
- Preserve keys, controllers, focus, drafts and callbacks across responsive changes.
- Keep runtime independent of networking, state management, business models,
  native plugins and credentials. Only Flutter SDK is a runtime dependency.
- For adoption, start from `example/lib/recipes/` and `ai/MIGRATION.md`.
- Verify painted input borders and Material button surfaces, not outer boxes.
- Run `dart analyze --fatal-infos`, `flutter test --coverage`, and example tests.
  Do not regenerate goldens to hide regressions; inspect intentional changes.
- Do not activate CI, publish to pub.dev, move existing tags, or upgrade
  consumers automatically. Record API/behavior changes in CHANGELOG.md.
