import 'package:flutter_test/flutter_test.dart';
import 'package:gpa_calculator/grade_converter.dart';

void main() {
  group('GradeConverter Tests', () {
    test('A+ should return 4.0', () {
      expect(GradeConverter.convertToPoints('A+'), 4.0);
    });

    test('A should return 4.0', () {
      expect(GradeConverter.convertToPoints('A'), 4.0);
    });

    test('A- should return 3.7', () {
      expect(GradeConverter.convertToPoints('A-'), 3.7);
    });

    test('B+ should return 3.3', () {
      expect(GradeConverter.convertToPoints('B+'), 3.3);
    });

    test('B should return 3.0', () {
      expect(GradeConverter.convertToPoints('B'), 3.0);
    });

    test('B- should return 2.7', () {
      expect(GradeConverter.convertToPoints('B-'), 2.7);
    });

    test('C+ should return 2.3', () {
      expect(GradeConverter.convertToPoints('C+'), 2.3);
    });

    test('C should return 2.0', () {
      expect(GradeConverter.convertToPoints('C'), 2.0);
    });

    test('D should return 1.0', () {
      expect(GradeConverter.convertToPoints('D'), 1.0);
    });

    test('F should return 0.0', () {
      expect(GradeConverter.convertToPoints('F'), 0.0);
    });

    test('Invalid grade should return 0.0', () {
      expect(GradeConverter.convertToPoints('Z'), 0.0);
    });
  });
}
