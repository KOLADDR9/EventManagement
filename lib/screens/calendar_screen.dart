import 'package:event_management_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app/services/api_service.dart';
import 'package:event_management_app/models/event_model.dart';
import 'package:event_management_app/widgets/calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:event_management_app/services/auth_service.dart';

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF083E68), // #083E68
                Color(0xFF107BCE), // #107BCE
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ), // Fixed background color
        elevation: 0.0, // No shadow when scrolling
        title: Text(
          'CIB Event Management',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'YourCustomFont', // Replace with your custom font
            color: Colors.white, // Ensure text remains visible
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Confirm Logout'),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 215, 212),
                            ),
                            child: Text('Logout'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true) {
                    await AuthService.removeToken(); // Add this line
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
              offset: Offset(0, 40),
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                child: Icon(Icons.person, color: Color(0xFFFBA518)),
              ), // Adjust the vertical offset as needed
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<DateTime, List<Event>>>(
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
    );
  }
}
