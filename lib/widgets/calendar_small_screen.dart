import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '/theme/font_fm.dart';

class CalendarSmallScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> eventDetails;
  final Map<DateTime, List<Event>> events;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final String Function(String?) parseColor;
  final String Function(DateTime) getKhmerDayName;
  final bool Function(DateTime) isWeekend;

  const CalendarSmallScreen({
    Key? key,
    required this.selectedDate,
    required this.eventDetails,
    required this.events,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.parseColor,
    required this.getKhmerDayName,
    required this.isWeekend,
  }) : super(key: key);

  // Add this helper method at class level
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: const EdgeInsets.only(bottom: 32.0),
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
                      child: TableCalendar(
                        focusedDay: selectedDate,
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2050),
                        calendarFormat: calendarFormat,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        eventLoader: (date) {
                          final normalizedDate = _normalizeDate(date);
                          final dayEvents = events[normalizedDate] ?? [];

                          // Filter events that are active on this date
                          return dayEvents.where((event) {
                            final eventStart = _normalizeDate(event.startTime);
                            final eventEnd = _normalizeDate(event.endTime);
                            return !normalizedDate.isBefore(eventStart) &&
                                !normalizedDate.isAfter(eventEnd);
                          }).toList();
                        },
                        selectedDayPredicate: (day) =>
                            isSameDay(day, selectedDate),
                        onDaySelected: onDaySelected,
                        locale: 'en_GB',
                        headerVisible: true, // Ensure header is visible
                        headerStyle: HeaderStyle(
                          formatButtonVisible:
                              false, // Optional: Hide the format button
                          titleCentered:
                              true, // Center the title (Month and Year)
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          rightChevronIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_right,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              IconButton(
                                icon: Icon(Icons.today, color: Colors.white),
                                onPressed: () => onDaySelected(
                                    DateTime.now(), DateTime.now()),
                                tooltip: 'Today',
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 20,
                              ),
                            ],
                          ),
                          headerPadding: EdgeInsets.symmetric(vertical: 8.0),
                          titleTextStyle: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF083E68), // #083E68
                                Color(0xFF107BCE), // #107BCE
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ), // Background color for the header
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          rightChevronMargin: EdgeInsets.only(right: 12),
                          leftChevronMargin: EdgeInsets.only(left: 12),
                          headerMargin: EdgeInsets.only(bottom: 8),
                        ),

                        daysOfWeekHeight: 60.0,
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: constraints.maxWidth > 500 ? 18.0 : 14.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 145, 17, 8),
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
                            final khmerDayName = getKhmerDayName(day);
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                khmerDayName,
                                style: TextStyle(
                                  color: isWeekend(day)
                                      ? Color.fromARGB(255, 145, 17, 8)
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
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center alignment for event markers
                                    children: [
                                      ...limitedEvents.map((event) {
                                        final eventObj = event as Event;
                                        final color =
                                            parseColor(eventObj.color);
                                        return Container(
                                          width: 6.0,
                                          height: 6.0,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF083E68),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                      if (hasMoreEvents)
                                        const Icon(
                                          Icons.more_horiz,
                                          size: 8.0,
                                          color: Color(0xFF083E68),
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
                              margin: const EdgeInsets.all(6.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(90, 184, 255, 0.274),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${date.day}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 32, 32, 32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 10, 104, 180),
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
                    );
                  },
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
                            bottom: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Color(int.parse(parseColor(event.color))),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              // color: Color(0xFF083E68),
                                              // Don't specify color here to use the theme's color
                                            ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0), // Padding inside the row
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: Colors.black, size: 20.0),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "ទីតាំង: ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: event.place,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0), // Padding inside the row
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.black, size: 20.0),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "ពេលវេលា: ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: !isSameDay(event.startTime,
                                                      event.endTime)
                                                  ? "${DateFormat("hh:mm a").format(event.startTime)} - ${DateFormat("hh:mm a").format(event.endTime)}"
                                                  : "${DateFormat("hh:mm a").format(event.startTime)} - ${DateFormat("hh:mm a").format(event.endTime)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0), // Padding inside the row
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.people_outline,
                                        color: Colors.black, size: 20.0),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "អ្នកចូលរួម:\n",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: event.employees
                                                  .map((e) => e.name)
                                                  .join('\n'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //  CreatedBy
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end, // Align to right
                                  children: [
                                    Icon(Icons.checklist,
                                        color: const Color.fromARGB(
                                            255, 175, 175, 175),
                                        size: 20.0),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        text:
                                            event.createdBy ?? "មិនមានព័ត៌មាន",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15,
                                              color: const Color.fromARGB(
                                                  255, 175, 175, 175),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "ថ្ងៃនេះ មិនមានកិច្ចប្រជុំទេ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... [Keep the existing _buildCalendar and _buildEventList methods from the small screen implementation]
}
