import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../models/vehicle_state.dart';
import '../providers/eco_flotador_controller.dart';
import 'status_pill.dart';

class BluetoothIndicator extends StatelessWidget {
  const BluetoothIndicator({
    super.key,
    required this.controller,
    this.compact = false,
  });

  final EcoFlotadorController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = controller.vehicle.connection;
    final connected = state == BluetoothConnectionState.connected;
    final working =
        state == BluetoothConnectionState.connecting ||
        state == BluetoothConnectionState.scanning;
    final color = connected
        ? AppColors.ecoGreen
        : working
        ? AppColors.warning
        : AppColors.danger;
    final label = connected
        ? compact
              ? 'En línea'
              : controller.vehicle.deviceName ?? 'Conectado'
        : working
        ? 'Conectando'
        : state == BluetoothConnectionState.lost
        ? 'Conexión perdida'
        : 'Sin conexión';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: StatusPill(
        key: ValueKey(label),
        label: label,
        color: color,
        icon: connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
      ),
    );
  }
}
