import 'package:flutter/material.dart';
import 'course_model.dart';

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
    'C+', 'C', 
    'D', 'F'
  ];

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
    setState(() {
      _courses.removeAt(index);
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
