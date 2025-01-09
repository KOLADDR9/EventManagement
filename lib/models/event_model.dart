class Event {
  final String title;
  final String startTime;
  final String endTime;
  final String type;
  final String place;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.place,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      startTime: json['start'],
      endTime: json['end'],
      type: json['type'],
      place: json['place'],
    );
  }
}
