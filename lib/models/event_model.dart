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
  final bool isOnline;
  final String? onlineLink;
  final String? documentLink;

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
    this.isOnline = false,
    this.onlineLink,
    this.documentLink,
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
      isOnline: json['is_online'] == 1,
      onlineLink: json['online_link'],
      documentLink: json['document_link'],
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
      'is_online': isOnline ? 1 : 0,
      'online_link': onlineLink,
      'document_link': documentLink,
    };
  }

  static DateTime _parseDate(String dateStr) {
    if (dateStr.isEmpty) {
      throw FormatException("Empty date string");
    }
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
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
    return _checkLinkValidity(onlineLink);
  }

  Future<bool> checkDocumentLink() async {
    return _checkLinkValidity(documentLink);
  }

  Future<bool> launchOnlineLink() async {
    return _launchLink(onlineLink);
  }

  Future<bool> launchDocumentLink() async {
    return _launchLink(documentLink);
  }

  Future<bool> _checkLinkValidity(String? link) async {
    if (link == null || link.isEmpty) return false;
    final uri = Uri.tryParse(link);
    if (uri == null) return false;

    try {
      return await canLaunchUrl(uri);
    } catch (e) {
      print('Error checking link: $e');
      return false;
    }
  }

  Future<bool> _launchLink(String? link) async {
    if (link == null || link.isEmpty) return false;
    final uri = Uri.tryParse(link);
    if (uri == null) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching link: $e');
      return false;
    }
  }
}

class Employee {
  final int employeeId;
  final String name;
  final bool isOnline;
  final String? onlineLink;
  final String? documentLink;

  Employee({
    required this.employeeId,
    required this.name,
    this.isOnline = false,
    this.onlineLink,
    this.documentLink,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'],
      name: json['name'],
      isOnline: json['is_online'] == 1,
      onlineLink: json['online_link'],
      documentLink: json['document_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'is_online': isOnline ? 1 : 0,
      'online_link': onlineLink,
      'document_link': documentLink,
    };
  }

  Future<bool> launchOnlineLink() async {
    return _launchLink(onlineLink);
  }

  Future<bool> launchDocumentLink() async {
    return _launchLink(documentLink);
  }

  Future<bool> _launchLink(String? link) async {
    if (link == null || link.isEmpty) return false;
    final uri = Uri.tryParse(link);
    if (uri == null) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching link: $e');
      return false;
    }
  }
}
