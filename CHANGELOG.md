# Changelog

## 0.4.1

- Recalculate metric row heights when descendant content changes asynchronously,
  including growth and shrinkage without rebuilding the grid. Preserve equal
  surfaces, LayoutBuilder support and natural accessible content height.

## 0.4.0

- Add UiSurface / UiSurface.inverse to scope text, icons and native button
  palettes coherently, including inherited explicit product button colors.
- Preserve fonts, geometry and theme extensions; native primary/tonal pairs
  remain distinct. Explicit descendant colors still belong to the consumer.
- Add contrast regressions for light/dark parents, normal/inverse surfaces,
  recovery buttons, icons, disabled buttons and primary/tonal actions.

## 0.3.0

- Add UiStatCard.adaptive; keep the explicit constructor's behavior unchanged.
- Make selects expanded by default, with natural menu item height; callers can
  opt out via isExpanded:false. This avoids overflow with large text.
- Replace intrinsic metric row sizing with bounded two-pass layout, supporting
  LayoutBuilder children, matching row heights, RTL and hit testing.
- Add machine-readable public API index and agent-oriented adoption rules,
  checked against exports, geometry defaults and runtime dependencies.
- Add three executable, tested composition recipes without a hosted catalog.
- Expand regression coverage for 599/600 boundaries, 300% text, fractional DPR,
  local panel adaptation and exact editor-state preservation while resizing.

## 0.2.1

- Opt-in compact horizontal composition for UiStatCard on small viewports.

## 0.2.0

- `UiStatCard`: vertical statistics with category, description and optional action.
- `UiSplitView`: adaptive natural-height columns preserving children on resize.

## 0.1.0

- Independent Flutter package extracted from a production application.
- Configurable painted control geometry, with native validation, focus and keys.
- Adaptive forms, collection cards, metrics, navigation and segmented controls.
- Theme/semantic palette, fullscreen dialogs, local messages and global notices.
- Standalone example and regression tests; no application or networking dependency.
