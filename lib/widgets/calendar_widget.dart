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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          // For larger screens, display side by side
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar on the left
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_getMonthName(selectedDate)} ${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF107BCE),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF107BCE),
                            ),
                            onPressed: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (newDate != null && newDate != selectedDate) {
                                onDaySelected(newDate, newDate);
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
                        selectedDayPredicate: (day) =>
                            isSameDay(day, selectedDate),
                        onDaySelected: onDaySelected,
                        locale: 'en_GB',
                        headerVisible: false,
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          cellMargin: EdgeInsets.symmetric(
                            vertical: 16.0, // Space from top and bottom
                            horizontal: 16.0, // Space between cells
                          ), // More space between cells
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF107BCE),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF2196F3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        pageAnimationEnabled: true,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            final khmerDayName = _getKhmerDayName(day);
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                khmerDayName,
                                style: TextStyle(
                                  color: _isWeekend(day)
                                      ? Colors.red
                                      : Colors.black,
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
                              return Column(
                                children: [
                                  Spacer(), // Pushes the markers to the bottom
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ...limitedEvents.map((event) {
                                        final eventObj = event as Event;
                                        final color =
                                            parseColor(eventObj.color);
                                        return Container(
                                          width: 8.0,
                                          height: 8.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(color)),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                      if (hasMoreEvents)
                                        const Icon(
                                          Icons.more_horiz,
                                          size: 8.0,
                                          color: Color.fromARGB(255, 255, 0, 0),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          todayBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF107BCE),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    width: 16), // Space between calendar and meeting info
                // Meeting info on the right
                Expanded(
                  flex: 1,
                  child: eventDetails.isNotEmpty
                      ? SingleChildScrollView(
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
                                        blurRadius: 4.0,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(int.parse(
                                              parseColor(event.color))),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8.0),
                                            bottomRight: Radius.circular(8.0),
                                          ),
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
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
                                                    text: "ទីតាំង: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              size: 20.0),
                                          const SizedBox(width: 8),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "ពេលវេលា: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                TextSpan(
                                                  text: isSameDay(
                                                          event.startTime,
                                                          selectedDate)
                                                      ? "${DateFormat("hh:mm a").format(event.startTime)} - ${DateFormat("hh:mm a").format(event.endTime)}"
                                                      : "${DateFormat("yyyy-MM-dd hh:mm a").format(event.startTime)} - ${DateFormat("yyyy-MM-dd hh:mm a").format(event.endTime)}",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.people_outline,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              size: 20.0),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "អ្នកចូលរួម:\n",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2196F3), // Light grey background
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "ថ្ងៃនេះ មិនមានកិច្ចប្រជុំទេ។",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        } else {
          // For smaller screens, display in a column
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_getMonthName(selectedDate)} ${selectedDate.year}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF107BCE),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF107BCE),
                            ),
                            onPressed: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (newDate != null && newDate != selectedDate) {
                                onDaySelected(newDate, newDate);
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
                        selectedDayPredicate: (day) =>
                            isSameDay(day, selectedDate),
                        onDaySelected: onDaySelected,
                        locale: 'en_GB',
                        headerVisible: false,
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                        pageAnimationEnabled: true,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            final khmerDayName = _getKhmerDayName(day);
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                khmerDayName,
                                style: TextStyle(
                                  color: _isWeekend(day)
                                      ? Colors.red
                                      : Colors.black,
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
                              return Column(
                                children: [
                                  Spacer(), // Pushes the markers to the bottom
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ...limitedEvents.map((event) {
                                        final eventObj = event as Event;
                                        final color =
                                            parseColor(eventObj.color);
                                        return Container(
                                          width: 8.0,
                                          height: 8.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(color)),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                      if (hasMoreEvents)
                                        const Icon(
                                          Icons
                                              .more_horiz, // Use more_horiz icon
                                          size: 8.0,
                                          color: Color.fromARGB(255, 255, 0, 0),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          todayBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF107BCE),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (eventDetails.isNotEmpty)
                        Column(
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
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(
                                            int.parse(parseColor(event.color))),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8.0),
                                          bottomRight: Radius.circular(8.0),
                                        ),
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                color: const Color.fromARGB(
                                                    255, 0, 0, 0),
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
                                                  text: "ទីតាំង: ",
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
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            size: 20.0),
                                        const SizedBox(width: 8),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "ពេលវេលា: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: isSameDay(event.startTime,
                                                        selectedDate)
                                                    ? "${DateFormat("hh:mm a").format(event.startTime)} - ${DateFormat("hh:mm a").format(event.endTime)}"
                                                    : "${DateFormat("yyyy-MM-dd hh:mm a").format(event.startTime)} - ${DateFormat("yyyy-MM-dd hh:mm a").format(event.endTime)}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.people_outline,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            size: 20.0),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "អ្នកចូលរួម:\n",
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
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("ថ្ងៃនេះ មិនមានកិច្ចប្រជុំទេ។"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
