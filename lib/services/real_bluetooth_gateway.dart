import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart';

import '../models/bluetooth_device_info.dart';
import 'bluetooth_gateway.dart';
import 'esp32_protocol.dart';

/// UUIDs reales tomados del firmware BLE del ESP32 (ver
/// `firmware/eco_flotador_esp32/eco_flotador_esp32.ino`, servicio único con
/// una sola characteristic READ | WRITE | NOTIFY).
const _serviceUuid = '12345678-1234-1234-1234-1234567890AB';
const _characteristicUuid = '87654321-4321-4321-4321-BA0987654321';

/// Implementación real del [BluetoothGateway] usando `universal_ble`, que
/// funciona tanto en Android (BLE nativo) como en la versión web (Web
/// Bluetooth API, solo en navegadores basados en Chromium: Chrome, Edge,
/// Opera — no funciona en Safari ni Firefox).
///
/// Importante: el ESP32 real solo entiende un protocolo de joystick
/// `"x,y"` (ver `procesarJoystick` en el firmware), no los comandos
/// `F/B/L/R/S` que usa el resto de la app. Esta clase traduce los comandos
/// lógicos de [Esp32Protocol] al formato real por el aire; el resto de la
/// UI, el controlador y las pantallas no necesitan cambiar.
class RealBluetoothGateway implements BluetoothGateway {
  final _packets = StreamController<String>.broadcast();
  final _connection = StreamController<bool>.broadcast();

  final _foundDevices = <String, BleDevice>{};
  BleDevice? _device;
  BleCharacteristic? _characteristic;
  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<Uint8List>? _valueSub;

  @override
  Stream<String> get incomingPackets => _packets.stream;

  @override
  Stream<bool> get connectionChanges => _connection.stream;

  @override
  Future<List<BluetoothDeviceInfo>> scan() async {
    _foundDevices.clear();

    final resultsSub = UniversalBle.scanStream.listen((device) {
      _foundDevices[device.deviceId] = device;
    });

    try {
      await UniversalBle.startScan(
        scanFilter: ScanFilter(withServices: [_serviceUuid]),
      );
      await Future<void>.delayed(const Duration(seconds: 4));
    } finally {
      await UniversalBle.stopScan();
      await resultsSub.cancel();
    }

    return _foundDevices.values
        .map(
          (d) => BluetoothDeviceInfo(
            id: d.deviceId,
            name: (d.name == null || d.name!.isEmpty)
                ? 'ECO FLOTADOR'
                : d.name!,
            signal: d.rssi ?? -100,
          ),
        )
        .toList();
  }

  @override
  Future<void> connect(BluetoothDeviceInfo device) async {
    final bleDevice = _foundDevices[device.id];
    if (bleDevice == null) {
      throw StateError(
        'Dispositivo no encontrado; vuelve a buscar antes de conectar.',
      );
    }

    await bleDevice.connect();
    _device = bleDevice;

    await _connectionSub?.cancel();
    _connectionSub = bleDevice.connectionStream.listen((isConnected) {
      _connection.add(isConnected);
      if (!isConnected) _teardownCharacteristic();
    });

    final characteristic = await bleDevice.getCharacteristic(
      _characteristicUuid,
      service: _serviceUuid,
    );
    _characteristic = characteristic;

    await characteristic.notifications.subscribe();
    _valueSub = characteristic.onValueReceived.listen((bytes) {
      final text = utf8.decode(bytes, allowMalformed: true).trim();
      if (text.isNotEmpty) _packets.add(text);
    });

    _connection.add(true);
  }

  @override
  Future<void> disconnect() async {
    await _device?.disconnect();
    _teardownCharacteristic();
    _connection.add(false);
  }

  @override
  Future<void> send(String command) async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      throw StateError('No hay conexión BLE activa con el ESP32.');
    }
    await characteristic.write(utf8.encode(_toWireFormat(command)));
  }

  /// Traduce los comandos lógicos de la app al protocolo real `"x,y"` del
  /// firmware. Los comandos de banda (`BELT_*`) no tienen aún un motor
  /// físico que los reciba: se envían tal cual (el firmware actual los
  /// ignora sin coma en el string, de forma segura) para que el día que
  /// agregues el motor de banda solo tengas que leerlos en el ESP32.
  String _toWireFormat(String logicalCommand) {
    switch (logicalCommand) {
      case Esp32Protocol.forward:
        return '0,100';
      case Esp32Protocol.backward:
        return '0,-100';
      case Esp32Protocol.left:
        return '-100,0';
      case Esp32Protocol.right:
        return '100,0';
      case Esp32Protocol.stop:
        return '0,0';
      default:
        return logicalCommand;
    }
  }

  void _teardownCharacteristic() {
    _valueSub?.cancel();
    _valueSub = null;
    _characteristic = null;
  }

  @override
  Future<void> dispose() async {
    await _connectionSub?.cancel();
    await _valueSub?.cancel();
    await _device?.disconnect();
    await _packets.close();
    await _connection.close();
  }
}
