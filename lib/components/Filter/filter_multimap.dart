import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/components/Filter/filter_lihatsemua.dart';
import 'package:receipt_keeper/components/Filter/widgetsisa.dart';
import 'package:receipt_keeper/utils/theme.dart';

class FilterMapPage extends StatefulWidget {
  const FilterMapPage({
    super.key,
    required this.title,
    required this.data,
    required this.onDataChanged,
  });

  final String title;
  final List<Map<String, dynamic>> data;
  final Function(List<Map<String, dynamic>>) onDataChanged;

  @override
  State<FilterMapPage> createState() => _FilterMapPageState();
}

class _FilterMapPageState extends State<FilterMapPage> {
  int sisaFilter = 0;
  List<Map<String, dynamic>> listMap = [];

  @override
  void initState() {
    super.initState();
    getInit();
  }

  void getInit() {
    listMap = widget.data;
  }

  List<Widget> _listWidget(List<Map<String, dynamic>> data) {
    return List.generate(data.length < 6 ? data.length : 6, (index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            data[index]['checked'] = !data[index]['checked'];
          });
          widget.onDataChanged(data);
        },
        child: _widgetKategori(data[index]),
      );
    });
  }

  Widget _widgetKategori(Map<String, dynamic> filter) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.h,
        bottom: 8.h,
        right: 8.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: filter['checked'] == true
          ? CareraTheme.styleBoxFilter
          : CareraTheme.styleUnselectBoxFilter,
      child: Text(
        filter['name'],
        style: AxataTextStyle.textSm.copyWith(
          color: filter['checked'] == true
              ? CareraTheme.mainColor
              : CareraTheme.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (listMap.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AxataTextStyle.textSm.copyWith(fontWeight: FontWeight.bold),
          ),
          const Center(
            child: Text('Data kosong'),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      decoration: CareraTheme.decBorderBlue,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style:
                    AxataTextStyle.textSm.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openFullPageLihatSemua(),
                // onTap: () => _openModalLihatSemua(
                //   context,
                //   listMap,
                //   (List<Map<String, dynamic>> data) {
                //     setState(() {
                //       listMap = data;
                //       listMap.sort((a, b) {
                //         if (b['checked']) {
                //           return 1;
                //         }
                //         return -1;
                //       });
                //       int sisa = data
                //           .where((item) => item['checked'] == true)
                //           .fold(0, (sum, item) => sum + 1);

                //       if (sisa > 6) {
                //         sisaFilter = sisa - 6;
                //       } else {
                //         sisaFilter = 0;
                //       }
                //     });
                //     widget.onDataChanged(data);
                //   },
                // ),
                child: Text(
                  'Lihat Semua',
                  style: AxataTextStyle.textSm
                      .copyWith(color: CareraTheme.mainColor),
                ),
              ),
            ],
          ),
          _wrapSisa(_listWidget(listMap), sisaFilter),
        ],
      ),
    );
  }

  Wrap _wrapSisa(List<Widget> widgetList, int sisa) {
    return Wrap(
      children: [
        ...widgetList,
        WidgetSisa(sisa: sisa),
      ],
    );
  }

  void _openFullPageLihatSemua() async {
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (_) => FullListFilterPage(
          title: 'Semua ${widget.title}',
          initialData: listMap,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        listMap = result;
        // urutkan dan hitung sisa seperti sebelumnya...
      });
      widget.onDataChanged(listMap);
    }
  }
}
