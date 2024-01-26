import 'dart:convert';

class Room {
  const Room(
      {required this.name, this.mon, this.tue, this.wed, this.thu, this.fri});

  final String name;
  final List<String>? mon;
  final List<String>? tue;
  final List<String>? wed;
  final List<String>? thu;
  final List<String>? fri;

  String toJson() {
    return jsonEncode({
      'name': name,
      'mon': mon,
      'tue': tue,
      'wed': wed,
      'thu': thu,
      'fri': fri,
    });
  }

  static Room fromJson(Map<String, dynamic> jsonData) {
    String name = jsonData['name'] as String;
    List<String> mon =
        (jsonData['mon'] as List<dynamic>).map((e) => e.toString()).toList();
    List<String> tue =
        (jsonData['tue'] as List<dynamic>).map((e) => e.toString()).toList();
    List<String> wed =
        (jsonData['wed'] as List<dynamic>).map((e) => e.toString()).toList();
    List<String> thu =
        (jsonData['thu'] as List<dynamic>).map((e) => e.toString()).toList();
    List<String> fri =
        (jsonData['fri'] as List<dynamic>).map((e) => e.toString()).toList();

    return Room(
      name: jsonData['name'],
      mon: mon,
      tue: tue,
      wed: wed,
      thu: thu,
      fri: fri,
    );
  }
}
