import 'dart:async';
 
import 'package:flutter/foundation.dart';
 
import '../models/app_settings.dart';
import '../models/bluetooth_device_info.dart';
import '../models/telemetry.dart';
import '../models/vehicle_state.dart';
import '../services/bluetooth_gateway.dart';
import '../services/esp32_protocol.dart';
import '../services/hybrid_bluetooth_gateway.dart';
import '../services/settings_service.dart';
 
class EcoFlotadorController extends ChangeNotifier {
  EcoFlotadorController({
    required this.bluetooth,
    required this.settingsService,
  });
 
  final BluetoothGateway bluetooth;
  final SettingsService settingsService;
 
  StreamSubscription<String>? _packetSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  Timer? _keepAliveTimer;
  bool _isShutdown = false;
 
  /// El ESP32 real detiene los motores si no recibe un mensaje en 800 ms
  /// (failsafe de seguridad). La UI solo llama [move] cuando la dirección
  /// cambia, así que sin este reenvío periódico el bote se detendría solo
  /// cada 800 ms mientras el joystick sigue presionado en la misma
  /// dirección. Se reenvía el último comando cada 300 ms mientras haya
  /// movimiento activo.
  static const _keepAliveInterval = Duration(milliseconds: 300);
 
  VehicleState vehicle = const VehicleState();
  Telemetry telemetry = const Telemetry();
  AppSettings settings = const AppSettings();
  List<BluetoothDeviceInfo> devices = const [];
  bool isScanning = false;
  bool isSaving = false;
  String? message;
 
  /// Nivel de velocidad de los motores de propulsión: 1=lento, 2=medio,
  /// 3=rápido. El ESP32 arranca con el mismo valor por defecto (medio),
  /// así que ambos lados quedan sincronizados sin necesidad de un mensaje
  /// inicial.
  int motorSpeedLevel = 2;
 
  bool get controlsEnabled => settings.demoMode || vehicle.isConnected;
 
  Future<void> initialize() async {
    settings = await settingsService.load();
    vehicle = vehicle.copyWith(beltSpeed: settings.defaultBeltSpeed);
    final gateway = bluetooth;
    if (gateway is HybridBluetoothGateway) {
      await gateway.useRealHardware(!settings.demoMode);
    }
    _packetSubscription = bluetooth.incomingPackets.listen(_onPacket);
    _connectionSubscription = bluetooth.connectionChanges.listen(
      _onConnectionChanged,
    );
    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (_) {
      if (vehicle.isConnected && vehicle.movement != Movement.stopped) {
        unawaited(_send(vehicle.lastCommand));
      }
    });
 
