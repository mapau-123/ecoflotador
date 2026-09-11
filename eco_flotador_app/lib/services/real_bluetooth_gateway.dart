import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
 
import 'package:universal_ble/universal_ble.dart';
 
import '../models/bluetooth_device_info.dart';
import 'bluetooth_gateway.dart';
 
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
/// El firmware del ESP32 entiende directamente los comandos lógicos de
/// [Esp32Protocol] ("F", "B", "L", "R", "S", "VEL:n", "BELT_*"), así que
/// esta clase los envía tal cual por BLE, sin traducción.
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
    await characteristic.write(utf8.encode(command));
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
 
