import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../models/bluetooth_device_info.dart';
import '../../providers/eco_flotador_controller.dart';
import '../../providers/eco_flotador_scope.dart';
import '../../widgets/hmi_card.dart';
import '../../widgets/section_heading.dart';
import '../../widgets/status_pill.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EcoFlotadorScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                title: 'Configuración',
                subtitle: 'Conectividad, umbrales y preferencias',
              ),
              const SizedBox(height: 14),
              _BluetoothSection(controller: controller),
              const SizedBox(height: 16),
              _ParametersSection(controller: controller),
              const SizedBox(height: 16),
              _PreferencesSection(controller: controller),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: controller.isSaving
                      ? null
                      : controller.saveSettings,
                  icon: controller.isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    controller.isSaving ? 'GUARDANDO...' : 'GUARDAR CAMBIOS',
                  ),
                ),
              ),
              if (controller.message != null) ...[
                const SizedBox(height: 10),
                Text(
                  controller.message!,
                  style: const TextStyle(color: AppColors.aqua, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BluetoothSection extends StatelessWidget {
  const _BluetoothSection({required this.controller});

  final EcoFlotadorController controller;

  @override
  Widget build(BuildContext context) {
    final connected = controller.vehicle.isConnected;
    return HmiCard(
      accent: connected ? AppColors.seaBlue : null,
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
                      'BLUETOOTH',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Enlace de control y telemetría con ESP32',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: connected ? 'CONECTADO' : 'DESCONECTADO',
                color: connected ? AppColors.ecoGreen : AppColors.danger,
                icon: connected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
              ),
            ],
          ),
          if (connected) ...[
            const SizedBox(height: 16),
            _ConnectedDevice(
              name: controller.vehicle.deviceName ?? 'ESP32',
              onDisconnect: controller.disconnect,
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isScanning ? null : controller.scan,
              icon: controller.isScanning
                  ? const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.radar_rounded),
              label: Text(
                controller.isScanning
                    ? 'BUSCANDO DISPOSITIVOS...'
                    : 'BUSCAR DISPOSITIVOS',
              ),
            ),
          ),
          if (controller.devices.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'DISPOSITIVOS DISPONIBLES',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ...controller.devices.map(
              (device) => _DeviceTile(
                device: device,
                connected: controller.vehicle.deviceName == device.name,
                onConnect: () => controller.connect(device),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConnectedDevice extends StatelessWidget {
  const _ConnectedDevice({required this.name, required this.onDisconnect});

  final String name;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.ecoGreen.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ecoGreen.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.memory_rounded, color: AppColors.ecoGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const Text(
                  'ESP32 · Enlace activo',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onDisconnect, child: const Text('Desconectar')),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.connected,
    required this.onConnect,
  });

  final BluetoothDeviceInfo device;
  final bool connected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.oceanLight,
        child: Icon(Icons.bluetooth_rounded, color: AppColors.aqua),
      ),
      title: Text(
        device.name,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        'Señal ${device.signal} dBm',
        style: const TextStyle(color: AppColors.muted),
      ),
      trailing: connected
          ? const StatusPill(label: 'ACTIVO', color: AppColors.ecoGreen)
          : FilledButton(onPressed: onConnect, child: const Text('Conectar')),
    );
  }
}

class _ParametersSection extends StatelessWidget {
  const _ParametersSection({required this.controller});

  final EcoFlotadorController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    return HmiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PARÁMETROS',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _SettingSlider(
            title: 'Umbral de batería baja',
            value: settings.lowBatteryThreshold.toDouble(),
            suffix: '%',
            min: 5,
            max: 50,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(lowBatteryThreshold: value.round()),
            ),
          ),
          _SettingSlider(
            title: 'Recipiente: atención',
            value: settings.binWarningThreshold.toDouble(),
            suffix: '%',
            min: 50,
            max: 89,
            onChanged: (value) {
              final warning = value
                  .round()
                  .clamp(50, settings.binFullThreshold - 1)
                  .toInt();
              controller.updateSettings(
                settings.copyWith(binWarningThreshold: warning),
              );
            },
          ),
          _SettingSlider(
            title: 'Recipiente: lleno',
            value: settings.binFullThreshold.toDouble(),
            suffix: '%',
            min: 71,
            max: 100,
            onChanged: (value) {
              final full = value
                  .round()
                  .clamp(settings.binWarningThreshold + 1, 100)
                  .toInt();
              controller.updateSettings(
                settings.copyWith(binFullThreshold: full),
              );
            },
          ),
          _SettingSlider(
            title: 'Velocidad máxima',
            value: settings.maxVehicleSpeed.toDouble(),
            suffix: '%',
            min: 20,
            max: 100,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(maxVehicleSpeed: value.round()),
            ),
          ),
          _SettingSlider(
            title: 'Velocidad predeterminada de banda',
            value: settings.defaultBeltSpeed.toDouble(),
            suffix: '%',
            min: 0,
            max: 100,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(defaultBeltSpeed: value.round()),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: _VoltageField(
                  label: 'Voltaje mínimo',
                  value: settings.minimumBatteryVoltage,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(minimumBatteryVoltage: value),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VoltageField(
                  label: 'Voltaje máximo',
                  value: settings.maximumBatteryVoltage,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(maximumBatteryVoltage: value),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.title,
    required this.value,
    required this.suffix,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final double value;
  final String suffix;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text(
                '${value.round()}$suffix',
                style: const TextStyle(
                  color: AppColors.aqua,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _VoltageField extends StatefulWidget {
  const _VoltageField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_VoltageField> createState() => _VoltageFieldState();
}

class _VoltageFieldState extends State<_VoltageField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: 'V',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onChanged: (source) {
        final value = double.tryParse(source.replaceAll(',', '.'));
        if (value != null) widget.onChanged(value);
      },
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({required this.controller});

  final EcoFlotadorController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    return HmiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREFERENCIAS',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sonidos de alerta'),
            subtitle: const Text(
              'Preparado para avisos sonoros',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            value: settings.alertSounds,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(alertSounds: value),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo demostración'),
            subtitle: const Text(
              'Simula conexión, movimiento y telemetría',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            value: settings.demoMode,
            onChanged: controller.setDemoMode,
          ),
        ],
      ),
    );
  }
}
