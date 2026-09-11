import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../providers/eco_flotador_scope.dart';
import '../../providers/eco_flotador_controller.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/eco_flotador_hero.dart';
import '../../widgets/hmi_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final binStatus = telemetry.binPercent >= settings.binFullThreshold
        ? 'Lleno'
        : telemetry.binPercent >= settings.binWarningThreshold
        ? 'Atención'
        : 'Normal';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EcoFlotadorHero(
                operational: vehicle.isConnected || settings.demoMode,
              ),
              const SizedBox(height: 26),
              const SectionHeading(
                title: 'Estado general',
                subtitle: 'Lectura instantánea del prototipo',
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 520 ? 2 : 1;
                  final itemWidth = (width - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: MetricCard(
                          title: 'Capacidad',
                          value: '${telemetry.binPercent}%',
                          icon: Icons.delete_sweep_rounded,
                          color: binColor,
                          progress: telemetry.binPercent / 100,
                          status: binStatus,
                          statusColor: binColor,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: MetricCard(
                          title: 'Batería',
                          value: '${telemetry.batteryPercent}%',
                          subtitle: '${telemetry.voltage.toStringAsFixed(1)} V',
                          icon: Icons.battery_charging_full_rounded,
                          color:
                              telemetry.batteryPercent <=
                                  settings.lowBatteryThreshold
                              ? AppColors.warning
                              : AppColors.lime,
                          progress: telemetry.batteryPercent / 100,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: MetricCard(
                          title: 'Bluetooth',
                          value: vehicle.isConnected
                              ? 'Conectado'
                              : 'Sin enlace',
                          subtitle: vehicle.deviceName ?? 'Sin dispositivo',
                          icon: Icons.bluetooth_connected_rounded,
                          color: vehicle.isConnected
                              ? AppColors.seaBlue
                              : AppColors.danger,
                          status: vehicle.isConnected
                              ? 'Conectado'
                              : 'Desconectado',
                          statusColor: vehicle.isConnected
                              ? AppColors.ecoGreen
                              : AppColors.danger,
                          animateValue: false,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _SystemCard(controller: controller),
                      ),
                    ],
                  );
                },
              ),
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 26),
                SectionHeading(
                  title: 'Alertas',
                  subtitle: '${alerts.length} aviso(s) activo(s)',
                ),
                const SizedBox(height: 12),
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
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.controller});

  final EcoFlotadorController controller;

  @override
  Widget build(BuildContext context) {
    final vehicle = controller.vehicle;
    return HmiCard(
      accent: AppColors.aqua,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.aqua.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.settings_input_component_rounded,
                  color: AppColors.aqua,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'SISTEMA',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const StatusPill(label: 'Operativo', color: AppColors.ecoGreen),
            ],
          ),
          const SizedBox(height: 17),
          _StatusRow(
            label: 'Motores',
            value: vehicle.motorsActive ? 'Activos' : 'Listos',
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: 'Banda',
            value: vehicle.beltRunning ? 'Activa' : 'Detenida',
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
