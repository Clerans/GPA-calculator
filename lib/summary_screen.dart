import 'package:flutter/material.dart';
import 'course_model.dart';
import 'grade_converter.dart';

class SummaryScreen extends StatelessWidget {
  final double gpa;
  final List<Course> courses;

  const SummaryScreen({super.key, required this.gpa, required this.courses});

  @override
  Widget build(BuildContext context) {
    // calculate total credits again or pass it. calculating here is fine.
    double totalCredits = 0;
    List<Course> validCourses = [];

    for (var course in courses) {
      double credits = double.tryParse(course.creditsController.text) ?? 0;
      if (credits > 0 && course.grade != null) {
        totalCredits += credits;
        validCourses.add(course);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // GPA Card
            Card(
              elevation: 4.0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Semester GPA',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gpa.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 48, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Credits: ${totalCredits.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Course List Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Course Breakdown',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            
            // Course List
            validCourses.isEmpty
                ? const Text('No valid courses to display.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: validCourses.length,
                    itemBuilder: (context, index) {
                      final course = validCourses[index];
                      double credits = double.tryParse(course.creditsController.text) ?? 0;
                      double points = GradeConverter.convertToPoints(course.grade!);
                      double totalPoints = points * credits;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            course.nameController.text.isEmpty
                                ? 'Unnamed Course'
                                : course.nameController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Credits: ${credits.toStringAsFixed(1)} | Grade: ${course.grade} ($points)',
                          ),
                          trailing: Text(
                            'Pts: ${totalPoints.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
