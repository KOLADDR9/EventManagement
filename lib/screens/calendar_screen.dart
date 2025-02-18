import 'package:event_management_app/screens/login.dart';
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

class _CalendarScreenState extends State<CalendarScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CIB event management',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily:
                'YourCustomFont', // Replace with your custom font family
            color: const Color.fromARGB(255, 0, 33, 105),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<DateTime, List<Event>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available'));
          } else {
            final events = snapshot.data!;
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
          }
        },
      ),
    );
  }
}
