enum FilterType { single, multi }

class FilterConfig {
  final String key; // Identifier unik, misal "status", "kategori", dll.
  final String title;
  final FilterType type;
  final dynamic
      initialValue; // Jika tipe single, expected String; jika multi, expected List<Map<String, dynamic>>
  final List<dynamic>
      options; // Jika tipe single: List<String>, jika multi: List<Map<String, dynamic>>

  FilterConfig({
    required this.key,
    required this.title,
    required this.type,
    required this.initialValue,
    required this.options,
  });
}
