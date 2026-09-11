abstract final class BatteryCalibration {
  static int percentageFromVoltage({
    required double voltage,
    required double minimumVoltage,
    required double maximumVoltage,
  }) {
    if (maximumVoltage <= minimumVoltage) return 0;
    final normalized =
        (voltage - minimumVoltage) / (maximumVoltage - minimumVoltage);
    return (normalized.clamp(0, 1) * 100).round();
  }
}
