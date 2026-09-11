import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../models/app_settings.dart';
import '../models/telemetry.dart';
import '../models/vehicle_state.dart';

class SystemAlert {
  const SystemAlert({
    required this.title,
    required this.detail,
    required this.color,
    required this.icon,
  });

  final String title;
  final String detail;
  final Color color;
  final IconData icon;
}

List<SystemAlert> buildSystemAlerts(
  Telemetry telemetry,
  VehicleState vehicle,
  AppSettings settings,
) {
  final alerts = <SystemAlert>[];

  if (vehicle.connection == BluetoothConnectionState.lost ||
      (!vehicle.isConnected && !settings.demoMode)) {
    alerts.add(
      const SystemAlert(
        title: 'Conexión perdida',
        detail: 'Los controles de movimiento están deshabilitados.',
        color: AppColors.danger,
        icon: Icons.bluetooth_disabled_rounded,
      ),
    );
  }
  if (telemetry.batteryPercent <= settings.lowBatteryThreshold) {
    alerts.add(
      const SystemAlert(
        title: 'Batería baja',
        detail: 'Regrese el prototipo para realizar la recarga.',
        color: AppColors.warning,
        icon: Icons.battery_alert_rounded,
      ),
    );
  }
  if (telemetry.binPercent >= settings.binFullThreshold) {
    alerts.add(
      const SystemAlert(
        title: 'Recipiente lleno',
        detail: 'Detenga la recolección y vacíe el recipiente.',
        color: AppColors.danger,
        icon: Icons.delete_rounded,
      ),
    );
  } else if (telemetry.binPercent >= settings.binWarningThreshold) {
    alerts.add(
      const SystemAlert(
        title: 'Recipiente casi lleno',
        detail: 'Prepare el vaciado del recipiente.',
        color: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      ),
    );
  }

  return alerts;
}

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert});

  final SystemAlert alert;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .96, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: alert.color.withValues(alpha: .45)),
        ),
        child: Row(
          children: [
            Icon(alert.icon, color: alert.color, size: 27),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      color: alert.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.detail,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
