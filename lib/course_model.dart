import 'package:flutter/material.dart';

class Course {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController creditsController = TextEditingController();
  String? grade;

  Course({this.grade});
}
