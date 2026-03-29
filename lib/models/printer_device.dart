// lib/models/printer_device.dart

/// Model perangkat printer untuk dipakai di UI dan disimpan di setting.
///
/// connectionType:
/// - 'BLUETOOTH'
/// - 'WIFI'
/// - 'USB_OTG'
class PrinterDevice {
  /// Nama yang tampil di UI (misal: "Printer Kasir 58mm").
  final String name;

  /// Alamat unik:
  /// - Bluetooth: MAC address
  /// - WiFi: IP:port
  /// - USB: ID USB / path (boleh null jika tidak tersedia dari plugin)
  final String? address;

  /// Jenis koneksi: 'BLUETOOTH' / 'WIFI' / 'USB_OTG'
  final String connectionType;

  /// Untuk USB printer (kalau plugin menyediakan, biasanya string hex).
  final String? vendorId;

  /// Untuk USB printer (kalau plugin menyediakan, biasanya string hex).
  final String? productId;

  /// Menandai kalau perangkat ini Bluetooth BLE.
  final bool isBle;

  const PrinterDevice({
    required this.name,
    this.address,
    required this.connectionType,
    this.vendorId,
    this.productId,
    this.isBle = false,
  });

  PrinterDevice copyWith({
    String? name,
    String? address,
    String? connectionType,
    String? vendorId,
    String? productId,
    bool? isBle,
  }) {
    return PrinterDevice(
      name: name ?? this.name,
      address: address ?? this.address,
      connectionType: connectionType ?? this.connectionType,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      isBle: isBle ?? this.isBle,
    );
  }
}
