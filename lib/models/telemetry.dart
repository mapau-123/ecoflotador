class Telemetry {
  const Telemetry({
    this.batteryPercent = 85,
    this.voltage = 12.4,
    this.binPercent = 68,
    this.motorOn = false,
    this.beltOn = false,
    this.receivedAt,
  });

  final int batteryPercent;
  final double voltage;
  final int binPercent;
  final bool motorOn;
  final bool beltOn;
  final DateTime? receivedAt;

  Telemetry copyWith({
    int? batteryPercent,
    double? voltage,
    int? binPercent,
    bool? motorOn,
    bool? beltOn,
    DateTime? receivedAt,
  }) {
    return Telemetry(
      batteryPercent: batteryPercent ?? this.batteryPercent,
      voltage: voltage ?? this.voltage,
      binPercent: binPercent ?? this.binPercent,
      motorOn: motorOn ?? this.motorOn,
      beltOn: beltOn ?? this.beltOn,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
