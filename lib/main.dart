import 'package:flutter/material.dart';
import 'course_model.dart';
import 'semester_model.dart';
import 'grade_converter.dart';
import 'widgets/gpa_gauge.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
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
  final List<Semester> _semesters = [];
  bool _isWeighted = false;

  final List<String> _gradeOptions = [
    'A+', 'A', 'A-', 
    'B+', 'B', 'B-', 
    'C+', 'C', 'C-',
    'D', 'F'
  ];

  final List<String> _courseTypes = ['Regular', 'Honors', 'AP'];

  @override
  void initState() {
    super.initState();
    _addSemester();
  }

  void _addSemester() {
    setState(() {
      _semesters.add(Semester(name: 'Semester ${_semesters.length + 1}'));
      _addCourse(_semesters.last);
    });
  }

  void _addCourse(Semester semester) {
    setState(() {
      semester.courses.add(Course());
    });
  }

  void _removeCourse(Semester semester, int index) {
    setState(() {
      semester.courses.removeAt(index);
    });
  }

  double _calculateGPA() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (var semester in _semesters) {
      for (var course in semester.courses) {
        double credits = double.tryParse(course.creditsController.text) ?? 0;
        if (credits <= 0) continue;

        if (course.grade != null) {
          double points = GradeConverter.convertToPoints(course.grade!);
          
          if (_isWeighted) {
            if (course.courseType == 'Honors') {
              points += 0.5;
            } else if (course.courseType == 'AP') {
              points += 1.0;
            }
          }

          totalPoints += points * credits;
          totalCredits += credits;
        }
      }
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double currentGPA = _calculateGPA();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / GPA Card
              GPAGauge(
                gpa: currentGPA,
                maxGpa: _isWeighted ? 5.0 : 4.0,
                isWeighted: _isWeighted,
                onToggleWeighted: (value) {
                  setState(() {
                    _isWeighted = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Semesters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _semesters.length,
                itemBuilder: (context, semesterIndex) {
                  final semester = _semesters[semesterIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                semester.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => _addCourse(semester),
                              ),
                            ],
                          ),
                          const Divider(),
                          ...semester.courses.asMap().entries.map((entry) {
                            int courseIndex = entry.key;
                            Course course = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  // Name
                                  Expanded(
                                    flex: 3,
                                    child: _buildTextField(course.nameController, 'Name'),
                                  ),
                                  const SizedBox(width: 8),
                                  // Grade
                                  Expanded(
                                    flex: 2,
                                    child: _buildDropdown(
                                      course.grade,
                                      _gradeOptions,
                                      (v) => setState(() => course.grade = v),
                                      hint: 'Gr',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Credits
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      course.creditsController,
                                      'Cr',
                                      numeric: true,
                                      onChanged: (v) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Type
                                  Expanded(
                                    flex: 3,
                                    child: _buildDropdown(
                                      course.courseType,
                                      _courseTypes,
                                      (v) => setState(() => course.courseType = v!),
                                      fontSize: 12,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                    onPressed: () => _removeCourse(semester, courseIndex),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),

              Center(
                child: TextButton.icon(
                  onPressed: _addSemester,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Semester'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTextField(TextEditingController controller, String hint, {bool numeric = false, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, {String? hint, double fontSize = 13}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: fontSize)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
