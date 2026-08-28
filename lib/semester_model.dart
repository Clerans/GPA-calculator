import 'course_model.dart';

class Semester {
  String name;
  final List<Course> courses;

  Semester({
    required this.name,
    List<Course>? courses,
  }) : courses = courses ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    var rawCourses = json['courses'] as List<dynamic>? ?? [];
    List<Course> loadedCourses = rawCourses
        .map((c) => Course.fromJson(c as Map<String, dynamic>))
        .toList();

    return Semester(
      name: json['name'] as String? ?? 'Semester',
      courses: loadedCourses,
    );
  }
}
