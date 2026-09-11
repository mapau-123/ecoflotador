class BluetoothDeviceInfo {
  const BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.signal,
  });

  final String id;
  final String name;
  final int signal;
}
