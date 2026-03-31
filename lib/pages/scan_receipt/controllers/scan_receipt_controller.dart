// lib/pages/scan_receipt/controllers/scan_receipt_controller.dart
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt_keeper/components/custom_toast.dart';
import 'package:receipt_keeper/routes/app_pages.dart';

class ScanReceiptController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxnString selectedImagePath = RxnString();
  final RxnString selectedSource = RxnString();
  final RxnString errorMessage = RxnString();

  bool get hasSelectedImage {
    final value = selectedImagePath.value?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get canContinue => hasSelectedImage && !isLoading.value;

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

    if (hasSelectedImage) {
      return 'Lanjutkan ke draft struk untuk cek data dan isi item belanja.';
    }

    return 'Ambil foto struk dari kamera atau pilih gambar dari galeri.';
  }

  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

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
  }

  Future<void> continueToDraft() async {
    if (!canContinue) {
      CustomToast.errorToast(
        'Gambar belum ada',
        'Silakan ambil foto atau pilih gambar struk terlebih dahulu.',
      );
      return;
    }

    await Get.toNamed(
      Routes.MANUAL_RECEIPT,
      arguments: {
        'scanImagePath': selectedImagePath.value,
        'scanSource': selectedSource.value,
        'fromScanFlow': true,
      },
    );
  }
}
