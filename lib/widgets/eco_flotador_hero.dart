import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import 'status_pill.dart';

class EcoFlotadorHero extends StatefulWidget {
  const EcoFlotadorHero({super.key, required this.operational});

  final bool operational;

  @override
  State<EcoFlotadorHero> createState() => _EcoFlotadorHeroState();
}

class _EcoFlotadorHeroState extends State<EcoFlotadorHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C3C48), Color(0xFF071E29)],
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OceanPainter(animation: _controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 560;
                  final copy = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ECO FLOTADOR',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Sistema de recolección de residuos',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      StatusPill(
                        label: widget.operational
                            ? 'SISTEMA OPERATIVO'
                            : 'SISTEMA EN ESPERA',
                        color: widget.operational
                            ? AppColors.ecoGreen
                            : AppColors.warning,
                        icon: Icons.bolt_rounded,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bahía de Cartagena · HMI móvil',
                        style: TextStyle(
                          color: AppColors.aqua,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );

                  const illustration = RepaintBoundary(
                    child: SizedBox(
                      width: 210,
                      height: 145,
                      child: CustomPaint(painter: _BoatPainter()),
                    ),
                  );

                  return wide
                      ? Row(
                          children: [
                            Expanded(child: copy),
                            const SizedBox(width: 16),
                            illustration,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            copy,
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: illustration,
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OceanPainter extends CustomPainter {
  _OceanPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.aqua.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.seaBlue.withValues(alpha: 0.22);
    for (var row = 0; row < 3; row++) {
      final path = Path();
      final baseY = size.height - 30 - row * 13;
      for (double x = 0; x <= size.width; x += 4) {
        final y =
            baseY +
            math.sin((x / 26) + animation.value * math.pi * 2 + row) * 4;
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, wave);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanPainter oldDelegate) => false;
}

class _BoatPainter extends CustomPainter {
  const _BoatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .53, size.height * .78),
        width: size.width * .72,
        height: 22,
      ),
      shadow,
    );

    final hull = Path()
      ..moveTo(size.width * .12, size.height * .55)
      ..lineTo(size.width * .86, size.height * .55)
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .84,
        size.width * .47,
        size.height * .86,
      )
      ..quadraticBezierTo(
        size.width * .20,
        size.height * .82,
        size.width * .12,
        size.height * .55,
      )
      ..close();
    canvas.drawPath(
      hull,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.ecoGreen, Color(0xFF168C70)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final deck = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .28,
        size.height * .34,
        size.width * .43,
        size.height * .25,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(deck, Paint()..color = AppColors.ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .35,
          size.height * .21,
          size.width * .27,
          size.height * .18,
        ),
        const Radius.circular(9),
      ),
      Paint()..color = AppColors.seaBlue,
    );

    final belt = Paint()
      ..color = AppColors.deepOcean
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .08, size.height * .42),
      Offset(size.width * .34, size.height * .68),
      belt,
    );
    final slat = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 2;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.11 + i * .045);
      final y = size.height * (.44 + i * .043);
      canvas.drawLine(Offset(x - 5, y + 5), Offset(x + 5, y - 5), slat);
    }

    final solar = Paint()..color = const Color(0xFF156B89);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .42,
          size.height * .26,
          size.width * .3,
          size.height * .12,
        ),
        const Radius.circular(4),
      ),
      solar,
    );
    final solarLine = Paint()
      ..color = AppColors.aqua.withValues(alpha: .55)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * (.42 + .075 * i);
      canvas.drawLine(
        Offset(x, size.height * .26),
        Offset(x, size.height * .38),
        solarLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
