// lib/services/export/receipt_pdf_service.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:receipt_keeper/models/receipt.dart';
import 'package:receipt_keeper/models/receipt_item.dart';
import 'package:receipt_keeper/models/warranty.dart';
import 'package:receipt_keeper/utils/app_format_helper.dart';

class ReceiptPdfService {
  Future<Uint8List> buildReceiptPdfBytes({
    required Receipt receipt,
    List<ReceiptItem> items = const [],
    List<Warranty> warranties = const [],
  }) async {
    final pdf = pw.Document();
    final receiptImage = await _loadReceiptImage(receipt.imagePath);
    final storeName = _resolveStoreName(receipt);
    final note = receipt.note?.trim();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 32),
        build: (context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 16),
            _buildInfoCard(
              receipt: receipt,
              storeName: storeName,
              itemCount: items.length,
              warrantyCount: warranties.length,
            ),
            if (note != null && note.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildNoteSection(note),
            ],
            if (receiptImage != null) ...[
              pw.SizedBox(height: 16),
              _buildImageSection(receiptImage),
            ],
            pw.SizedBox(height: 16),
            _buildItemSection(items),
            if (warranties.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _buildWarrantySection(warranties),
            ],
            pw.SizedBox(height: 20),
            _buildLegalNote(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<File> generateReceiptPdfFile({
    required Receipt receipt,
    List<ReceiptItem> items = const [],
    List<Warranty> warranties = const [],
  }) async {
    final bytes = await buildReceiptPdfBytes(
      receipt: receipt,
      items: items,
      warranties: warranties,
    );

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'receipt_keeper_${_sanitizeFileName(_resolveStoreName(receipt))}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 1,
        ),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RECEIPT KEEPER',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Bukti Belanja Digital',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoCard({
    required Receipt receipt,
    required String storeName,
    required int itemCount,
    required int warrantyCount,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('Toko', storeName),
          _buildInfoRow(
            'Tanggal',
            AppFormatHelper.formatDateTime(receipt.purchaseDate),
          ),
          _buildInfoRow(
            'Total',
            AppFormatHelper.formatRupiah(receipt.totalAmount),
          ),
          _buildInfoRow('Jumlah Item', itemCount.toString()),
          _buildInfoRow('Jumlah Garansi', warrantyCount.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNoteSection(String note) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 1,
        ),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Catatan',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(note),
        ],
      ),
    );
  }

  pw.Widget _buildItemSection(List<ReceiptItem> items) {
    if (items.isEmpty) {
      return _buildEmptySection(
        title: 'Daftar Item',
        message: 'Belum ada item yang tersimpan pada struk ini.',
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Daftar Item'),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey800,
          ),
          cellStyle: const pw.TextStyle(
            fontSize: 10,
          ),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          headers: const [
            'Item',
            'Qty',
            'Harga',
            'Subtotal',
          ],
          data: items
              .map(
                (item) => [
                  item.itemName,
                  _formatQty(item.qty),
                  AppFormatHelper.formatRupiah(item.unitPrice),
                  AppFormatHelper.formatRupiah(item.subtotal),
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  pw.Widget _buildWarrantySection(List<Warranty> warranties) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Daftar Garansi'),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 10,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blueGrey800,
          ),
          cellStyle: const pw.TextStyle(
            fontSize: 10,
          ),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          headers: const [
            'Produk',
            'Durasi',
            'Beli',
            'Habis',
          ],
          data: warranties
              .map(
                (warranty) => [
                  warranty.productName,
                  '${warranty.warrantyMonths} bulan',
                  AppFormatHelper.formatDate(warranty.purchaseDate),
                  AppFormatHelper.formatDate(warranty.expiryDate),
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  pw.Widget _buildImageSection(pw.MemoryImage image) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 1,
        ),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Foto Struk'),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Image(
              image,
              fit: pw.BoxFit.contain,
              height: 220,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLegalNote() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Text(
        'Dokumen ini dibuat dari aplikasi Receipt Keeper sebagai bukti pembelian digital sederhana. '
        'Pastikan data struk dan foto struk sesuai dengan dokumen asli sebelum digunakan untuk klaim atau arsip.',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  pw.Widget _buildEmptySection({
    required String title,
    required String message,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 1,
        ),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(10),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          pw.SizedBox(height: 6),
          pw.Text(
            message,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  Future<pw.MemoryImage?> _loadReceiptImage(String? imagePath) async {
    final normalizedPath = imagePath?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return null;
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return pw.MemoryImage(bytes);
  }

  String _resolveStoreName(Receipt receipt) {
    final storeName = receipt.storeName?.trim();
    if (storeName == null || storeName.isEmpty) {
      return 'Tanpa Nama Toko';
    }

    return storeName;
  }

  String _sanitizeFileName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _formatQty(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}
