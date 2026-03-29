// lib/utils/global_data.dart
// ignore_for_file: non_constant_identifier_names

class GlobalData {
  // Mode aplikasi
  static bool isTestMode = false;

  // ───────── Profil Toko ─────────
  static String NamaToko = 'TOKO SAYA';
  static String AlamatToko = 'Jl. Contoh No. 123';
  static String KotaToko = '';
  static String TelpToko = '08xxxxxxxxxx';

  // ───────── Nota ─────────
  static String NotaJudul = 'Struk Belanja';

  static String NotaFooter1 = 'Terima kasih sudah berbelanja.';
  static String NotaFooter2 =
      'Barang yang sudah dibeli tidak dapat dikembalikan.';
  static String NotaFooter3 = 'Simpan nota ini sebagai bukti pembayaran.';
  static String NotaketA4 =
      'Barang yang sudah dibeli tidak dapat dikembalikan.\nSimpan nota ini sebagai bukti pembayaran.';

  // Jenis nota default: THERMAL / A4
  static String JenisNotaDefault = 'THERMAL';

  // ───────── Pengaturan Nota Thermal ─────────
  static bool NotaThermalTampilkanLogo = false;
  static int NotaThermalLogoWidthPercent = 80;
  static bool NotaThermalTampilkanNamaToko = true;
  static bool NotaThermalTampilkanAlamat = true;
  static bool NotaThermalTampilkanTelp = true;
  static bool NotaThermalTampilkanWaktuCetak = true;
  static bool NotaThermalTampilkanKasir = true;
  static bool NotaThermalTampilkanFooter = true;

  static int NotaThermalPaperWidthMm = 58;
  static int NotaThermalCharPerLine = 42;
  static bool NotaThermalCetakOtomatis = false;

  // ───────── Pengaturan Nota A4 ─────────
  static bool NotaA4TampilkanLogo = true;
  static bool NotaA4TampilkanNamaToko = true;
  static bool NotaA4TampilkanAlamat = true;
  static bool NotaA4TampilkanTelp = true;
  static bool NotaA4TampilkanWaktuCetak = true;
  static bool NotaA4TampilkanKasir = true;
  static bool NotaA4TampilkanFooter = true;
  static bool NotaA4TampilkanTTDPemilik = false;

  // ───────── Lain-lain (contoh) ─────────
  static int NextSkuBarang = 1;

  /// Biometrik saat buka aplikasi (ON/OFF)
  static bool BiometrikSaatBukaAplikasi = false;
}
