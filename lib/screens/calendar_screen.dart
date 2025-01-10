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

import 'package:event_management_app/widgets/calendar_widget.dart';
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
            "សំណើអញ្ជើញចូលរួម: Contracts - Detail on multiple meetings on the same day",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "09:00AM - 10:00AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 255, 198, 12),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 0, 85, 3),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 27, 0, 122),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 0, 124, 0),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 172, 0, 134),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 110, 3, 21),
      },
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Contracts - Additional detail",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "10:30AM - 11:30AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 0, 182, 127),
      },
    ],
    _normalizeDate(DateTime(2025, 1, 22)): [
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Same day another meeting",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "09:00AM - 10:00AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 255, 213, 150),
      },
    ],
    _normalizeDate(DateTime(2025, 1, 25)): [
      {
        "title": "កិច្ចប្រជុំ",
        "description": "សំណើអញ្ជើញចូលរួម: Another meeting on the same day",
        "location": "បន្ទប់ប្រជុំច្រកចេញ-ចូលតែមួយ",
        "time": "09:00AM - 10:00AM",
        "participants": ["លោក សេង​ ស៊ុនលី"],
        "color": const Color.fromARGB(255, 241, 162, 255),
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
    _getEventDetailsForSelectedDate();
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: CalendarWidget(
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
        events: _events,
        eventDetails: _getEventDetailsForSelectedDate(),
      ),
    );
  }
}
