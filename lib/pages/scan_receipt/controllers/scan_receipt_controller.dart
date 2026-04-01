// lib/pages/scan_receipt/controllers/scan_receipt_controller.dart
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/models/ocr_result_model.dart';
import 'package:receipt_keeper/routes/app_pages.dart';
import 'package:receipt_keeper/services/ocr/ocr_service.dart';

class ScanReceiptController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();

  final RxBool isLoading = false.obs;
  final RxBool isProcessingOcr = false.obs;
  final RxnString selectedImagePath = RxnString();
  final RxnString selectedSource = RxnString();
  final RxnString errorMessage = RxnString();
  final RxnString ocrErrorMessage = RxnString();
  final Rx<OcrResultModel> ocrResult = OcrResultModel.empty().obs;

  bool get hasSelectedImage {
    final value = selectedImagePath.value?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get hasOcrText => ocrResult.value.hasText;

  bool get canContinue =>
      hasSelectedImage && !isLoading.value && !isProcessingOcr.value;

  String get sourceLabel {
    switch (selectedSource.value) {
      case 'camera':
        return 'Kamera';
      case 'gallery':
        return 'Galeri';
      default:
        return 'Belum ada sumber';
    }
  }

  String get previewTitle {
    if (hasSelectedImage && isProcessingOcr.value) {
      return 'Sedang membaca struk';
    }

    if (hasSelectedImage && hasOcrText) {
      return 'Hasil OCR siap dicek';
    }

    if (hasSelectedImage) {
      return 'Preview struk siap';
    }

    if ((errorMessage.value ?? '').trim().isNotEmpty) {
      return 'Gagal membuka gambar';
    }

    return 'Belum ada gambar';
  }

  String get previewDescription {
    final error = errorMessage.value?.trim();
    if (error != null && error.isNotEmpty) {
      return error;
    }

    final ocrError = ocrErrorMessage.value?.trim();
    if (ocrError != null && ocrError.isNotEmpty) {
      return ocrError;
    }

    if (hasSelectedImage && isProcessingOcr.value) {
      return 'Mohon tunggu, sistem sedang membaca teks dari gambar struk.';
    }

    if (hasSelectedImage && hasOcrText) {
      return 'Teks berhasil dibaca. Lanjutkan ke draft untuk cek dan koreksi data.';
    }

    if (hasSelectedImage) {
      return 'Gambar sudah siap. Anda tetap bisa lanjut ke draft dan isi manual bila hasil OCR belum terbaca.';
    }

    return 'Ambil foto struk dari kamera atau pilih gambar dari galeri.';
  }

  bool get hasOcrFailureMessage {
    final value = ocrErrorMessage.value?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get isOcrFailed =>
      hasSelectedImage && !isProcessingOcr.value && !hasOcrText;

  String get continueButtonText {
    if (!hasSelectedImage) {
      return 'Lanjut ke Draft Struk';
    }

    if (isProcessingOcr.value) {
      return 'Sedang Memproses OCR';
    }

    if (hasOcrText) {
      return 'Cek Hasil OCR di Draft';
    }

    return 'Lanjut Isi Manual';
  }

  String get continueHelperText {
    if (!hasSelectedImage) {
      return 'Pilih gambar struk dulu agar bisa lanjut.';
    }

    if (isProcessingOcr.value) {
      return 'Mohon tunggu sampai proses OCR selesai.';
    }

    if (hasOcrText) {
      return 'Lanjut untuk cek hasil OCR lalu simpan struk.';
    }

    return 'OCR belum maksimal, tapi Anda tetap bisa isi data secara manual.';
  }

  Future<void> retryOcr() async {
    if (!hasSelectedImage || isProcessingOcr.value) {
      return;
    }

    ocrErrorMessage.value = null;
    ocrResult.value = OcrResultModel.empty();
    await processOcr();
  }

  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isLoading.value || isProcessingOcr.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      ocrErrorMessage.value = null;
      selectedImagePath.value = null;
      selectedSource.value = null;
      ocrResult.value = OcrResultModel.empty();

      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 2200,
        maxHeight: 2200,
      );

      if (image == null) {
        return;
      }

      selectedImagePath.value = image.path;
      selectedSource.value =
          source == ImageSource.camera ? 'camera' : 'gallery';

      CustomToast.successToast(
        'Gambar siap',
        source == ImageSource.camera
            ? 'Foto struk berhasil diambil.'
            : 'Gambar struk berhasil dipilih.',
      );
    } on PlatformException catch (e) {
      final message = _mapImageError(e, source);
      errorMessage.value = message;

      CustomToast.errorToast(
        'Akses dibutuhkan',
        message,
      );
    } catch (_) {
      errorMessage.value = 'Gambar belum bisa dibuka. Silakan coba lagi.';

      CustomToast.errorToast(
        'Gagal membuka gambar',
        errorMessage.value!,
      );
    } finally {
      isLoading.value = false;
    }

    if (hasSelectedImage) {
      await processOcr();
    }
  }

  Future<void> processOcr() async {
    final imagePath = selectedImagePath.value?.trim();
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    try {
      isProcessingOcr.value = true;
      ocrErrorMessage.value = null;

      final result = await _ocrService.extractTextFromImage(imagePath);
      ocrResult.value = result;

      if (result.hasText) {
        CustomToast.successToast(
          'Teks berhasil dibaca',
          'Hasil scan siap dicek dan diedit sebelum disimpan.',
        );
        return;
      }

      ocrErrorMessage.value =
          'Teks pada struk belum terbaca jelas. Anda tetap bisa lanjut dan isi data secara manual.';
    } catch (_) {
      ocrResult.value = OcrResultModel.empty();
      ocrErrorMessage.value =
          'OCR belum berhasil membaca struk. Anda tetap bisa lanjut dan isi data secara manual.';
    } finally {
      isProcessingOcr.value = false;
    }
  }

  String _mapImageError(
    PlatformException error,
    ImageSource source,
  ) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    final isPermissionError = code.contains('denied') ||
        code.contains('access_denied') ||
        code.contains('permission') ||
        message.contains('denied') ||
        message.contains('permission');

    if (isPermissionError) {
      return source == ImageSource.camera
          ? 'Mohon beri akses kamera agar Anda bisa memotret struk.'
          : 'Mohon beri akses galeri atau penyimpanan agar Anda bisa memilih gambar struk.';
    }

    return 'Gambar belum bisa dibuka. Silakan coba lagi.';
  }

  void retryScan() {
    selectedImagePath.value = null;
    selectedSource.value = null;
    errorMessage.value = null;
    ocrErrorMessage.value = null;
    ocrResult.value = OcrResultModel.empty();
  }

  Future<void> continueToDraft() async {
    if (!canContinue) {
      CustomToast.errorToast(
        'Gambar belum siap',
        'Silakan tunggu proses scan selesai atau pilih gambar struk terlebih dahulu.',
      );
      return;
    }

    await Get.toNamed(
      Routes.MANUAL_RECEIPT,
      arguments: {
        'scanImagePath': selectedImagePath.value,
        'scanSource': selectedSource.value,
        'fromScanFlow': true,
        'rawOcrText': ocrResult.value.rawText,
        'ocrLines': ocrResult.value.lines,
        'hasOcrText': ocrResult.value.hasText,
      },
    );
  }

  @override
  void onClose() {
    _ocrService.dispose();
    super.onClose();
  }
}
