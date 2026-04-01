// lib/pages/scan_receipt/models/ocr_result_model.dart

class OcrResultModel {
  final String rawText;
  final List<String> lines;
  final bool hasText;

  const OcrResultModel({
    required this.rawText,
    required this.lines,
    required this.hasText,
  });

  factory OcrResultModel.empty() {
    return const OcrResultModel(
      rawText: '',
      lines: [],
      hasText: false,
    );
  }

  OcrResultModel copyWith({
    String? rawText,
    List<String>? lines,
    bool? hasText,
  }) {
    return OcrResultModel(
      rawText: rawText ?? this.rawText,
      lines: lines ?? this.lines,
      hasText: hasText ?? this.hasText,
    );
  }
}
