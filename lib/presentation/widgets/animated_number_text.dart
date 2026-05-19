import 'dart:math' as math;

import 'package:flutter/material.dart';

const animatedNumberDefaultEmphasis = AnimatedNumberEmphasis(
  enabled: true,
  maxScale: 1.045,
  colorBlendFactor: 0.16,
  duration: Duration(milliseconds: 360),
  curve: Curves.easeOutCubic,
);

class AnimatedNumberEmphasis {
  const AnimatedNumberEmphasis({
    this.enabled = true,
    this.maxScale = 1.045,
    this.colorBlendFactor = 0.16,
    this.duration = const Duration(milliseconds: 360),
    this.curve = Curves.easeOutCubic,
    this.highlightColor,
  });

  final bool enabled;
  final double maxScale;
  final double colorBlendFactor;
  final Duration duration;
  final Curve curve;
  final Color? highlightColor;
}

class AnimatedNumberText extends StatefulWidget {
  const AnimatedNumberText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimalDigits = 0,
    this.groupThousands = false,
    this.style,
    this.textAlign,
    this.curve = Curves.easeOutCubic,
    this.duration,
    this.emphasis = animatedNumberDefaultEmphasis,
    this.reserveWidth = true,
    this.useTabularFigures = true,
  });

  final num value;
  final String prefix;
  final String suffix;
  final int decimalDigits;
  final bool groupThousands;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Curve curve;
  final Duration? duration;
  final AnimatedNumberEmphasis emphasis;
  final bool reserveWidth;
  final bool useTabularFigures;

  @override
  State<AnimatedNumberText> createState() => _AnimatedNumberTextState();
}

class _AnimatedNumberTextState extends State<AnimatedNumberText>
    with SingleTickerProviderStateMixin {
  late double _previousValue;
  late final AnimationController _emphasisController;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value.toDouble();
    _emphasisController = AnimationController(
      vsync: this,
      duration: widget.emphasis.duration,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedNumberText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emphasis.duration != widget.emphasis.duration) {
      _emphasisController.duration = widget.emphasis.duration;
    }

    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value.toDouble();
      if (widget.emphasis.enabled) {
        _emphasisController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _emphasisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _previousValue, end: widget.value.toDouble()),
      duration: widget.duration ?? _resolveDuration(),
      curve: widget.curve,
      builder: (context, animatedValue, child) {
        return AnimatedBuilder(
          animation: _emphasisController,
          builder: (context, child) {
            final style = DefaultTextStyle.of(
              context,
            ).style.merge(widget.style);
            final effectiveStyle = widget.useTabularFigures
                ? style.copyWith(
                    fontFeatures: [
                      ...?style.fontFeatures,
                      const FontFeature.tabularFigures(),
                    ],
                  )
                : style;
            final pulse = widget.emphasis.enabled
                ? math.sin(
                    CurvedAnimation(
                          parent: _emphasisController,
                          curve: widget.emphasis.curve,
                        ).value *
                        math.pi,
                  )
                : 0.0;

            final text = Transform.scale(
              scale: 1 + ((widget.emphasis.maxScale - 1) * pulse),
              alignment: _resolveAlignment(),
              child: Text(
                _formatValue(animatedValue),
                textAlign: widget.textAlign,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: effectiveStyle.copyWith(
                  color: _resolveAnimatedColor(effectiveStyle.color, pulse),
                ),
              ),
            );

            if (!widget.reserveWidth) {
              return text;
            }

            return SizedBox(
              width: _resolveReservedWidth(context, effectiveStyle),
              child: text,
            );
          },
        );
      },
    );
  }

  Duration _resolveDuration() {
    final scale = math.pow(10, widget.decimalDigits).toDouble();
    final steps = (widget.value.toDouble() - _previousValue).abs() * scale;
    final milliseconds = (220 + steps * 26).clamp(220, 1200).round();
    return Duration(milliseconds: milliseconds);
  }

  String _formatValue(double value) {
    final formattedNumber = widget.decimalDigits == 0
        ? value.round().toString()
        : value.toStringAsFixed(widget.decimalDigits);

    final displayNumber = widget.groupThousands
        ? _groupThousands(formattedNumber)
        : formattedNumber;

    return '${widget.prefix}$displayNumber${widget.suffix}';
  }

  String _groupThousands(String input) {
    final parts = input.split('.');
    final integerPart = parts.first;
    final sign = integerPart.startsWith('-') ? '-' : '';
    final digits = sign.isEmpty ? integerPart : integerPart.substring(1);
    final grouped = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    if (parts.length == 1) {
      return '$sign$grouped';
    }

    return '$sign$grouped.${parts[1]}';
  }

  double _resolveReservedWidth(BuildContext context, TextStyle style) {
    final currentLabel = _formatValue(widget.value.toDouble());
    final previousLabel = _formatValue(_previousValue);
    final maxLabel = currentLabel.length >= previousLabel.length
        ? currentLabel
        : previousLabel;

    final painter = TextPainter(
      text: TextSpan(text: maxLabel, style: style),
      textDirection: Directionality.of(context),
      textAlign: widget.textAlign ?? TextAlign.start,
      maxLines: 1,
    )..layout();

    return painter.width + 4;
  }

  Alignment _resolveAlignment() {
    return switch (widget.textAlign) {
      TextAlign.center => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
  }

  Color? _resolveAnimatedColor(Color? baseColor, double pulse) {
    if (!widget.emphasis.enabled || baseColor == null) {
      return baseColor;
    }

    final highlightColor = widget.emphasis.highlightColor ?? Colors.white;
    return Color.lerp(
      baseColor,
      highlightColor,
      widget.emphasis.colorBlendFactor * pulse,
    );
  }
}
