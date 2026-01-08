import 'package:flutter/material.dart';

class Course {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController creditsController = TextEditingController();
  String? grade;
  String courseType; // 'Regular', 'Honors', 'AP'

  Course({this.grade, this.courseType = 'Regular'});
}
