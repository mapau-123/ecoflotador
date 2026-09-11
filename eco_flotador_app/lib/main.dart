import 'package:flutter/material.dart';

import 'app/app.dart';
import 'providers/eco_flotador_controller.dart';
import 'services/hybrid_bluetooth_gateway.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = EcoFlotadorController(
    bluetooth: HybridBluetoothGateway(),
    settingsService: SettingsService(),
  );
  await controller.initialize();

  runApp(EcoFlotadorApp(controller: controller));
}
