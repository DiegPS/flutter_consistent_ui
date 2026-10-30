import 'package:flutter/material.dart';

/// Smooth count-up animation for numbers, currencies, and percentages.
///
/// Uses [AutomaticKeepAliveClientMixin] so that scrolling inside a [ListView]
/// does NOT dispose and re-animate from zero on every scroll.
class UiCountUpText extends StatefulWidget {
  const UiCountUpText({
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  /// The formatted display string (e.g. "$1,250.00", "42", "98.5%", "12 h 30 min").
  final String value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  @override
  State<UiCountUpText> createState() => _UiCountUpTextState();
}

class _UiCountUpTextState extends State<UiCountUpText>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static String _formatThousands(String s) {
    final buffer = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final match = RegExp(r'^([^\d\-+]*)([\d,]+(?:\.\d+)?)(.*)$')
        .firstMatch(widget.value.trim());
    if (match == null) {
      return Text(widget.value, style: widget.style);
    }

    final prefix = match.group(1) ?? '';
    final rawNumberStr = (match.group(2) ?? '').replaceAll(',', '');
    final suffix = match.group(3) ?? '';
    final targetNumber = double.tryParse(rawNumberStr);

    if (targetNumber == null) {
      return Text(widget.value, style: widget.style);
    }

    final isInteger = !rawNumberStr.contains('.');
    final decimalPlaces = isInteger ? 0 : rawNumberStr.split('.')[1].length;

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.value),
      tween: Tween<double>(begin: 0.0, end: targetNumber),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, current, child) {
        String formattedNumber;
        if (isInteger) {
          final intStr = current.round().toString();
          formattedNumber = _formatThousands(intStr);
        } else {
          final fixed = current.toStringAsFixed(decimalPlaces);
          final parts = fixed.split('.');
          final intPart = _formatThousands(parts[0]);
          formattedNumber = '$intPart.${parts[1]}';
        }

        return Text('$prefix$formattedNumber$suffix', style: widget.style);
      },
    );
  }
}
