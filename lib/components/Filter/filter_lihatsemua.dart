import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/utils/theme.dart';

class FullListFilterPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> initialData;

  const FullListFilterPage({
    super.key,
    required this.title,
    required this.initialData,
  });

  @override
  State<FullListFilterPage> createState() => _FullListFilterPageState();
}

class _FullListFilterPageState extends State<FullListFilterPage> {
  late List<Map<String, dynamic>> dataList;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    // deep copy initial data
    dataList =
        widget.initialData.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // filter berdasarkan searchTerm
    final filtered = dataList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      return name.contains(searchTerm.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(title: widget.title, theme: ''),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => searchTerm = val),
              decoration: InputDecoration(
                hintText: 'Cari',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
            ),
          ),

          // List of checkboxes
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final item = filtered[i];
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(item['name'], style: AxataTextStyle.textBase),
                  value: item['checked'] as bool,
                  activeColor: CareraTheme.mainColor,
                  onChanged: (v) {
                    setState(() {
                      // ubah di dataList asli, bukan di filtered
                      final original = dataList.firstWhere((e) =>
                          e['name'] == item['name'] &&
                          (e['id'] ?? e.hashCode) ==
                              (item['id'] ?? item.hashCode));
                      original['checked'] = v;
                    });
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ButtonFull(
              ontap: () => Get.back(result: dataList),
            ),
          )
        ],
      ),
    );
  }
}
