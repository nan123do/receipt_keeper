import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/Filter/widgetfilter.dart';
import 'package:receipt_keeper/utils/theme.dart';

class FilterSingleMapPage extends StatefulWidget {
  const FilterSingleMapPage({
    super.key,
    required this.title,
    required this.selected,
    required this.data,
    required this.onDataChanged,
  });

  final String title;
  final String selected;
  final List<String> data;
  final Function(String) onDataChanged;
  @override
  State<FilterSingleMapPage> createState() => _FilterSingleMapPageState();
}

class _FilterSingleMapPageState extends State<FilterSingleMapPage> {
  String selectedFilter = "";
  List<String> listMap = [];

  @override
  void initState() {
    getInit();
    super.initState();
  }

  getInit() {
    listMap = widget.data;
    selectedFilter = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetLaporan = List.generate(listMap.length, (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = listMap[index];
          });
          widget.onDataChanged(selectedFilter);
        },
        child: WidgetFilter(
          namafilter: listMap[index],
          selected: selectedFilter,
        ),
      );
    });
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      decoration: CareraTheme.decBorderBlue,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AxataTextStyle.textSm.copyWith(fontWeight: FontWeight.bold),
          ),
          Wrap(
            children: [
              ...widgetLaporan,
            ],
          ),
        ],
      ),
    );
  }
}
