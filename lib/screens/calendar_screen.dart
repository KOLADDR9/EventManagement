// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/event_model.dart';

// class CalendarScreen extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   late Future<List<Event>> events;

//   @override
//   void initState() {
//     super.initState();
//     events = ApiService().fetchEvents();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Event Calendar')),
//       body: FutureBuilder<List<Event>>(
//         future: events,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No events available'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final event = snapshot.data![index];
//                 return Card(
//                   margin: EdgeInsets.all(8.0),
//                   child: ListTile(
//                     title: Text(event.title),
//                     subtitle: Text(
//                         '${event.startTime} - ${event.endTime}\nType: ${event.type}\nPlace: ${event.place}'),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();

  // Map to store event details
  Map<DateTime, List<Map<String, dynamic>>> _events = {
    _normalizeDate(DateTime(2025, 1, 20)): [
      {
        "title": "កិច្ចប្រជុំ",
        "description":
            "សំណើអញ្ជើញចូលរួមContracts: detail on multiple meetings on the same day",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "09:00AM - 10:00 AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color":
            const Color.fromARGB(255, 58, 166, 255), // Add a color property
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួមContracts: additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30 AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color":
            const Color.fromARGB(255, 152, 255, 155), // Add a color property
      },
    ],
    _normalizeDate(DateTime(2025, 1, 22)): [
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួមContracts: same day another meeting",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "09:00AM - 10:00 AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color":
            const Color.fromARGB(255, 255, 213, 150), // Add a color property
      },
    ],
    _normalizeDate(DateTime(2025, 1, 25)): [
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួមកើContracts: same day another meeting",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតèmួយ",
        "time": "09:00AM - 10:00 AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color":
            const Color.fromARGB(255, 241, 162, 255), // Add a color property
      },
    ],
  };

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Map<String, dynamic>> _getEventDetailsForSelectedDate() {
    return _events[_normalizeDate(_selectedDate)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventDetails = _getEventDetailsForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            eventLoader: (date) {
              return _events.containsKey(_normalizeDate(date))
                  ? _events[_normalizeDate(date)]!
                  : [];
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
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

            // Customizing the calendar builder for events
            calendarBuilders: CalendarBuilders(
              // Customize day with events
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  // Get the first event and access its color property correctly
                  final event = events.first as Map<String, dynamic>;
                  final color =
                      event["color"] ?? Colors.grey; // Default to grey if null
                  return Positioned(
                    bottom: 1.0,
                    right: 0.0,
                    left: 0.0,
                    child: Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: color, // Use event color here
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 16),
          if (eventDetails.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: eventDetails.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: event["color"], // Use the event's color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event["title"],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event["description"],
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "ទីតាំង៖ ${event["location"]}",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "ម៉ោង៖ ${event["time"]}",
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "អ្នកចូលរួម៖ ${event["participants"].join(', ')}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "គ្មានព័ត៌មានសម្រាប់ថ្ងៃនេះ។",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
