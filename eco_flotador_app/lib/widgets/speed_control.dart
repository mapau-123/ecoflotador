import 'package:flutter/material.dart';
 
import '../app/theme/app_colors.dart';
import '../providers/eco_flotador_controller.dart';
import 'hmi_card.dart';
 
/// Slider de 3 posiciones para elegir la velocidad de los motores
/// de propulsión (lento / medio / rápido). Envía "VEL:1|2|3" al ESP32
/// a través del controlador cada vez que cambia.
class SpeedControl extends StatelessWidget {
  const SpeedControl({
    super.key,
    required this.controller,
    required this.enabled,
  });
 
  final EcoFlotadorController controller;
  final bool enabled;
 
  @override
  Widget build(BuildContext context) {
    final level = controller.motorSpeedLevel;
 
    return HmiCard(
      accent: enabled ? AppColors.ecoGreen : AppColors.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VELOCIDAD DE MOTORES',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? 'Nivel actual: ${_speedLabel(level)}'
                : 'Conecte el ESP32 para ajustar la velocidad',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Slider(
            value: level.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            activeColor: AppColors.ecoGreen,
            label: _speedLabel(level),
            onChanged: enabled
                ? (value) => controller.setMotorSpeed(value.round())
                : null,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lento',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              Text(
                'Medio',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              Text(
                'Rápido',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  static String _speedLabel(int level) => switch (level) {
    1 => 'LENTO',
    2 => 'MEDIO',
    _ => 'RÁPIDO',
  };
}
 
