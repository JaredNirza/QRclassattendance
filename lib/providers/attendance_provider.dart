import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../services/database_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Student> _students = [];
  List<AttendanceRecord> _todayRecords = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  List<AttendanceRecord> get todayRecords => _todayRecords;
  bool get isLoading => _isLoading;

  /// Dynamic Summary Counter 1: Total Enrolled active students
  int get totalEnrolled => _students.length;

  /// Dynamic Summary Counter 2: Unique students marked present today
  int get presentToday {
    return _todayRecords.map((record) => record.studentId).toSet().length;
  }

  /// Dynamic Summary Counter 3: Absent / Dropped
  int get absentCount {
    final diff = totalEnrolled - presentToday;
    return diff < 0 ? 0 : diff;
  }

  AttendanceProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbService.init();
      _students = await _dbService.getStudents();
      _todayRecords = await _dbService.getTodayAttendance();
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new student, immediately persists to SQLite, and updates counters
  Future<void> registerStudent(Student student) async {
    await _dbService.insertStudent(student);
    _students = await _dbService.getStudents();
    notifyListeners();
  }

  /// Removes a student from the database and updates both enrolled and present counters
  Future<void> deleteStudent(String studentId) async {
    await _dbService.deleteStudent(studentId);
    _students = await _dbService.getStudents();
    _todayRecords = await _dbService.getTodayAttendance();
    notifyListeners();
  }

  /// Scans / Marks attendance with 3-tier checks:
  /// 1. Unregistered ID check
  /// 2. Already scanned today check
  /// 3. Valid scan -> inserts into SQLite and refreshes counters
  Future<AttendanceScanResult> markAttendance(String studentId) async {
    final result = await _dbService.markAttendance(studentId);
    if (result.status == AttendanceScanStatus.success) {
      _todayRecords = await _dbService.getTodayAttendance();
      notifyListeners();
    }
    return result;
  }

  /// Helper to check if a specific student is present today
  bool isStudentPresentToday(String studentId) {
    return _todayRecords.any((r) => r.studentId == studentId);
  }

  /// Helper to find student by ID
  Student? findStudentById(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (_) {
      return null;
    }
  }
}
