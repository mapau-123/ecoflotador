import 'package:eco_flotador/services/battery_calibration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calibra el porcentaje dentro de los límites configurados', () {
    expect(
      BatteryCalibration.percentageFromVoltage(
        voltage: 10.5,
        minimumVoltage: 10.5,
        maximumVoltage: 12.5,
      ),
      0,
    );
    expect(
      BatteryCalibration.percentageFromVoltage(
        voltage: 11.5,
        minimumVoltage: 10.5,
        maximumVoltage: 12.5,
      ),
      50,
    );
    expect(
      BatteryCalibration.percentageFromVoltage(
        voltage: 12.5,
        minimumVoltage: 10.5,
        maximumVoltage: 12.5,
      ),
      100,
    );
  });
}
