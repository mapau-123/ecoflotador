import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../providers/eco_flotador_controller.dart';
import 'hmi_card.dart';
import 'status_pill.dart';

class BeltControl extends StatelessWidget {
  const BeltControl({
    super.key,
    required this.controller,
    required this.enabled,
  });

  final EcoFlotadorController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final running = controller.vehicle.beltRunning;
    final speed = controller.vehicle.beltSpeed;
    return HmiCard(
      accent: running ? AppColors.ecoGreen : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BANDA RECOLECTORA',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Control independiente de recolección',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: running ? 'ACTIVA' : 'DETENIDA',
                color: running ? AppColors.ecoGreen : AppColors.muted,
                icon: running ? Icons.autorenew_rounded : Icons.pause_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: enabled && !running
                      ? () => controller.setBeltRunning(true)
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('INICIAR'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled && running
                      ? () => controller.setBeltRunning(false)
                      : null,
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('DETENER'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Velocidad',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '$speed%',
                style: const TextStyle(
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: speed.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '$speed%',
            onChanged: enabled ? controller.setBeltSpeed : null,
          ),
          Row(
            children: [
              _QuickSpeed(
                label: 'Lenta',
                value: 30,
                selected: speed == 30,
                enabled: enabled,
                onPressed: controller.setBeltSpeed,
              ),
              const SizedBox(width: 8),
              _QuickSpeed(
                label: 'Media',
                value: 60,
                selected: speed == 60,
                enabled: enabled,
                onPressed: controller.setBeltSpeed,
              ),
              const SizedBox(width: 8),
              _QuickSpeed(
                label: 'Rápida',
                value: 100,
                selected: speed == 100,
                enabled: enabled,
                onPressed: controller.setBeltSpeed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickSpeed extends StatelessWidget {
  const _QuickSpeed({
    required this.label,
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final int value;
  final bool selected;
  final bool enabled;
  final ValueChanged<double> onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? AppColors.ecoGreen.withValues(alpha: .16)
              : null,
          foregroundColor: selected ? AppColors.ecoGreen : AppColors.ink,
          side: BorderSide(
            color: selected ? AppColors.ecoGreen : AppColors.divider,
          ),
        ),
        onPressed: enabled ? () => onPressed(value.toDouble()) : null,
        child: Text(label),
      ),
    );
  }
}
