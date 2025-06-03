import 'package:flutter/material.dart';
import 'package:event_management_app/services/api_service.dart';
import 'package:event_management_app/models/event_model.dart';
import 'package:event_management_app/widgets/calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<DateTime, List<Event>>> _eventsFuture;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEventsFromApi();
  }

  Future<Map<DateTime, List<Event>>> _fetchEventsFromApi() async {
    final eventsList = await ApiService().fetchEvents();
    final Map<DateTime, List<Event>> eventsMap = {};

    for (var event in eventsList) {
      DateTime startDate = _normalizeDate(event.startTime);
      DateTime endDate = _normalizeDate(event.endTime);

      if (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        DateTime currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
          if (!eventsMap.containsKey(currentDate)) {
            eventsMap[currentDate] = [];
          }
          eventsMap[currentDate]?.add(event);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } else {
        // Handle single-day events or invalid date ranges
        if (!eventsMap.containsKey(startDate)) {
          eventsMap[startDate] = [];
        }
        eventsMap[startDate]?.add(event);
      }
    }

    return eventsMap;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Event> _getEventDetailsForSelectedDate(
      Map<DateTime, List<Event>> events) {
    return events[_normalizeDate(_selectedDate)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor:
          Color.fromARGB(235, 250, 252, 255), // Light blue background
      body: SafeArea(
        child: FutureBuilder<Map<DateTime, List<Event>>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? {};
            final eventDetails = _getEventDetailsForSelectedDate(events);
            return CalendarWidget(
              selectedDate: _selectedDate,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              events: events,
              eventDetails: eventDetails,
            );
          },
        ),
      ),
    );
  }
}
