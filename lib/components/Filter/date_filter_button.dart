// lib/components/Filter/date_filter_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:receipt_keeper/components/custombottomsheet.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/utils/theme.dart';

import 'date_filter.dart';

/// Tombol reusable untuk memilih filter tanggal.
/// - Menampilkan label rentang tanggal (Hari ini, 7 hari terakhir, dst)
/// - Saat ditekan akan membuka CustomBottomSheet dengan berbagai opsi.
class DateFilterButton extends StatelessWidget {
  final DateFilterValue value;
  final ValueChanged<DateFilterValue> onChanged;
  final String? label;

  const DateFilterButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bottomSheetKey = GlobalKey<_DateFilterBottomSheetBodyState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AxataTextStyle.textBase.copyWith(
              color: CareraTheme.gray80,
              fontWeight: FontWeight.w600,
            ),
          ),
          6.gap,
        ],
        InkWell(
          onTap: () async {
            final result = await CustomBottomSheet.showDynamic<DateFilterValue>(
              title: 'Filter Tanggal',
              isScrollControlled: true,
              body: DateFilterBottomSheetBody(
                key: bottomSheetKey,
                initialValue: value,
              ),
              primaryText: 'Terapkan',
              onSave: () async {
                final state = bottomSheetKey.currentState;
                if (state == null) return value;
                return state.buildResult();
              },
            );

            if (result != null) {
              onChanged(result);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            decoration: CareraTheme.decBorderBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.label,
                    style: AxataTextStyle.textBase.copyWith(
                      color: CareraTheme.gray80,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.wGap,
                Icon(
                  Icons.calendar_today,
                  color: CareraTheme.mainColor,
                  size: 18.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Body untuk CustomBottomSheet filter tanggal.
class DateFilterBottomSheetBody extends StatefulWidget {
  final DateFilterValue initialValue;

  const DateFilterBottomSheetBody({
    super.key,
    required this.initialValue,
  });

  @override
  State<DateFilterBottomSheetBody> createState() =>
      _DateFilterBottomSheetBodyState();
}

class _DateFilterBottomSheetBodyState extends State<DateFilterBottomSheetBody> {
  late DateFilterPreset _selectedPreset;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.initialValue.preset;
    _start = widget.initialValue.start;
    _end = widget.initialValue.end;
  }

  DateFilterValue buildResult() {
    switch (_selectedPreset) {
      case DateFilterPreset.all:
        return DateFilterValue.all();
      case DateFilterPreset.today:
        return DateFilterValue.today();
      case DateFilterPreset.last7Days:
        return DateFilterValue.last7Days();
      case DateFilterPreset.last30Days:
        return DateFilterValue.last30Days();
      case DateFilterPreset.customDate:
        return DateFilterValue.customDateRange(_start, _end);
      case DateFilterPreset.customMonth:
        return DateFilterValue.customMonthRange(_start, _end);
      case DateFilterPreset.customYear:
        return DateFilterValue.customYearRange(_start, _end);
    }
  }

  void _onSelectPreset(DateFilterPreset preset) {
    setState(() {
      _selectedPreset = preset;

      if (preset == DateFilterPreset.all) {
        final v = DateFilterValue.all();
        _start = v.start;
        _end = v.end;
      } else if (preset == DateFilterPreset.today) {
        final v = DateFilterValue.today();
        _start = v.start;
        _end = v.end;
      } else if (preset == DateFilterPreset.last7Days) {
        final v = DateFilterValue.last7Days();
        _start = v.start;
        _end = v.end;
      } else if (preset == DateFilterPreset.last30Days) {
        final v = DateFilterValue.last30Days();
        _start = v.start;
        _end = v.end;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih rentang waktu',
          style: AxataTextStyle.textBaseBold,
        ),
        12.gap,

        // Preset cepat
        _buildPresetTile(
          preset: DateFilterPreset.all,
          title: 'Semua tanggal',
        ),
        _buildPresetTile(
          preset: DateFilterPreset.today,
          title: 'Hari ini',
        ),
        _buildPresetTile(
          preset: DateFilterPreset.last7Days,
          title: '7 hari terakhir',
        ),
        _buildPresetTile(
          preset: DateFilterPreset.last30Days,
          title: '30 hari terakhir',
        ),

        12.gap,
        const Divider(color: CareraTheme.gray30),
        8.gap,

        // Custom tanggal
        _buildPresetTile(
          preset: DateFilterPreset.customDate,
          title: 'Pilih tanggal',
          subtitle: 'Atur rentang hari, bulan, dan tahun',
        ),
        if (_selectedPreset == DateFilterPreset.customDate) ...[
          8.gap,
          _buildRangePickers(context, _RangeType.date),
        ],

        12.gap,

        // Custom bulan
        _buildPresetTile(
          preset: DateFilterPreset.customMonth,
          title: 'Pilih bulan',
          subtitle: 'Atur rentang bulan dan tahun',
        ),
        if (_selectedPreset == DateFilterPreset.customMonth) ...[
          8.gap,
          _buildRangePickers(context, _RangeType.month),
        ],

        12.gap,

        // Custom tahun
        _buildPresetTile(
          preset: DateFilterPreset.customYear,
          title: 'Pilih tahun',
          subtitle: 'Atur rentang tahun',
        ),
        if (_selectedPreset == DateFilterPreset.customYear) ...[
          8.gap,
          _buildRangePickers(context, _RangeType.year),
        ],
      ],
    );
  }

  Widget _buildPresetTile({
    required DateFilterPreset preset,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () => _onSelectPreset(preset),
      child: Row(
        children: [
          RadioGroup(
            groupValue: _selectedPreset,
            onChanged: (value) {
              if (value != null) {
                _onSelectPreset(value);
              }
            },
            child: Radio<DateFilterPreset>(
              value: preset,
              activeColor: CareraTheme.mainColor,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AxataTextStyle.textBase,
                ),
                if (subtitle != null) ...[
                  4.gap,
                  Text(
                    subtitle,
                    style: AxataTextStyle.textSm.copyWith(
                      color: CareraTheme.gray60,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangePickers(BuildContext context, _RangeType type) {
    return Row(
      children: [
        0.12.sw.wGap,
        Expanded(
          child: _buildSinglePicker(
            context: context,
            type: type,
            isStart: true,
          ),
        ),
        8.wGap,
        Expanded(
          child: _buildSinglePicker(
            context: context,
            type: type,
            isStart: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSinglePicker({
    required BuildContext context,
    required _RangeType type,
    required bool isStart,
  }) {
    final label = isStart ? 'Mulai' : 'Sampai';
    final value = isStart ? _start : _end;
    final displayText = _formatDisplay(value, type);

    return InkWell(
      onTap: () => _pickDate(context, type: type, isStart: isStart),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 10.h,
        ),
        decoration: CareraTheme.decBorderBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AxataTextStyle.textSm.copyWith(
                color: CareraTheme.gray60,
              ),
            ),
            4.gap,
            Text(
              displayText,
              style: AxataTextStyle.textBase,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDisplay(DateTime value, _RangeType type) {
    switch (type) {
      case _RangeType.date:
        return DateFormat('dd MMM yyyy', 'id_ID').format(value);
      case _RangeType.month:
        return DateFormat('MMMM yyyy', 'id_ID').format(value);
      case _RangeType.year:
        return DateFormat('yyyy', 'id_ID').format(value);
    }
  }

  Future<void> _pickDate(
    BuildContext context, {
    required _RangeType type,
    required bool isStart,
  }) async {
    final current = isStart ? _start : _end;

    String dateFormat;
    switch (type) {
      case _RangeType.date:
        dateFormat = 'dd MMM yyyy';
        break;
      case _RangeType.month:
        // hanya tampilkan bulan & tahun
        dateFormat = 'MMMM yyyy';
        break;
      case _RangeType.year:
        // hanya tampilkan tahun
        dateFormat = 'yyyy';
        break;
    }

    DatePicker.showDatePicker(
      context,
      locale: DateTimePickerLocale.id,
      dateFormat: dateFormat,
      initialDateTime: current,
      minDateTime: DateTime(2000, 1, 1),
      maxDateTime: DateTime(2100, 12, 31),
      onConfirm: (value, _) {
        setState(() {
          late DateTime newDate;

          switch (type) {
            case _RangeType.date:
              newDate = DateTime(value.year, value.month, value.day);
              break;
            case _RangeType.month:
              // Simpan tanggal 1 di bulan yang dipilih
              newDate = DateTime(value.year, value.month, 1);
              break;
            case _RangeType.year:
              // Simpan tanggal 1 Januari di tahun yang dipilih
              newDate = DateTime(value.year, 1, 1);
              break;
          }

          if (isStart) {
            _start = newDate;
            if (_end.isBefore(_start)) {
              _end = newDate;
            }
          } else {
            _end = newDate;
            if (_end.isBefore(_start)) {
              _start = newDate;
            }
          }
        });
      },
    );
  }
}

enum _RangeType {
  date,
  month,
  year,
}
