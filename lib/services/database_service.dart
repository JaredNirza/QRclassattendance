import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';

enum AttendanceScanStatus {
  success,
  alreadyCheckedIn,
  unregistered,
}

class AttendanceScanResult {
  final AttendanceScanStatus status;
  final String message;
  final Student? student;
  final AttendanceRecord? record;

  AttendanceScanResult({
    required this.status,
    required this.message,
    this.student,
    this.record,
  });
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;
  bool _isInitialized = false;

  // In-memory fallback for web or platforms where native SQLite is unavailable
  final List<Student> _memStudents = [];
  final List<AttendanceRecord> _memAttendance = [];
  bool _useInMemoryFallback = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (kIsWeb) {
      _useInMemoryFallback = true;
      _seedDemoDataDirectly();
      return;
    }

    try {
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        try {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        } catch (_) {}
      }

      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'edutrack_attendance.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await _createTables(db);
        },
      );
      await _createTables(_db!);

      await _seedDemoDataDirectly();
    } catch (e) {
      debugPrint('SQLite init failed ($e), falling back to in-memory store.');
      _useInMemoryFallback = true;
      _seedDemoDataDirectly();
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        photoPath TEXT,
        course TEXT NOT NULL,
        yearLevel TEXT NOT NULL,
        section TEXT NOT NULL,
        registeredAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedDemoDataDirectly() async {
    final sampleStudents = [
      Student(
        id: '2026-10492',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        email: 'juan.delacruz@jmc.edu.ph',
        photoPath: '',
        course: 'BSIT',
        yearLevel: '3rd Year',
        section: 'BSIT-3A',
        registeredAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Student(
        id: '2026-10884',
        firstName: 'Maria',
        lastName: 'Santos',
        email: 'maria.santos@jmc.edu.ph',
        photoPath: '',
        course: 'BSCS',
        yearLevel: '3rd Year',
        section: 'BSCS-3A',
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Student(
        id: '2026-11205',
        firstName: 'Kenneth',
        lastName: 'Reyes',
        email: 'kenneth.reyes@jmc.edu.ph',
        photoPath: '',
        course: 'BSCpE',
        yearLevel: '4th Year',
        section: 'BSCpE-4B',
        registeredAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (_useInMemoryFallback || _db == null) {
      if (_memStudents.isEmpty) {
        _memStudents.addAll(sampleStudents);
      }
    } else {
      final existing = await _db!.query('students', limit: 1);
      if (existing.isEmpty) {
        for (final s in sampleStudents) {
          await _db!.insert(
            'students',
            s.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }

  // --- Student Operations ---

  Future<void> insertStudent(Student student) async {
    await init();
    if (_useInMemoryFallback || _db == null) {
      final idx = _memStudents.indexWhere((s) => s.id == student.id);
      if (idx >= 0) {
        _memStudents[idx] = student;
      } else {
        _memStudents.add(student);
      }
      return;
    }

    await _db!.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getStudents() async {
    await init();
    if (_useInMemoryFallback || _db == null) {
      return List<Student>.from(_memStudents);
    }

    final maps = await _db!.query('students', orderBy: 'lastName ASC');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudentById(String id) async {
    await init();
    if (_useInMemoryFallback || _db == null) {
      try {
        return _memStudents.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }

    final maps = await _db!.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<void> deleteStudent(String id) async {
    await init();
    if (_useInMemoryFallback || _db == null) {
      _memStudents.removeWhere((s) => s.id == id);
      _memAttendance.removeWhere((a) => a.studentId == id);
      return;
    }

    await _db!.transaction((txn) async {
      await txn.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'attendance_records',
        where: 'studentId = ?',
        whereArgs: [id],
      );
    });
  }

  // --- Attendance Operations ---

  Future<AttendanceScanResult> markAttendance(String studentId) async {
    await init();
    final student = await getStudentById(studentId);

    // Check 1: Is student in SQLite roster?
    if (student == null) {
      return AttendanceScanResult(
        status: AttendanceScanStatus.unregistered,
        message: 'Unregistered Student ID: $studentId',
      );
    }

    final todayRecords = await getTodayAttendance();

    // Check 2: Is student already scanned today?
    final alreadyChecked = todayRecords.any((rec) => rec.studentId == studentId);
    if (alreadyChecked) {
      return AttendanceScanResult(
        status: AttendanceScanStatus.alreadyCheckedIn,
        message: 'Already Checked In: ${student.fullName}',
        student: student,
      );
    }

    // Check 3: Valid new scan
    final record = AttendanceRecord(
      studentId: student.id,
      studentName: student.fullName,
      timestamp: DateTime.now(),
    );

    if (_useInMemoryFallback || _db == null) {
      _memAttendance.insert(0, record);
    } else {
      final id = await _db!.insert('attendance_records', record.toMap());
      // Return with generated ID
      return AttendanceScanResult(
        status: AttendanceScanStatus.success,
        message: 'Marked Present: ${student.fullName}',
        student: student,
        record: AttendanceRecord(
          id: id,
          studentId: record.studentId,
          studentName: record.studentName,
          timestamp: record.timestamp,
        ),
      );
    }

    return AttendanceScanResult(
      status: AttendanceScanStatus.success,
      message: 'Marked Present: ${student.fullName}',
      student: student,
      record: record,
    );
  }

  Future<List<AttendanceRecord>> getTodayAttendance() async {
    await init();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_useInMemoryFallback || _db == null) {
      return _memAttendance.where((rec) {
        return rec.timestamp.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            rec.timestamp.isBefore(endOfDay.add(const Duration(seconds: 1)));
      }).toList();
    }

    final maps = await _db!.query(
      'attendance_records',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => AttendanceRecord.fromMap(map)).toList();
  }

  Future<List<AttendanceRecord>> getAllAttendance() async {
    await init();
    if (_useInMemoryFallback || _db == null) {
      return List<AttendanceRecord>.from(_memAttendance);
    }

    final maps = await _db!.query(
      'attendance_records',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => AttendanceRecord.fromMap(map)).toList();
  }
}
