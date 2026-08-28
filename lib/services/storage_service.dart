import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../semester_model.dart';

class StorageData {
  final List<Semester> semesters;

  StorageData({required this.semesters});
}

class StorageService {
  static const String _semestersKey = 'saved_semesters_data_v2';

  static Future<void> saveData({
    required List<Semester> semesters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final semestersJsonList = semesters.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(semestersJsonList);
      await prefs.setString(_semestersKey, jsonString);
    } catch (e) {
      // Handle gracefully
    }
  }

  static Future<StorageData?> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_semestersKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final List<Semester> semesters = decoded
            .map((item) => Semester.fromJson(item as Map<String, dynamic>))
            .toList();
        return StorageData(semesters: semesters);
      }
    } catch (e) {
      // Handle gracefully
    }
    return null;
  }

  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_semestersKey);
  }
}
