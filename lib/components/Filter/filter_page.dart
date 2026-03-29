import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/Button/buttonfull.dart';
import 'package:receipt_keeper/components/Filter/filter_config.dart';
import 'package:receipt_keeper/components/Filter/filter_multimap.dart';
import 'package:receipt_keeper/components/Filter/filter_singlemap.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/utils/theme.dart';

class FilterPage extends StatefulWidget {
  final List<FilterConfig> filters;

  const FilterPage({super.key, required this.filters});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late Map<String, dynamic> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = {};
    for (final filter in widget.filters) {
      if (filter.type == FilterType.single) {
        // Inisialisasi nilai single, misalnya "Semua"
        selectedFilters[filter.key] = filter.initialValue;
      } else if (filter.type == FilterType.multi) {
        // Lakukan deep copy untuk List<Map<String, dynamic>>
        selectedFilters[filter.key] = (filter.initialValue as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buat list widget yang akan ditampilkan sesuai dengan konfigurasi filter
    List<Widget> filterWidgets = [];
    for (final filter in widget.filters) {
      if (filter.type == FilterType.single) {
        filterWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: FilterSingleMapPage(
              key: ValueKey(
                  'single-${filter.key}-${selectedFilters[filter.key]}'),
              title: filter.title,
              selected: selectedFilters[filter.key],
              data: filter.options
                  .cast<String>(), // Pastikan tipe data List<String>
              onDataChanged: (value) {
                setState(() {
                  selectedFilters[filter.key] = value;
                });
              },
            ),
          ),
        );
      } else if (filter.type == FilterType.multi) {
        filterWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: FilterMapPage(
              title: filter.title,
              data: selectedFilters[filter.key].cast<Map<String, dynamic>>(),
              onDataChanged: (value) {
                setState(() {
                  selectedFilters[filter.key] = value;
                });
              },
            ),
          ),
        );
      }
      // Tambahkan jarak antar filter
      filterWidgets.add(SizedBox(height: 10.h));
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Filter',
        theme: 'normalIcon',
        widgetIcon: GestureDetector(
          onTap: () {
            setState(() {
              for (final filter in widget.filters) {
                if (filter.type == FilterType.single) {
                  // single: pilih opsi pertama lagi
                  selectedFilters[filter.key] = filter.options.first;
                } else if (filter.type == FilterType.multi) {
                  // multi: uncheck semua
                  final listData =
                      selectedFilters[filter.key] as List<Map<String, dynamic>>;
                  for (final item in listData) {
                    item['checked'] = false;
                  }
                }
              }
            });
          },
          child: Container(
            padding: EdgeInsets.only(right: 10.w),
            child: Text(
              'Reset',
              style: AxataTextStyle.textBase.copyWith(
                color: CareraTheme.red,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...filterWidgets,
                    ],
                  ),
                ),
              ),
              ButtonFull(
                ontap: () => Get.back(result: selectedFilters),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
