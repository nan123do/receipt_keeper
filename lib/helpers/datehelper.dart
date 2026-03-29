import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static DateTime convertStringToDateTime(String dateString) {
    List<String> formats = [
      'yyyy-MM-ddTHH.mm.ss',
      'yyyy-MM-dd HH:mm:ss',
      'dd/MM/yyyy HH:mm:ss',
      'yyyy-MM-ddTHH:mm:ss',
      'yyyy-MM-dd',
      'HH:mm:ss',
      'dd/MM/yyyy',
      'MM/dd/yyyy hh:mm:ss a',
      'yyyy/MM/dd HH:mm:ss',
      'yyyy/MM/dd HH:mm:ss',
      'M/d/yyyy hh:mm:ss a',
    ];

    for (String format in formats) {
      try {
        DateTime dateTime = DateFormat(format).parse(dateString);
        return dateTime;
      } catch (e) {
        // Coba format berikutnya jika konversi gagal
      }
    }

    // Jika tidak ada format yang sesuai
    throw Exception('Invalid date format');
  }

  static TimeOfDay stringToTime(String value) {
    List<String> timeComponents = value.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String strHMStoHM(String value) {
    List<String> times = value.split(':');
    return '${times[0]}:${times[1]}';
  }

  static String timetoHM(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  static bool isTimeBeforeEndTime(TimeOfDay myTime, TimeOfDay current) {
    // Dapatkan waktu saat ini
    TimeOfDay currentTime = current;

    // Bandingkan myTime dengan waktu saat ini
    if (myTime.hour < currentTime.hour ||
        (myTime.hour == currentTime.hour &&
            myTime.minute < currentTime.minute)) {
      // myTime sebelum waktu saat ini
      return true;
    } else {
      // myTime setelah atau sama dengan waktu saat ini
      return false;
    }
  }

  static void datePickerTime(
    BuildContext context,
    TimeOfDay time,
    Function(TimeOfDay, String) onTimeChanged,
  ) {
    DatePicker.showDatePicker(
      context,
      locale: DateTimePickerLocale.id,
      initialDateTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      ),
      pickerMode: DateTimePickerMode.time,
      onConfirm: (value, _) {
        TimeOfDay selectedTime =
            TimeOfDay(hour: value.hour, minute: value.minute);
        String strTime =
            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
        onTimeChanged(selectedTime, strTime);
      },
    );
  }

  static void listDatePickerV2(
    BuildContext context,
    String dateFormat,
    date,
    dateText,
    Function(DateTime, String) onDateChanged,
  ) {
    DatePicker.showDatePicker(
      context,
      locale: DateTimePickerLocale.id,
      dateFormat: dateFormat,
      initialDateTime: date,
      minDateTime: DateTime(2000, 1, 1),
      maxDateTime: DateTime(2100, 12, 31),
      onConfirm: (value, selectedIndex) {
        DateTime newDate = DateTime(value.year, value.month, value.day);
        String newDateText = DateFormat('dd MMMM yyyy', 'id_ID').format(value);
        onDateChanged(newDate, newDateText);
      },
    );
  }
}
