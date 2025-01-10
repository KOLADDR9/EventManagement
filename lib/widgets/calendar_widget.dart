import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final List<Map<String, dynamic>> eventDetails;

  const CalendarWidget({
    Key? key,
    required this.selectedDate,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.events,
    required this.eventDetails,
  }) : super(key: key);

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper function to get month name
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarFormat: calendarFormat,
          eventLoader: (date) {
            return events.containsKey(_normalizeDate(date))
                ? events[_normalizeDate(date)]!
                : [];
          },
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            formatButtonVisible: false, // Hide the format button
          ),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, date) {
              // Custom header title to show only the month and year
              return Text(
                '${_getMonthName(date.month)} ${date.year}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              );
            },
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                // Limit the number of events to 3
                final limitedEvents = events.take(3).toList();
                final hasMoreEvents =
                    events.length > 3; // Check if there are more than 3 events

                return Positioned(
                  bottom:
                      1.0, // Adjust this value to position the markers below the date box
                  right: 0.0,
                  left: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the points and plus sign
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Align children vertically in the middle
                    children: [
                      // Display up to 3 points
                      ...limitedEvents.map((event) {
                        final color =
                            (event as Map<String, dynamic>)["color"] ??
                                Colors.grey;
                        return Container(
                          width: 6.0,
                          height: 6.0,
                          margin: const EdgeInsets.symmetric(
                            horizontal:
                                1.0, // Horizontal spacing between points
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),

                      // Add a "+" sign if there are more than 3 events
                      if (hasMoreEvents)
                        Container(
                          width: 12.0, // Increase the width
                          height: 14.0, // Increase the height
                          margin: const EdgeInsets.symmetric(
                            horizontal: 1.0, // Horizontal spacing
                          ),
                          alignment: Alignment
                              .center, // Center the plus sign vertically
                          child: Text(
                            "+",
                            style: TextStyle(
                              fontSize: 10.0, // Increase the font size
                              color: const Color.fromARGB(
                                  255, 0, 0, 0), // Text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        color: Colors.white, // Background color for the card
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with background color
                          Container(
                            decoration: BoxDecoration(
                              color: event["color"] ??
                                  const Color.fromARGB(
                                      255, 0, 0, 0), // Solid color
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  event["title"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Description
                          Text(
                            event["description"],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black, // Black text color
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black, // Black icon color
                                size: 16.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "ទីតាំង៖ ${event["location"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // Black text color
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.black, // Black icon color
                                size: 16.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "ម៉ោង៖ ${event["time"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // Black text color
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Participants
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.black, // Black icon color
                                size: 16.0,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "អ្នកចូលរួម៖ ${event["participants"].join(', ')}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // Black text color
                                ),
                              ),
                            ],
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
              "មិនមានកិច្ជប្រជុំទេ សម្រាប់ថ្ងៃនេះ។",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
