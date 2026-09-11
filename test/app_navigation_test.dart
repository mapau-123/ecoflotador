import 'package:eco_flotador/app/app.dart';
import 'package:eco_flotador/providers/eco_flotador_controller.dart';
import 'package:eco_flotador/services/demo_bluetooth_gateway.dart';
import 'package:eco_flotador/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navega por las cuatro secciones principales', (tester) async {
    final controller = EcoFlotadorController(
      bluetooth: DemoBluetoothGateway(),
      settingsService: SettingsService(),
    );

    await tester.pumpWidget(EcoFlotadorApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ECO FLOTADOR'), findsWidgets);
    expect(find.text('Estado general'), findsOneWidget);

    await tester.tap(find.text('Control'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Control manual'), findsOneWidget);
    expect(find.text('STOP · EMERGENCIA'), findsOneWidget);

    await tester.tap(find.text('Datos'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Telemetría'), findsOneWidget);

    await tester.tap(find.text('Configuración'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('BUSCAR DISPOSITIVOS'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
