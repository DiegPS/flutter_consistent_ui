import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ui_control_metrics.dart';
import '../theme/ui_theme.dart';

/// Construction boundary for native form controls and actions.
/// Geometry is shared; callbacks, keys, validation and controller ownership are not.
abstract final class UiControls {
  static TextStyle _text(BuildContext context, TextStyle? style) =>
      UiControlMetrics.textStyle(context)
          .merge(style)
          .copyWith(
            fontSize: UiThemeData.of(context).fontSize,
            height:
                UiThemeData.of(context).lineHeight /
                UiThemeData.of(context).fontSize,
          );
  static ButtonStyle _action(BuildContext context, ButtonStyle? style) =>
      UiControlMetrics.action(context).merge(style);

  static Widget input({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    InputDecoration? decoration = const InputDecoration(),
    bool? enabled,
    bool autofocus = false,
    bool obscureText = false,
    bool readOnly = false,
    bool enableSuggestions = true,
    bool autocorrect = true,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int? maxLength,
    int? maxLines = 1,
    int? minLines,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => TextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      decoration: decoration == null
          ? null
          : UiControlMetrics.decoration(context, decoration),
      style: _text(context, style),
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      readOnly: readOnly,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      inputFormatters: inputFormatters,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    ),
  );

  static Widget formInput({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? initialValue,
    InputDecoration? decoration = const InputDecoration(),
    bool? enabled,
    bool autofocus = false,
    bool obscureText = false,
    bool readOnly = false,
    bool enableSuggestions = true,
    bool autocorrect = true,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    TextStyle? style,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    AutovalidateMode? autovalidateMode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => TextFormField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      decoration: decoration == null
          ? null
          : UiControlMetrics.decoration(context, decoration),
      style: _text(context, style),
      enabled: enabled,
      autofocus: autofocus,
      obscureText: obscureText,
      readOnly: readOnly,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      inputFormatters: inputFormatters,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: onSaved,
    ),
  );

  static Widget select<T>({
    Key? key,
    T? initialValue,
    required List<DropdownMenuItem<T>>? items,
    required ValueChanged<T?>? onChanged,
    InputDecoration? decoration,
    bool isExpanded = true,
    TextStyle? style,
    FormFieldValidator<T>? validator,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => DropdownButtonFormField<T>(
      key: key,
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      isExpanded: isExpanded,
      isDense: true,
      itemHeight: null,
      style: _text(context, style),
      decoration: UiControlMetrics.decoration(
        context,
        decoration ?? const InputDecoration(),
        select: true,
      ),
      validator: validator,
    ),
  );

  static Widget primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => FilledButton(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      child: child,
    ),
  );
  static Widget primaryIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => FilledButton.icon(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      icon: icon,
      label: label,
    ),
  );
  static Widget tonal({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => FilledButton.tonal(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      child: child,
    ),
  );
  static Widget tonalIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => FilledButton.tonalIcon(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      icon: icon,
      label: label,
    ),
  );
  static Widget secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => OutlinedButton(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      child: child,
    ),
  );
  static Widget secondaryIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => OutlinedButton.icon(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      icon: icon,
      label: label,
    ),
  );
  static Widget quiet({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => TextButton(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      child: child,
    ),
  );
  static Widget quietIcon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
  }) => Builder(
    key: key == null ? null : ValueKey<Key>(key),
    builder: (context) => TextButton.icon(
      key: key,
      onPressed: onPressed,
      style: _action(context, style),
      icon: icon,
      label: label,
    ),
  );
}
