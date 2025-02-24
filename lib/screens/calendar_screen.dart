import 'package:flutter/material.dart';
import 'package:event_management_app/services/api_service.dart';
import 'package:event_management_app/models/event_model.dart';
import 'package:event_management_app/widgets/calendar_widget.dart';
import 'package:event_management_app/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _currentIndex = 0; // Track selected tab
  late Future<Map<DateTime, List<Event>>> _eventsFuture;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _fetchEventsFromApi();
  }

  Future<Map<DateTime, List<Event>>> _fetchEventsFromApi() async {
    final eventsList = await ApiService().fetchEvents();
    final Map<DateTime, List<Event>> eventsMap = {};

    for (var event in eventsList) {
      final date = event.startTime;
      final normalizedDate = _normalizeDate(date);
      if (!eventsMap.containsKey(normalizedDate)) {
        eventsMap[normalizedDate] = [];
      }
      eventsMap[normalizedDate]?.add(event);
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

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to ProfileScreen when clicking Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      setState(() {
        _currentIndex = 0; // Stay on CalendarScreen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Ensures padding for status bar
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
