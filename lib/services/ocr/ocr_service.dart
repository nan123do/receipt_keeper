// lib/services/ocr/ocr_service.dart

import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_keeper/models/ocr_result_model.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<OcrResultModel> extractTextFromImage(String imagePath) async {
    if (imagePath.trim().isEmpty) {
      return OcrResultModel.empty();
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return OcrResultModel.empty();
    }

    final inputImage = InputImage.fromFilePath(imagePath);

    final recognizedText = await _textRecognizer.processImage(inputImage);
    final rawText = recognizedText.text.trim();

    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return OcrResultModel(
      rawText: rawText,
      lines: lines,
      hasText: rawText.isNotEmpty,
    );
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