    if (settings.demoMode) {
      await connect(
        const BluetoothDeviceInfo(
          id: 'demo-eco-flotador',
          name: 'ECO-FLOTADOR',
          signal: -42,
        ),
      );
    }
  }
 
  Future<void> scan() async {
    final wasConnected = vehicle.isConnected;
    isScanning = true;
    message = null;
    vehicle = vehicle.copyWith(connection: BluetoothConnectionState.scanning);
    notifyListeners();
 
    try {
      devices = await bluetooth.scan();
      vehicle = vehicle.copyWith(
        connection: wasConnected
            ? BluetoothConnectionState.connected
            : BluetoothConnectionState.disconnected,
      );
    } catch (_) {
      message = 'No fue posible buscar dispositivos.';
      vehicle = vehicle.copyWith(
        connection: BluetoothConnectionState.disconnected,
      );
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }
 
  Future<void> connect(BluetoothDeviceInfo device) async {
    vehicle = vehicle.copyWith(connection: BluetoothConnectionState.connecting);
    message = null;
    notifyListeners();
 
    try {
      await bluetooth.connect(device);
      vehicle = vehicle.copyWith(
        connection: BluetoothConnectionState.connected,
        deviceName: device.name,
      );
    } catch (_) {
      message = 'No fue posible conectar con ${device.name}.';
      vehicle = vehicle.copyWith(
        connection: BluetoothConnectionState.disconnected,
      );
    }
    notifyListeners();
  }
 
  Future<void> disconnect() async {
    await emergencyStop();
    await bluetooth.disconnect();
    vehicle = vehicle.copyWith(
      connection: BluetoothConnectionState.disconnected,
      clearDeviceName: true,
      movement: Movement.stopped,
      beltRunning: false,
    );
    notifyListeners();
  }
 
  Future<void> move(Movement direction) async {
    if (!controlsEnabled) return;
    if (vehicle.movement == direction) return;
 
    final command = switch (direction) {
      Movement.forward => Esp32Protocol.forward,
      Movement.backward => Esp32Protocol.backward,
      Movement.left => Esp32Protocol.left,
      Movement.right => Esp32Protocol.right,
      Movement.stopped => Esp32Protocol.stop,
    };
 
    vehicle = vehicle.copyWith(movement: direction, lastCommand: command);
    telemetry = telemetry.copyWith(motorOn: direction != Movement.stopped);
    notifyListeners();
    await _send(command);
  }
 
  /// Cambia la velocidad de los motores de propulsión (1=lento, 2=medio,
  /// 3=rápido) y avisa al ESP32 con "VEL:n". No depende del keep-alive:
  /// se envía una sola vez apenas cambia el slider.
  Future<void> setMotorSpeed(int level) async {
    final clamped = level.clamp(1, 3);
    if (motorSpeedLevel == clamped) return;
    motorSpeedLevel = clamped;
    notifyListeners();
    if (controlsEnabled) await _send('VEL:$clamped');
  }
 
  Future<void> emergencyStop() async {
    vehicle = vehicle.copyWith(
      movement: Movement.stopped,
      beltRunning: false,
      lastCommand: Esp32Protocol.stop,
    );
    telemetry = telemetry.copyWith(motorOn: false, beltOn: false);
    notifyListeners();
 
    if (controlsEnabled) {
      await _send(Esp32Protocol.stop);
      await _send(Esp32Protocol.beltOff);
    }
  }
 
  Future<void> setBeltRunning(bool running) async {
    if (!controlsEnabled) return;
    vehicle = vehicle.copyWith(beltRunning: running);
    telemetry = telemetry.copyWith(beltOn: running);
    notifyListeners();
    await _send(running ? Esp32Protocol.beltOn : Esp32Protocol.beltOff);
  }
 
  Future<void> setBeltSpeed(double value) async {
    final speed = value.round().clamp(0, 100).toInt();
    if (vehicle.beltSpeed == speed) return;
    vehicle = vehicle.copyWith(beltSpeed: speed);
    notifyListeners();
    if (controlsEnabled) await _send(Esp32Protocol.beltSpeed(speed));
  }
 
  Future<void> setDemoMode(bool enabled) async {
    settings = settings.copyWith(demoMode: enabled);
    notifyListeners();
    await saveSettings();
 
    final gateway = bluetooth;
    if (gateway is HybridBluetoothGateway) {
      await gateway.useRealHardware(!enabled);
    }
 
    if (enabled && !vehicle.isConnected) {
      await connect(
        const BluetoothDeviceInfo(
          id: 'demo-eco-flotador',
          name: 'ECO-FLOTADOR',
          signal: -42,
        ),
      );
    } else if (!enabled && vehicle.deviceName == 'ECO-FLOTADOR') {
      await disconnect();
    }
  }
 
  void updateSettings(AppSettings next) {
    settings = next;
    notifyListeners();
  }
 
  Future<void> saveSettings() async {
    isSaving = true;
    notifyListeners();
    await settingsService.save(settings);
    isSaving = false;
    message = 'Configuración guardada en el dispositivo.';
    notifyListeners();
  }
 
  void simulateAlert({int? battery, int? bin}) {
    if (!settings.demoMode) return;
    telemetry = telemetry.copyWith(
      batteryPercent: battery ?? telemetry.batteryPercent,
      binPercent: bin ?? telemetry.binPercent,
    );
    notifyListeners();
  }
 
  Future<void> _send(String command) async {
    if (!vehicle.isConnected && !settings.demoMode) return;
    try {
      await bluetooth.send(command);
    } catch (_) {
      _onConnectionChanged(false);
    }
  }
 
  void _onPacket(String packet) {
    telemetry = Esp32Protocol.parseTelemetry(packet, telemetry);
    vehicle = vehicle.copyWith(
      beltRunning: telemetry.beltOn,
      movement: telemetry.motorOn ? vehicle.movement : Movement.stopped,
    );
    notifyListeners();
  }
 
  void _onConnectionChanged(bool connected) {
    vehicle = vehicle.copyWith(
      connection: connected
          ? BluetoothConnectionState.connected
          : BluetoothConnectionState.lost,
      movement: connected ? vehicle.movement : Movement.stopped,
      beltRunning: connected ? vehicle.beltRunning : false,
    );
    if (!connected) {
      telemetry = telemetry.copyWith(motorOn: false, beltOn: false);
      message = 'Conexión perdida. Controles deshabilitados.';
    }
    notifyListeners();
  }
 
  Future<void> shutdown() async {
    if (_isShutdown) return;
    _isShutdown = true;
    _keepAliveTimer?.cancel();
    await _packetSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await bluetooth.dispose();
  }
 
  @override
  void dispose() {
    unawaited(shutdown());
    super.dispose();
  }
}
 
