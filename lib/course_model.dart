import 'package:flutter/material.dart';

class Course {
  final TextEditingController nameController;
  final TextEditingController creditsController;
  String? grade;

  Course({
    String name = '',
    String credits = '',
    this.grade,
  })  : nameController = TextEditingController(text: name),
        creditsController = TextEditingController(text: credits);

  Map<String, dynamic> toJson() {
    return {
      'name': nameController.text,
      'credits': creditsController.text,
      'grade': grade,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'] as String? ?? '',
      credits: json['credits'] as String? ?? '',
      grade: json['grade'] as String?,
    );
  }

  void dispose() {
    nameController.dispose();
    creditsController.dispose();
  }
}
