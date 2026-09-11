enum BluetoothConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  lost,
}

enum Movement { stopped, forward, backward, left, right }

class VehicleState {
  const VehicleState({
    this.connection = BluetoothConnectionState.disconnected,
    this.deviceName,
    this.movement = Movement.stopped,
    this.beltRunning = false,
    this.beltSpeed = 50,
    this.lastCommand = 'S',
  });

  final BluetoothConnectionState connection;
  final String? deviceName;
  final Movement movement;
  final bool beltRunning;
  final int beltSpeed;
  final String lastCommand;

  bool get isConnected => connection == BluetoothConnectionState.connected;
  bool get motorsActive => movement != Movement.stopped;

  VehicleState copyWith({
    BluetoothConnectionState? connection,
    String? deviceName,
    bool clearDeviceName = false,
    Movement? movement,
    bool? beltRunning,
    int? beltSpeed,
    String? lastCommand,
  }) {
    return VehicleState(
      connection: connection ?? this.connection,
      deviceName: clearDeviceName ? null : deviceName ?? this.deviceName,
      movement: movement ?? this.movement,
      beltRunning: beltRunning ?? this.beltRunning,
      beltSpeed: beltSpeed ?? this.beltSpeed,
      lastCommand: lastCommand ?? this.lastCommand,
    );
  }
}
