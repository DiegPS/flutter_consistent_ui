# Adoption procedure for agents

1. Inspect the consumer theme, SDK, dependency policy and shared control entrypoints.
2. Pin a real Git tag/commit; keep path dependencies local only. Run pub get.
3. Apply UiTheme to the consumer ThemeData. Preserve existing ThemeExtensions.
   Map business tones to UiSemanticColors if the consumer already owns a palette.
4. Replace shared construction boundaries first. Type aliases can preserve old
   names without duplicating widget implementations. Do not mass-rewrite business
   screens before proving the shared boundary works.
5. Preserve validators/controllers/keys/callbacks. Remove redundant `isDense`
   arguments: field geometry belongs to the library. Selects expand by default;
   explicitly opt out only for deliberately shrink-wrapped controls.
6. Remove finite heights around whole decorated fields. Measure InputDecorator's
   container separately from helper/error/counter space. Buttons use minimums,
   not finite fixed/max heights. Infinite fixed axes clear old caller overrides;
   they do not force an infinite rendered size in Flutter ButtonStyle.
7. Move forms to UiFormFields/Grid. Keep stable entity keys if reordered.
8. Lists: migrate UiCollectionViewport with the list if overlay padding is used.
   Page content requires bounded height. Use builder for large lists.
9. Use UiStatCard.adaptive for automatic presentation, `.new(compact: ...)` for
   explicit presentation. Do not manufacture trends or infer numbers from text.
10. Fullscreen: use showUiFullscreenDialog and its builder context for snackbars;
    use a per-app UiNoticeController/UiNoticeHost for above-route notices.
11. Test narrow/wide/local panes, text 1/2/3, fractional DPR, validation spacing,
    focus/capture on resize, callbacks, overlays, existing flows. Compare goldens
    only after measuring invariants. Do not claim physical device tests were run.

## Customization ownership

- Consumer: font registration/family, ColorScheme, UiSemanticColors, wording,
  locale/formatting, routes, authorization, API/errors, persistence and validation.
- UiThemeData: control border height, scale-aware line/font metrics, padding,
  radii, field spacing and minimum grid field width.
- Individual controls: enabled/busy state, native controllers/formatters,
  validator/callbacks and documented presentation options. Local action styles
  may change color/shape, not override the central geometry policy.
- Recipes: application compositions, not new backend behavior. Copy/adapt a
  recipe's consumer shell; depend on the package for the actual UI components.
