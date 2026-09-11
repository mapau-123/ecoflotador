import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    const defaults = AppSettings();

    return AppSettings(
      lowBatteryThreshold:
          preferences.getInt('lowBatteryThreshold') ??
          defaults.lowBatteryThreshold,
      binWarningThreshold:
          preferences.getInt('binWarningThreshold') ??
          defaults.binWarningThreshold,
      binFullThreshold:
          preferences.getInt('binFullThreshold') ?? defaults.binFullThreshold,
      maxVehicleSpeed:
          preferences.getInt('maxVehicleSpeed') ?? defaults.maxVehicleSpeed,
      defaultBeltSpeed:
          preferences.getInt('defaultBeltSpeed') ?? defaults.defaultBeltSpeed,
      minimumBatteryVoltage:
          preferences.getDouble('minimumBatteryVoltage') ??
          defaults.minimumBatteryVoltage,
      maximumBatteryVoltage:
          preferences.getDouble('maximumBatteryVoltage') ??
          defaults.maximumBatteryVoltage,
      alertSounds: preferences.getBool('alertSounds') ?? defaults.alertSounds,
      demoMode: preferences.getBool('demoMode') ?? defaults.demoMode,
    );
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setInt('lowBatteryThreshold', settings.lowBatteryThreshold),
      preferences.setInt('binWarningThreshold', settings.binWarningThreshold),
      preferences.setInt('binFullThreshold', settings.binFullThreshold),
      preferences.setInt('maxVehicleSpeed', settings.maxVehicleSpeed),
      preferences.setInt('defaultBeltSpeed', settings.defaultBeltSpeed),
      preferences.setDouble(
        'minimumBatteryVoltage',
        settings.minimumBatteryVoltage,
      ),
      preferences.setDouble(
        'maximumBatteryVoltage',
        settings.maximumBatteryVoltage,
      ),
      preferences.setBool('alertSounds', settings.alertSounds),
      preferences.setBool('demoMode', settings.demoMode),
    ]);
  }
}
