import '../models/bluetooth_device_info.dart';

abstract interface class BluetoothGateway {
  Stream<String> get incomingPackets;
  Stream<bool> get connectionChanges;

  Future<List<BluetoothDeviceInfo>> scan();
  Future<void> connect(BluetoothDeviceInfo device);
  Future<void> disconnect();
  Future<void> send(String command);
  Future<void> dispose();
}
