import '../models/telemetry.dart';

abstract final class Esp32Protocol {
  static const forward = 'F';
  static const backward = 'B';
  static const left = 'L';
  static const right = 'R';
  static const stop = 'S';
  static const beltOn = 'BELT_ON';
  static const beltOff = 'BELT_OFF';

  static String beltSpeed(int percent) =>
      'BELT_SPEED:${percent.clamp(0, 100).toInt()}';

  static Telemetry parseTelemetry(String packet, Telemetry current) {
    var next = current;
    final fields = packet.trim().split(RegExp(r'\s+'));

    for (final field in fields) {
      final separator = field.indexOf(':');
      if (separator <= 0 || separator == field.length - 1) continue;

      final key = field.substring(0, separator).toUpperCase();
      final value = field.substring(separator + 1).trim();

      switch (key) {
        case 'BAT':
          final parsed = int.tryParse(value);
          if (parsed != null) {
            next = next.copyWith(batteryPercent: parsed.clamp(0, 100).toInt());
          }
          break;
        case 'VOLT':
          final parsed = double.tryParse(value);
          if (parsed != null) next = next.copyWith(voltage: parsed);
          break;
        case 'BIN':
          final parsed = int.tryParse(value);
          if (parsed != null) {
            next = next.copyWith(binPercent: parsed.clamp(0, 100).toInt());
          }
          break;
        case 'MOTOR':
          next = next.copyWith(motorOn: _parseOnOff(value));
          break;
        case 'BELT':
          next = next.copyWith(beltOn: _parseOnOff(value));
          break;
      }
    }

    return next.copyWith(receivedAt: DateTime.now());
  }

  static bool _parseOnOff(String value) {
    return value.toUpperCase() == 'ON' || value == '1';
  }
}
