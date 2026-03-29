// lib/components/selectlist.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/utils/theme.dart';

class SelectListView<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final Widget Function(T item)? leading;
  final Widget? separator;

  /// Optional tombol tambah
  final Future<T?> Function()? onAdd;

  const SelectListView({
    super.key,
    required this.title,
    required this.items,
    required this.labelBuilder,
    this.leading,
    this.separator,
    this.onAdd,
  });

  @override
  State<SelectListView<T>> createState() => _SelectListViewState<T>();
}

class _SelectListViewState<T> extends State<SelectListView<T>> {
  String searchTerm = '';

  Future<void> _handleAdd() async {
    if (widget.onAdd == null) return;

    final newItem = await widget.onAdd!();

    if (newItem != null) {
      setState(() {
        widget.items.add(newItem);
      });

      Get.back(result: newItem);
    }
  }

  Widget _buildItem(T item) {
    return ListTile(
      leading: widget.leading?.call(item),
      title: Text(
        widget.labelBuilder(item),
        style: AxataTextStyle.textBase,
      ),
      onTap: () => Get.back(result: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final label = widget.labelBuilder(item).toLowerCase();

      return label.contains(
        searchTerm.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        theme: 'normal',
      ),
      body: SafeArea(
        child: Padding(
          padding: CareraTheme.paddingScaffold,
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => searchTerm = val),
                decoration: InputDecoration(
                  hintText: 'Cari',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              /// LIST
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      widget.separator ??
                      Divider(
                        height: 1,
                        color: CareraTheme.grey,
                      ),
                  itemBuilder: (_, index) {
                    final item = filtered[index];
                    return _buildItem(item);
                  },
                ),
              ),

              /// BUTTON TAMBAH (optional)
              if (widget.onAdd != null)
                ButtonFull(
                  middleText: 'Tambah',
                  ontap: _handleAdd,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
