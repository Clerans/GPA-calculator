import 'package:flutter/material.dart';
import 'course_model.dart';
import 'grade_converter.dart';


void main() {
  runApp(const GPACalculatorApp());
}

class GPACalculatorApp extends StatelessWidget {
  const GPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University GPA Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Course> _courses = [];

  // Standard Grading Scale
  final List<String> _gradeOptions = [
    'A+', 'A', 'A-', 
    'B+', 'B', 'B-', 
    'C+', 'C', 'C-',
    'D', 'F'
  ];

  double _gpa = 0.0;

  void _calculateGPA() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (var course in _courses) {
      double credits = double.tryParse(course.creditsController.text) ?? 0;
      if (course.grade != null) {
        double points = GradeConverter.convertToPoints(course.grade!);
        totalPoints += points * credits;
        totalCredits += credits;
      }
    }

    setState(() {
      _gpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    // Start with one empty course for convenience
    _addCourse();
  }

  void _addCourse() {
    setState(() {
      _courses.add(Course());
    });
  }

  void _removeCourse(int index) {
    });
    // Add listener to calculate GPA on credit change
    _courses.last.creditsController.addListener(_calculateGPA);
  }

  void _removeCourse(int index) {
    setState(() {
      _courses[index].creditsController.removeListener(_calculateGPA);
      _courses.removeAt(index);
      _calculateGPA();
    });
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var course in _courses) {
      course.nameController.dispose();
      course.creditsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University GPA Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calculated GPA:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _gpa.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _courses.isEmpty
          ? Center(
              child: Text(
                'Add a course to get started',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Name Input
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _courses[index].nameController,
                            decoration: const InputDecoration(
                              labelText: 'Course Name',
                              hintText: 'e.g. Math 101',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Credits Input
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _courses[index].creditsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              hintText: '3',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Grade Dropdown
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _courses[index].grade,
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            ),
                            items: _gradeOptions.map((String grade) {
                              return DropdownMenuItem<String>(
                                value: grade,
                                child: Text(grade),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _courses[index].grade = newValue;
                                _calculateGPA();
                              });
                            },
                          ),
                        ),
                        
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCourse(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        tooltip: 'Add Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}
