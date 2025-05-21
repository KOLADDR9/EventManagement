import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Event {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String place;
  final String color;
  final List<Employee> employees;
  final String createdBy;
  final bool isOnline; // Add this
  final String? onlineLink; // Add this

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.place,
    required this.color,
    required this.employees,
    required this.createdBy,
    this.isOnline = false, // Add this
    this.onlineLink, // Add this
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
      createdBy: json['createdBy'] ?? '',
      isOnline: json['is_online'] == 1, // Add this
      onlineLink: json['online_link'], // Add this
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
      'createdBy': createdBy,
      'is_online': isOnline ? 1 : 0, // Add this
      'online_link': onlineLink, // Add this
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

  Future<bool> checkOnlineLink() async {
    if (!isOnline || onlineLink == null || onlineLink!.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(onlineLink!);
    if (uri == null) {
      return false;
    }

    try {
      if (await canLaunchUrl(uri)) {
        return true;
      }
    } catch (e) {
      print('Error checking link: $e');
    }
    return false;
  }

  Future<bool> launchOnlineLink() async {
    if (await checkOnlineLink()) {
      return launchUrl(Uri.parse(onlineLink!));
    }
    return false;
  }
}

class Employee {
  final int employeeId;
  final String name;
  final bool isOnline;
  final String? onlineLink;

  Employee({
    required this.employeeId,
    required this.name,
    this.isOnline = false,
    this.onlineLink,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      name: json['name'],
      isOnline: json['is_online'] == 1,
      onlineLink: json['online_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'is_online': isOnline ? 1 : 0,
      'online_link': onlineLink,
    };
  }
}
