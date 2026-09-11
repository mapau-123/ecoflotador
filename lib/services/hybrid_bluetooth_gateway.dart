import 'dart:async';

import '../models/bluetooth_device_info.dart';
import 'bluetooth_gateway.dart';
import 'demo_bluetooth_gateway.dart';
import 'real_bluetooth_gateway.dart';

/// Combina [DemoBluetoothGateway] y [RealBluetoothGateway] detrás de un solo
/// [BluetoothGateway], para que el interruptor "Modo demostración" de
/// Configuración pueda seguir usándose (por ejemplo, ante el jurado, sin el
/// bote físico a la mano) sin perder la conexión real con el ESP32 el resto
/// del tiempo.
class HybridBluetoothGateway implements BluetoothGateway {
  HybridBluetoothGateway({DemoBluetoothGateway? demo, RealBluetoothGateway? real})
      : demo = demo ?? DemoBluetoothGateway(),
        real = real ?? RealBluetoothGateway() {
    _active = this.real;
    _rewire();
  }

  final DemoBluetoothGateway demo;
  final RealBluetoothGateway real;
  late BluetoothGateway _active;

  final _packets = StreamController<String>.broadcast();
  final _connection = StreamController<bool>.broadcast();
  StreamSubscription<String>? _packetsSub;
  StreamSubscription<bool>? _connSub;

  @override
  Stream<String> get incomingPackets => _packets.stream;

  @override
  Stream<bool> get connectionChanges => _connection.stream;

  void _rewire() {
    _packetsSub?.cancel();
    _connSub?.cancel();
    _packetsSub = _active.incomingPackets.listen(_packets.add);
    _connSub = _active.connectionChanges.listen(_connection.add);
  }

  /// Cambia entre el ESP32 real y el simulador de demostración, cerrando la
  /// conexión activa (si la hay) antes de cambiar.
  Future<void> useRealHardware(bool useReal) async {
    final next = useReal ? real : demo;
    if (identical(next, _active)) return;
    await _active.disconnect();
    _active = next;
    _rewire();
  }

  @override
  Future<List<BluetoothDeviceInfo>> scan() => _active.scan();

  @override
  Future<void> connect(BluetoothDeviceInfo device) => _active.connect(device);

  @override
  Future<void> disconnect() => _active.disconnect();

  @override
  Future<void> send(String command) => _active.send(command);

  @override
  Future<void> dispose() async {
    await _packetsSub?.cancel();
    await _connSub?.cancel();
    await demo.dispose();
    await real.dispose();
    await _packets.close();
    await _connection.close();
  }
}
