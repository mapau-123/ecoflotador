import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../models/vehicle_state.dart';
import '../../models/app_settings.dart';
import '../../providers/eco_flotador_scope.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/hmi_card.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/telemetry_gauge.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoFlotadorScope.of(context);
    final telemetry = controller.telemetry;
    final vehicle = controller.vehicle;
    final settings = controller.settings;
    final alerts = buildSystemAlerts(telemetry, vehicle, settings);

    final binColor = telemetry.binPercent >= settings.binFullThreshold
        ? AppColors.danger
        : telemetry.binPercent >= settings.binWarningThreshold
        ? AppColors.warning
        : AppColors.ecoGreen;
    final batteryColor =
        telemetry.batteryPercent <= settings.lowBatteryThreshold
        ? AppColors.warning
        : AppColors.lime;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                title: 'Telemetría',
                subtitle: telemetry.receivedAt == null
                    ? 'Esperando la primera lectura'
                    : 'Datos actualizados automáticamente',
                trailing: StatusPill(
                  label: vehicle.isConnected ? 'EN LÍNEA' : 'SIN DATOS',
                  color: vehicle.isConnected
                      ? AppColors.ecoGreen
                      : AppColors.danger,
                  icon: Icons.sensors_rounded,
                ),
              ),
              const SizedBox(height: 14),
              HmiCard(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final gauges = [
                      TelemetryGauge(
                        label: 'Batería',
                        value: telemetry.batteryPercent,
                        subtitle: '${telemetry.voltage.toStringAsFixed(1)} V',
                        color: batteryColor,
                        icon: Icons.battery_charging_full_rounded,
                      ),
                      TelemetryGauge(
                        label: 'Recipiente',
                        value: telemetry.binPercent,
                        subtitle: _binState(telemetry.binPercent, settings),
                        color: binColor,
                        icon: Icons.delete_sweep_rounded,
                      ),
                    ];
                    if (constraints.maxWidth >= 520) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: gauges
                            .map((gauge) => Expanded(child: gauge))
                            .toList(),
                      );
                    }
                    return Column(
                      children: [
                        gauges.first,
                        const SizedBox(height: 22),
                        gauges.last,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _LiveStatusCard(
                      title: 'Movimiento',
                      value: vehicle.movement == Movement.stopped
                          ? 'Detenido'
                          : 'Activo',
                      detail: _movementLabel(vehicle.movement),
                      icon: Icons.directions_boat_rounded,
                      active: vehicle.movement != Movement.stopped,
                    ),
                    _LiveStatusCard(
                      title: 'Banda',
                      value: vehicle.beltRunning ? 'Activa' : 'Detenida',
                      detail: 'Velocidad ${vehicle.beltSpeed}%',
                      icon: Icons.autorenew_rounded,
                      active: vehicle.beltRunning,
                    ),
                    _LiveStatusCard(
                      title: 'Bluetooth',
                      value: vehicle.isConnected ? 'Conectado' : 'Desconectado',
                      detail: vehicle.deviceName ?? 'Sin dispositivo',
                      icon: Icons.bluetooth_rounded,
                      active: vehicle.isConnected,
                    ),
                  ];
                  final columns = constraints.maxWidth >= 700 ? 3 : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards
                        .map((card) => SizedBox(width: width, child: card))
                        .toList(),
                  );
                },
              ),
              if (settings.demoMode) ...[
                const SizedBox(height: 22),
                const SectionHeading(
                  title: 'Simulación de alertas',
                  subtitle: 'Herramientas para la presentación ante el jurado',
                ),
                const SizedBox(height: 12),
                HmiCard(
                  child: Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      ActionChip(
                        avatar: const Icon(
                          Icons.battery_alert_rounded,
                          size: 19,
                        ),
                        label: const Text('Batería baja'),
                        onPressed: () => controller.simulateAlert(battery: 15),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.warning_amber_rounded,
                          size: 19,
                        ),
                        label: const Text('Recipiente casi lleno'),
                        onPressed: () => controller.simulateAlert(bin: 82),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.delete_rounded, size: 19),
                        label: const Text('Recipiente lleno'),
                        onPressed: () => controller.simulateAlert(bin: 96),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.restart_alt_rounded, size: 19),
                        label: const Text('Restablecer'),
                        onPressed: () =>
                            controller.simulateAlert(battery: 85, bin: 68),
                      ),
                    ],
                  ),
                ),
              ],
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 22),
                ...alerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AlertCard(alert: alert),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _movementLabel(Movement movement) => switch (movement) {
    Movement.forward => 'Avanzando',
    Movement.backward => 'Retrocediendo',
    Movement.left => 'Girando a la izquierda',
    Movement.right => 'Girando a la derecha',
    Movement.stopped => 'Motores en reposo',
  };

  static String _binState(int value, AppSettings settings) {
    if (value >= settings.binFullThreshold) return 'Lleno';
    if (value >= settings.binWarningThreshold) return 'Atención';
    return 'Nivel normal';
  }
}

class _LiveStatusCard extends StatelessWidget {
  const _LiveStatusCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.active,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ecoGreen : AppColors.muted;
    return HmiCard(
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  detail,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
