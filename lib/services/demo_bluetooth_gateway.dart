import 'dart:async';
import 'dart:math';

import '../models/bluetooth_device_info.dart';
import 'bluetooth_gateway.dart';

class DemoBluetoothGateway implements BluetoothGateway {
  final _packets = StreamController<String>.broadcast();
  final _connections = StreamController<bool>.broadcast();
  final _random = Random();

  Timer? _telemetryTimer;
  bool _connected = false;
  int _battery = 85;
  int _bin = 68;
  bool _motorOn = false;
  bool _beltOn = false;

  @override
  Stream<String> get incomingPackets => _packets.stream;

  @override
  Stream<bool> get connectionChanges => _connections.stream;

  @override
  Future<List<BluetoothDeviceInfo>> scan() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const [
      BluetoothDeviceInfo(
        id: 'demo-eco-flotador',
        name: 'ECO-FLOTADOR',
        signal: -42,
      ),
      BluetoothDeviceInfo(id: 'demo-esp32-lab', name: 'ESP32-LAB', signal: -68),
    ];
  }

  @override
  Future<void> connect(BluetoothDeviceInfo device) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _connected = true;
    _connections.add(true);
    _startTelemetry();
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _motorOn = false;
    _beltOn = false;
    _telemetryTimer?.cancel();
    _connections.add(false);
  }

  @override
  Future<void> send(String command) async {
    if (!_connected) {
      throw StateError('No hay conexión Bluetooth activa.');
    }

    switch (command) {
      case 'F':
      case 'B':
      case 'L':
      case 'R':
        _motorOn = true;
        break;
      case 'S':
        _motorOn = false;
        break;
      case 'BELT_ON':
        _beltOn = true;
        break;
      case 'BELT_OFF':
        _beltOn = false;
        break;
    }
    _emitPacket();
  }

  void _startTelemetry() {
    _telemetryTimer?.cancel();
    _emitPacket();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_connected) return;
      _battery = (_battery - (_random.nextBool() ? 1 : 0))
          .clamp(8, 100)
          .toInt();
      if (_beltOn && _random.nextBool()) {
        _bin = (_bin + 1).clamp(0, 100).toInt();
      }
      _emitPacket();
    });
  }

  void _emitPacket() {
    final voltage = 10.5 + (_battery / 100 * 2.1);
    _packets.add(
      'BAT:$_battery VOLT:${voltage.toStringAsFixed(1)} '
      'BIN:$_bin MOTOR:${_motorOn ? 'ON' : 'OFF'} '
      'BELT:${_beltOn ? 'ON' : 'OFF'}',
    );
  }

  @override
  Future<void> dispose() async {
    _telemetryTimer?.cancel();
    await _packets.close();
    await _connections.close();
  }
}
