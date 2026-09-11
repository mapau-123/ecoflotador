import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

class TelemetryGauge extends StatelessWidget {
  const TelemetryGauge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, $value por ciento',
      child: Column(
        children: [
          SizedBox.square(
            dimension: 168,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value / 100),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return CustomPaint(
                  painter: _GaugePainter(value: animatedValue, color: color),
                  child: child,
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 5),
                    Text(
                      '$value%',
                      style: const TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 9;
    const start = math.pi * .75;
    const sweep = math.pi * 1.5;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final background = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;
    final foreground = Paint()
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [color.withValues(alpha: .55), color],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;
    canvas.drawArc(bounds, start, sweep, false, background);
    canvas.drawArc(
      bounds,
      start,
      sweep * value.clamp(0, 1).toDouble(),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
