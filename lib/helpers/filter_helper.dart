import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:receipt_keeper/utils/theme.dart';

class FilterCustomHelper {
  static List<Map<String, dynamic>> listToMapChecked<T>(
    List<T> list, {
    String Function(T)? nameSelector,
    dynamic Function(T)? idSelector,
  }) {
    return list.where((item) {
      // Ambil nama menggunakan selector bila tersedia.
      String name;
      if (item is String) {
        name = item;
      } else if (item is Map) {
        name = item['name']?.toString() ?? '';
      } else if (nameSelector != null) {
        name = nameSelector(item);
      } else {
        throw Exception("Tidak ada nameSelector untuk tipe ${T.toString()}");
      }
      return name.isNotEmpty;
    }).map((item) {
      if (item is String) {
        return {'name': item, 'checked': false};
      }
      if (item is Map) {
        Map<String, dynamic> mapItem = Map<String, dynamic>.from(item);
        if (!mapItem.containsKey('checked')) {
          mapItem['checked'] = false;
        }
        return mapItem;
      }
      // Untuk tipe custom, gunakan nameSelector untuk mengambil nama.
      final name = nameSelector != null ? nameSelector(item) : '';
      if (idSelector != null) {
        final idValue = idSelector(item);
        return {'id': idValue, 'name': name, 'checked': false};
      }
      return {'name': name, 'checked': false};
    }).toList();
  }

  static String selectedMultiFilter(dynamic list) {
    String result = '';
    result = list
        .where((item) => item['checked'] == true)
        .map((item) => item['name'])
        .join(',');
    // if (result == '') {
    //   result = 'Semua';
    // }
    return result;
  }

  static List<Map> removeSemuaFromMap(List<Map> list) {
    List<Map> result = list;
    result.removeWhere(
        (item) => item['name'].toString().toUpperCase() == 'SEMUA');
    return result;
  }

  static bool isFilterActive({
    List<String> singleValues = const [],
    List<String> defaultSingleValues = const [],
    List<List<Map<String, dynamic>>> multiLists = const [],
  }) {
    // 1) cek semua single
    for (var i = 0;
        i < singleValues.length && i < defaultSingleValues.length;
        i++) {
      if (singleValues[i] != defaultSingleValues[i]) {
        return true;
      }
    }
    // 2) cek semua multi
    for (var list in multiLists) {
      if (list.any((item) => item['checked'] == true)) {
        return true;
      }
    }
    // tak ada yang aktif
    return false;
  }

  static Widget filterTextContainer(List<String> filterList) {
    Container textContainer(String text) {
      if (text == '') {
        return Container();
      } else {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40.w,
            vertical: 20.h,
          ),
          decoration: CareraTheme.styleBoxFilter,
          child: Text(
            text,
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.mainColor,
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var filter in filterList) ...[
            textContainer(filter),
            filter == '' ? Container() : SizedBox(width: 10.h),
          ],
        ],
      ),
    );
  }
}
