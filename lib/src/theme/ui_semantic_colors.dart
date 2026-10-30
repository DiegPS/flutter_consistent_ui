import 'package:flutter/material.dart';

/// One accessible semantic color family.
///
/// [strong]/[onStrong] are intended for solid controls and prominent icons.
/// [container]/[onContainer] are intended for badges, notices and selected
/// surfaces. Meaning must always also be conveyed by text or iconography.
@immutable
class UiTone {
  const UiTone({
    required this.strong,
    required this.onStrong,
    required this.container,
    required this.onContainer,
  });

  final Color strong;
  final Color onStrong;
  final Color container;
  final Color onContainer;

  static UiTone lerp(UiTone a, UiTone b, double t) => UiTone(
    strong: Color.lerp(a.strong, b.strong, t)!,
    onStrong: Color.lerp(a.onStrong, b.onStrong, t)!,
    container: Color.lerp(a.container, b.container, t)!,
    onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
  );
}

/// Semantic color source of truth for every Ui surface.
///
/// Product code consumes roles such as [warning] or [success], never a local
/// orange/green literal. This keeps the visual language consistent and makes
/// contrast auditable in one place.
@immutable
class UiSemanticColors extends ThemeExtension<UiSemanticColors> {
  const UiSemanticColors({
    required this.brand,
    required this.success,
    required this.warning,
    required this.info,
    required this.security,
    required this.ai,
    required this.document,
  });

  static const light = UiSemanticColors(
    brand: UiTone(
      strong: Color(0xFFC2410C),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFFFEDD5),
      onContainer: Color(0xFF7C2D12),
    ),
    success: UiTone(
      strong: Color(0xFF047857),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFD1FAE5),
      onContainer: Color(0xFF064E3B),
    ),
    warning: UiTone(
      strong: Color(0xFFB45309),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFFEF3C7),
      onContainer: Color(0xFF78350F),
    ),
    info: UiTone(
      strong: Color(0xFF0369A1),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFE0F2FE),
      onContainer: Color(0xFF0C4A6E),
    ),
    security: UiTone(
      strong: Color(0xFF4338CA),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFEEF2FF),
      onContainer: Color(0xFF312E81),
    ),
    ai: UiTone(
      strong: Color(0xFF7E22CE),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFF3E8FF),
      onContainer: Color(0xFF581C87),
    ),
    document: UiTone(
      strong: Color(0xFF0F766E),
      onStrong: Color(0xFFFFFFFF),
      container: Color(0xFFCCFBF1),
      onContainer: Color(0xFF134E4A),
    ),
  );

  final UiTone brand;
  final UiTone success;
  final UiTone warning;
  final UiTone info;
  final UiTone security;
  final UiTone ai;
  final UiTone document;

  /// Resolves the installed theme and keeps isolated component harnesses on
  /// the same Ui palette when they do not provide an application theme.
  static UiSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<UiSemanticColors>() ??
      fromColorScheme(Theme.of(context).colorScheme);

  /// Default status families adapt to dark surfaces; brand comes from the app.
  static UiSemanticColors fromColorScheme(ColorScheme colors) {
    UiTone adapt(UiTone tone) => colors.brightness == Brightness.light
        ? tone
        : UiTone(
            strong: tone.container,
            onStrong: tone.onContainer,
            container: tone.onContainer,
            onContainer: tone.container,
          );
    return UiSemanticColors(
      brand: UiTone(
        strong: colors.primary,
        onStrong: colors.onPrimary,
        container: colors.primaryContainer,
        onContainer: colors.onPrimaryContainer,
      ),
      success: adapt(light.success),
      warning: adapt(light.warning),
      info: adapt(light.info),
      security: adapt(light.security),
      ai: adapt(light.ai),
      document: adapt(light.document),
    );
  }

  @override
  UiSemanticColors copyWith({
    UiTone? brand,
    UiTone? success,
    UiTone? warning,
    UiTone? info,
    UiTone? security,
    UiTone? ai,
    UiTone? document,
  }) => UiSemanticColors(
    brand: brand ?? this.brand,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    security: security ?? this.security,
    ai: ai ?? this.ai,
    document: document ?? this.document,
  );

  @override
  UiSemanticColors lerp(covariant UiSemanticColors? other, double t) {
    if (other == null) return this;
    return UiSemanticColors(
      brand: UiTone.lerp(brand, other.brand, t),
      success: UiTone.lerp(success, other.success, t),
      warning: UiTone.lerp(warning, other.warning, t),
      info: UiTone.lerp(info, other.info, t),
      security: UiTone.lerp(security, other.security, t),
      ai: UiTone.lerp(ai, other.ai, t),
      document: UiTone.lerp(document, other.document, t),
    );
  }
}
