import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar_large_screen.dart';
import 'calendar_small_screen.dart';
import '../models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final Map<DateTime, List<Event>> events;
  final List<Event> eventDetails;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.events,
    required this.eventDetails,
  });

  String _getKhmerDayName(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  String parseColor(String? color) {
    if (color == null || color.isEmpty) return "0xFF2196F3";
    return "0xFF${color.replaceAll('#', '')}";
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return CalendarLargeScreen(
            selectedDate: selectedDate,
            eventDetails: eventDetails,
            events: events,
            calendarFormat: calendarFormat,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            parseColor: parseColor,
            getKhmerDayName: _getKhmerDayName,
            isWeekend: _isWeekend,
          );
        } else {
          return CalendarSmallScreen(
            selectedDate: selectedDate,
            eventDetails: eventDetails,
            events: events,
            calendarFormat: calendarFormat,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            parseColor: parseColor,
            getKhmerDayName: _getKhmerDayName,
            isWeekend: _isWeekend,
          );
        }
      },
    );
  }
}
