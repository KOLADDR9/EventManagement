import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the package for date formatting
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import 'dart:convert';

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

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print("Error parsing date: $dateString - $e");
      return DateTime.now();
    }
  }

  String parseColor(String? color) {
    if (color == null || color.isEmpty) return "0xFF2196F3"; // Default to blue
    return "0xFF${color.replaceAll('#', '')}"; // Remove '#' if present
  }

  String decodeUtf8(String text) {
    return utf8.decode(text.runes.toList());
  }

  String _getMonthName(DateTime date) {
    // Use the DateFormat class to get the month name from the selected date
    return DateFormat('MMMM')
        .format(date); // Formats month as a full name like "January"
  }

  String _getKhmerDayName(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7; // Saturday or Sunday
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getMonthName(selectedDate)} ${selectedDate.year}', // Use updated _getMonthName
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () async {
                      DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (newDate != null && newDate != selectedDate) {
                        onDaySelected(
                            newDate, newDate); // Update the selected date
                      }
                    },
                  ),
                ],
              ),
              TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                calendarFormat: calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                eventLoader: (date) {
                  return events[_normalizeDate(date)] ?? [];
                },
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                onDaySelected: onDaySelected,
                onFormatChanged: onFormatChanged,
                locale: 'en_GB',
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  formatButtonVisible: false,
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, date) {
                    return Text(
                      '${_getMonthName(date)} ${date.year}', // Use updated _getMonthName here too
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    );
                  },
                  dowBuilder: (context, day) {
                    final khmerDayName = _getKhmerDayName(day);
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        khmerDayName,
                        style: TextStyle(
                          color: _isWeekend(day) ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, eventList) {
                    if (eventList.isNotEmpty) {
                      final limitedEvents = eventList.take(3).toList();
                      final hasMoreEvents = eventList.length > 3;

                      return Positioned(
                        bottom: 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...limitedEvents.map((event) {
                              final eventObj = event as Event;
                              final color = parseColor(eventObj.color);
                              return Container(
                                width: 6.0,
                                height: 6.0,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1.0),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(color)),
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                            if (hasMoreEvents)
                              const Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
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
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(int.parse(parseColor(event.color))),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.description_outlined,
                                      color: Colors.black, size: 20.0),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Description:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: event.type,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      size: 20.0),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Location: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: event.place,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  size: 20.0),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Time: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: isSameDay(
                                              event.startTime, selectedDate)
                                          ? "${DateFormat("hh:mm a").format(event.startTime)} - ${DateFormat("hh:mm a").format(event.endTime)}"
                                          : "${DateFormat("yyyy-MM-dd hh:mm a").format(event.startTime)} - ${DateFormat("yyyy-MM-dd hh:mm a").format(event.endTime)}",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.people_outline,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  size: 20.0),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Participants:\n",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: event.employees
                                            .map((e) => e.name)
                                            .join('\n'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("មិនមានកិច្ចប្រជុំទេថ្ងៃនេះ។"),
          ),
      ],
    );
  }
}
