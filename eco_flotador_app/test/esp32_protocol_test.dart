import 'package:eco_flotador/models/telemetry.dart';
import 'package:eco_flotador/services/esp32_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Esp32Protocol', () {
    test('genera todos los comandos solicitados', () {
      expect(Esp32Protocol.forward, 'F');
      expect(Esp32Protocol.backward, 'B');
      expect(Esp32Protocol.left, 'L');
      expect(Esp32Protocol.right, 'R');
      expect(Esp32Protocol.stop, 'S');
      expect(Esp32Protocol.beltOn, 'BELT_ON');
      expect(Esp32Protocol.beltOff, 'BELT_OFF');
      expect(Esp32Protocol.beltSpeed(50), 'BELT_SPEED:50');
      expect(Esp32Protocol.beltSpeed(150), 'BELT_SPEED:100');
    });

    test('interpreta un paquete completo del ESP32', () {
      final result = Esp32Protocol.parseTelemetry(
        'BAT:85 VOLT:12.4 BIN:68 MOTOR:ON BELT:OFF',
        const Telemetry(),
      );

      expect(result.batteryPercent, 85);
      expect(result.voltage, 12.4);
      expect(result.binPercent, 68);
      expect(result.motorOn, isTrue);
      expect(result.beltOn, isFalse);
      expect(result.receivedAt, isNotNull);
    });

    test('conserva los datos cuando llegan paquetes parciales', () {
      final result = Esp32Protocol.parseTelemetry(
        'BIN:92',
        const Telemetry(batteryPercent: 64, voltage: 11.8),
      );

      expect(result.batteryPercent, 64);
      expect(result.voltage, 11.8);
      expect(result.binPercent, 92);
    });
  });
}
