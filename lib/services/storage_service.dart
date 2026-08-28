import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../semester_model.dart';

class StorageData {
  final List<Semester> semesters;
  final bool isWeighted;

  StorageData({required this.semesters, required this.isWeighted});
}

class StorageService {
  static const String _semestersKey = 'saved_semesters_data';
  static const String _weightedKey = 'saved_weighted_gpa';

  static Future<void> saveData({
    required List<Semester> semesters,
    required bool isWeighted,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final semestersJsonList = semesters.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(semestersJsonList);
      await prefs.setString(_semestersKey, jsonString);
      await prefs.setBool(_weightedKey, isWeighted);
    } catch (e) {
      // Handle or log error gracefully
    }
  }

  static Future<StorageData?> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_semestersKey);
      final isWeighted = prefs.getBool(_weightedKey) ?? false;

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final List<Semester> semesters = decoded
            .map((item) => Semester.fromJson(item as Map<String, dynamic>))
            .toList();
        return StorageData(semesters: semesters, isWeighted: isWeighted);
      }
    } catch (e) {
      // Handle or log error gracefully
    }
    return null;
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_semestersKey);
    await prefs.remove(_weightedKey);
  }
}
