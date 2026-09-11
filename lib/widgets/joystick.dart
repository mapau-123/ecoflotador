import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../models/vehicle_state.dart';

class Joystick extends StatefulWidget {
  const Joystick({
    super.key,
    required this.enabled,
    required this.movement,
    required this.onMove,
    required this.onStop,
  });

  final bool enabled;
  final Movement movement;
  final ValueChanged<Movement> onMove;
  final VoidCallback onStop;

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _knob = Offset.zero;

  void _update(Offset local, double size) {
    if (!widget.enabled) return;
    final center = Offset(size / 2, size / 2);
    var delta = local - center;
    const radiusFactor = .27;
    final maxRadius = size * radiusFactor;
    if (delta.distance > maxRadius) {
      delta = Offset.fromDirection(delta.direction, maxRadius);
    }
    setState(() => _knob = delta);

    final normalized = delta.distance / maxRadius;
    if (normalized < .28) {
      widget.onMove(Movement.stopped);
      return;
    }

    final x = delta.dx.abs();
    final y = delta.dy.abs();
    if (y >= x) {
      widget.onMove(delta.dy < 0 ? Movement.forward : Movement.backward);
    } else {
      widget.onMove(delta.dx < 0 ? Movement.left : Movement.right);
    }
  }

  void _release() {
    setState(() => _knob = Offset.zero);
    widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Joystick de control del Eco Flotador',
      enabled: widget.enabled,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, 310.0);
          return Center(
            child: GestureDetector(
              onPanDown: (event) => _update(event.localPosition, size),
              onPanUpdate: (event) => _update(event.localPosition, size),
              onPanEnd: (_) => _release(),
              onPanCancel: _release,
              child: AnimatedOpacity(
                opacity: widget.enabled ? 1 : .38,
                duration: const Duration(milliseconds: 200),
                child: SizedBox.square(
                  dimension: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF164554), Color(0xFF09232D)],
                          ),
                          border: Border.all(
                            color: AppColors.seaBlue.withValues(alpha: .45),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.seaBlue.withValues(alpha: .12),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      ...const [
                        Positioned(
                          top: 20,
                          child: _DirectionIcon(
                            Icons.keyboard_arrow_up_rounded,
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          child: _DirectionIcon(
                            Icons.keyboard_arrow_down_rounded,
                          ),
                        ),
                        Positioned(
                          left: 20,
                          child: _DirectionIcon(
                            Icons.keyboard_arrow_left_rounded,
                          ),
                        ),
                        Positioned(
                          right: 20,
                          child: _DirectionIcon(
                            Icons.keyboard_arrow_right_rounded,
                          ),
                        ),
                      ],
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 75),
                        transform: Matrix4.translationValues(
                          _knob.dx,
                          _knob.dy,
                          0,
                        ),
                        width: size * .34,
                        height: size * .34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.movement == Movement.stopped
                                ? const [AppColors.oceanLight, AppColors.ocean]
                                : const [AppColors.ecoGreen, Color(0xFF199C78)],
                          ),
                          border: Border.all(
                            color: AppColors.aqua.withValues(alpha: .45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ecoGreen.withValues(
                                alpha: widget.movement == Movement.stopped
                                    ? 0
                                    : .28,
                              ),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          size: 40,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DirectionIcon extends StatelessWidget {
  const _DirectionIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: AppColors.muted, size: 33);
  }
}
