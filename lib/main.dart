import 'package:flutter/material.dart';
import 'course_model.dart';
import 'semester_model.dart';
import 'grade_converter.dart';
import 'widgets/gradient_summary_card.dart';
import 'services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light Grey Modern Background
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
           backgroundColor: Colors.white,
           elevation: 0,
           scrolledUnderElevation: 0,
           titleTextStyle: TextStyle(color: Color(0xFF2D3436), fontSize: 20, fontWeight: FontWeight.bold),
           iconTheme: IconThemeData(color: Color(0xFF2D3436)),
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

  double _calculateTotalCredits() {
    double total = 0;
    for (var semester in _semesters) {
      for (var course in semester.courses) {
        total += double.tryParse(course.creditsController.text) ?? 0;
      }
    }
    return total;
  }

  int _calculateTotalCourses() {
    int total = 0;
    for (var semester in _semesters) {
      total += semester.courses.length;
    }
    return total;
  }

  String _getLetterGrade(double gpa) {
    if (gpa >= 4.0) return 'A+';
    if (gpa >= 3.7) return 'A';
    if (gpa >= 3.3) return 'B+'; // Approximation, usually mapped from points but simpler here
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.0) return 'D';
    return gpa > 0 ? 'F' : '-';
  }

  @override
  Widget build(BuildContext context) {
    double currentGPA = _calculateGPA();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
             Text('GPA Calculator'),
             Text('Track your academic progress', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
           IconButton(
             icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF2D3436)),
             onPressed: () async {
                final pdfData = await PdfService.generatePdf(
                  semesters: _semesters,
                  cumulativeGpa: _calculateGPA(),
                  isWeighted: _isWeighted,
                );
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfData,
                  name: 'GPA_Report.pdf',
                );
             },
           ),
           const SizedBox(width: 8),
        ],
      ),
      // Removed FloatingActionButton to use standard UI or put in AppBar

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header / GPA Card
              GradientSummaryCard(
                gpa: currentGPA,
                totalCredits: _calculateTotalCredits(),
                letterGrade: _getLetterGrade(currentGPA),
              ),
              const SizedBox(height: 24),

              Text(
                'Your Courses (${_calculateTotalCourses()})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _semesters.length,
                itemBuilder: (context, semesterIndex) {
                  final semester = _semesters[semesterIndex];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                semester.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E586E)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFF26C6DA)), // Cyan
                                onPressed: () => _addCourse(semester),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white), // Light divider looks engraved
                          ...semester.courses.asMap().entries.map((entry) {
                            int courseIndex = entry.key;
                            Course course = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: _buildModernField(course.nameController, 'Course Name'),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                         icon: const Icon(Icons.delete_outline, color: Colors.red),
                                         onPressed: () => _removeCourse(semester, courseIndex),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // Grade
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Grade', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 4),
                                            _buildModernDropdown(
                                              course.grade,
                                              _gradeOptions,
                                              (v) => setState(() => course.grade = v),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Credits
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Credits', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 4),
                                            _buildModernField(
                                              course.creditsController,
                                              '0',
                                              numeric: true,
                                              onChanged: (v) => setState(() {}),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                         flex: 2,
                                         child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                              const SizedBox(height: 4),
                                              _buildModernDropdown(
                                                course.courseType,
                                                _courseTypes,
                                                (v) => setState(() => course.courseType = v!),
                                                fontSize: 12,
                                              ),
                                            ],
                                         ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                },
              ),

              const SizedBox(height: 24),
              
              // Gradient Add Semester Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF7C4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2979FF).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _addSemester,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add Semester', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildModernField(TextEditingController controller, String hint, {bool numeric = false, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildModernDropdown(String? value, List<String> items, Function(String?) onChanged, {String? hint, double fontSize = 14}) {
     return Container(
       decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: fontSize, color: const Color(0xFF2D3436), fontWeight: FontWeight.w500)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2D3436)),
      ),
    );
  }
}
