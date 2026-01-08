import 'course_model.dart';

class Semester {
  String name;
  final List<Course> courses;

  Semester({required this.name, List<Course>? courses}) 
      : courses = courses ?? [];
}
