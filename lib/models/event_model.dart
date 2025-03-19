import 'package:intl/intl.dart';

class Event {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String place;
  final String color;
  final List<Employee> employees;
  final String createdBy; // Add this line

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.place,
    required this.color,
    required this.employees,
    required this.createdBy, // Add this line
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      startTime: _parseDate(json['start'] ?? ''),
      endTime: _parseDate(json['end'] ?? ''),
      type: json['type'],
      place: json['place'],
      color: json['color'] ?? "#000000",
      employees: (json['employees'] as List<dynamic>?)
              ?.map((e) => Employee.fromJson(e))
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '', // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start': DateFormat("yyyy-MM-dd HH:mm:ss").format(startTime),
      'end': DateFormat("yyyy-MM-dd HH:mm:ss").format(endTime),
      'type': type,
      'place': place,
      'color': color,
      'employees': employees.map((e) => e.toJson()).toList(),
      'createdBy': createdBy, // Add this line
    };
  }

  static DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) {
      throw FormatException("Empty date string");
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr);
      } catch (e) {
        print("Error parsing date: $dateStr, Exception: $e");
        throw FormatException("Invalid date format: $dateStr");
      }
    }
  }

  bool isOnDate(DateTime date) {
    final eventDate = DateTime(date.year, date.month, date.day);
    final start = DateTime(startTime.year, startTime.month, startTime.day);
    final end = DateTime(endTime.year, endTime.month, endTime.day);

    return (eventDate.isAtSameMomentAs(start) || eventDate.isAfter(start)) &&
        (eventDate.isAtSameMomentAs(end) || eventDate.isBefore(end));
  }
}

class Employee {
  final int employeeId;
  final String name;

  Employee({
    required this.employeeId,
    required this.name,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
    };
  }
}
