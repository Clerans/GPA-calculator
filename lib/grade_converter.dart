class GradeConverter {
  static double convertToPoints(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'E':
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  static String getDegreeClassification(double gpa) {
    if (gpa >= 3.70) return 'First Class Honours';
    if (gpa >= 3.30) return 'Second Upper (2:1)';
    if (gpa >= 3.00) return 'Second Lower (2:2)';
    if (gpa >= 2.00) return 'General Pass';
    if (gpa > 0) return 'Below Pass (< 2.0)';
    return 'No GPA yet';
  }
}
