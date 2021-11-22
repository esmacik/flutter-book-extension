import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

DateTime toDate(String date) {
  List<String> parts = date.split('/');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

Future<String> selectDate(BuildContext context, dynamic model, String date) async {
  DateTime initialDate = date == null || date != '' ? DateTime.now(): toDate(date);
  DateTime picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100));
  if(picked != null) {
    model.setChosenDate(DateFormat.yMMMMd('en_US').format(picked.toLocal()));
  }
  return "${picked.year}/${picked.month}/${picked.day}";
}

String formatTime(TimeOfDay picked) {
  String hour = (picked.hour % 12 == 0) ? '12' : (picked.hour % 12).toString();
  String minute = (picked.minute < 9) ? '0${picked.minute}' : picked.minute.toString();
  String period = (picked.period == DayPeriod.am) ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
