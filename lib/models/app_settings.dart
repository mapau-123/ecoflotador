class AppSettings {
  const AppSettings({
    this.lowBatteryThreshold = 20,
    this.binWarningThreshold = 70,
    this.binFullThreshold = 90,
    this.maxVehicleSpeed = 100,
    this.defaultBeltSpeed = 50,
    this.minimumBatteryVoltage = 10.5,
    this.maximumBatteryVoltage = 12.6,
    this.alertSounds = true,
    this.demoMode = false,
  });

  final int lowBatteryThreshold;
  final int binWarningThreshold;
  final int binFullThreshold;
  final int maxVehicleSpeed;
  final int defaultBeltSpeed;
  final double minimumBatteryVoltage;
  final double maximumBatteryVoltage;
  final bool alertSounds;
  final bool demoMode;

  AppSettings copyWith({
    int? lowBatteryThreshold,
    int? binWarningThreshold,
    int? binFullThreshold,
    int? maxVehicleSpeed,
    int? defaultBeltSpeed,
    double? minimumBatteryVoltage,
    double? maximumBatteryVoltage,
    bool? alertSounds,
    bool? demoMode,
  }) {
    return AppSettings(
      lowBatteryThreshold: lowBatteryThreshold ?? this.lowBatteryThreshold,
      binWarningThreshold: binWarningThreshold ?? this.binWarningThreshold,
      binFullThreshold: binFullThreshold ?? this.binFullThreshold,
      maxVehicleSpeed: maxVehicleSpeed ?? this.maxVehicleSpeed,
      defaultBeltSpeed: defaultBeltSpeed ?? this.defaultBeltSpeed,
      minimumBatteryVoltage:
          minimumBatteryVoltage ?? this.minimumBatteryVoltage,
      maximumBatteryVoltage:
          maximumBatteryVoltage ?? this.maximumBatteryVoltage,
      alertSounds: alertSounds ?? this.alertSounds,
      demoMode: demoMode ?? this.demoMode,
    );
  }
}
