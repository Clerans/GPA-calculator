import 'package:flutter/material.dart';
import 'course_model.dart';
import 'semester_model.dart';
import 'grade_converter.dart';
import 'widgets/gradient_summary_card.dart';
import 'services/pdf_service.dart';
import 'services/storage_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GPACalculatorApp());
}

class GPACalculatorApp extends StatelessWidget {
  const GPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University GPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
  List<Semester> _semesters = [];
  bool _isLoading = true;

  // Sri Lankan University Standard Grading System
  final List<String> _gradeOptions = [
    'A+', 'A', 'A-',
    'B+', 'B', 'B-',
    'C+', 'C', 'C-',
    'D+', 'D',
    'E', 'F'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedData = await StorageService.loadData();
    if (mounted) {
      setState(() {
        if (savedData != null && savedData.semesters.isNotEmpty) {
          _semesters = savedData.semesters;
        } else {
          _semesters = [
            Semester(
              name: 'Semester 1',
              courses: [Course()],
            ),
          ];
        }
        _isLoading = false;
      });
    }
  }

  void _saveData() {
    StorageService.saveData(semesters: _semesters);
  }

  void _addSemester() {
    setState(() {
      final newSemester = Semester(
        name: 'Semester ${_semesters.length + 1}',
        courses: [Course()],
      );
      _semesters.add(newSemester);
    });
    _saveData();
  }

  void _removeSemester(int index) {
    if (_semesters.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one semester must remain.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Semester?'),
        content: Text('Are you sure you want to delete ${_semesters[index].name}? All courses in this semester will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _semesters.removeAt(index);
              });
              _saveData();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editSemesterName(Semester semester) {
    final nameController = TextEditingController(text: semester.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Semester Name'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Year 1 Sem 1, Fall 2024',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  semester.name = nameController.text.trim();
                });
                _saveData();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addCourse(Semester semester) {
    setState(() {
      semester.courses.add(Course());
    });
    _saveData();
  }

  void _removeCourse(Semester semester, int index) {
    setState(() {
      semester.courses.removeAt(index);
    });
    _saveData();
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text('This will clear all entered semesters and courses permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearData();
              setState(() {
                _semesters = [
                  Semester(name: 'Semester 1', courses: [Course()]),
                ];
              });
              _saveData();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
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
          totalPoints += points * credits;
          totalCredits += credits;
        }
      }
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  double _calculateSemesterGPA(Semester semester) {
    double totalPoints = 0;
    double totalCredits = 0;

    for (var course in semester.courses) {
      double credits = double.tryParse(course.creditsController.text) ?? 0;
      if (credits <= 0) continue;

      if (course.grade != null) {
        double points = GradeConverter.convertToPoints(course.grade!);
        totalPoints += points * credits;
        totalCredits += credits;
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
    if (gpa >= 3.3) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.7) return 'B-';
    if (gpa >= 2.3) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.0) return 'D';
    return gpa > 0 ? 'F' : '-';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double currentGPA = _calculateGPA();
    String degreeClass = GradeConverter.getDegreeClassification(currentGPA);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('University GPA Calculator'),
            Text('Honours Degree & Semester Tracker',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export Transcript PDF',
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF2D3436)),
            onPressed: () async {
              final pdfData = await PdfService.generatePdf(
                semesters: _semesters,
                cumulativeGpa: _calculateGPA(),
              );
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfData,
                name: 'Academic_GPA_Report.pdf',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D3436)),
            onSelected: (value) {
              if (value == 'reset') {
                _clearAllData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Reset All Data', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GPA & Honours Classification Summary Card
              GradientSummaryCard(
                gpa: currentGPA,
                totalCredits: _calculateTotalCredits(),
                letterGrade: _getLetterGrade(currentGPA),
                degreeClassification: degreeClass,
              ),
              const SizedBox(height: 20),

              // Semesters Header with Local Auto-Save Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semesters (${_semesters.length}) • Courses (${_calculateTotalCourses()})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF00B894)),
                      SizedBox(width: 4),
                      Text(
                        'Saved Locally',
                        style: TextStyle(fontSize: 12, color: Color(0xFF00B894), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Semesters List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _semesters.length,
                itemBuilder: (context, semesterIndex) {
                  final semester = _semesters[semesterIndex];
                  final semGPA = _calculateSemesterGPA(semester);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Semester Header: Name, GPA badge, Add Course, Delete
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _editSemesterName(semester),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          semester.name.toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF2D3436),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Per Semester GPA Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sem GPA: ${semGPA.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Add Course Button
                            IconButton(
                              tooltip: 'Add Subject',
                              icon: const Icon(Icons.add_circle, color: Color(0xFF00B894)),
                              onPressed: () => _addCourse(semester),
                            ),
                            // Delete Semester Button
                            if (_semesters.length > 1)
                              IconButton(
                                tooltip: 'Delete Semester',
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _removeSemester(semesterIndex),
                              ),
                          ],
                        ),
                        const Divider(color: Color(0xFFEDF2F7), height: 20),

                        if (semester.courses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () => _addCourse(semester),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add your first subject to this semester'),
                              ),
                            ),
                          ),

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
                                      child: _buildModernField(
                                        course.nameController,
                                        'Subject / Module Name',
                                        onChanged: (v) => _saveData(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Remove Subject',
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _removeCourse(semester, courseIndex),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Grade Dropdown
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Grade', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 4),
                                          _buildModernDropdown(
                                            course.grade,
                                            _gradeOptions,
                                            (v) {
                                              setState(() => course.grade = v);
                                              _saveData();
                                            },
                                            hint: 'Grade (e.g. A, B+)',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Credits Field
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Credits', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 4),
                                          _buildModernField(
                                            course.creditsController,
                                            '3',
                                            numeric: true,
                                            onChanged: (v) {
                                              setState(() {});
                                              _saveData();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Gradient Add Semester Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF6C5CE7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2979FF).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _addSemester,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add Another Semester',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField(
    TextEditingController controller,
    String hint, {
    bool numeric = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildModernDropdown(
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? hint,
    double fontSize = 14,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(fontSize: fontSize, color: const Color(0xFF2D3436), fontWeight: FontWeight.w500),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2D3436)),
      ),
    );
  }
}
