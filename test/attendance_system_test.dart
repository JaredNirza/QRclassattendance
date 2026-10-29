import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/models/student.dart';
import 'package:my_project/models/attendance_record.dart';
import 'package:my_project/services/database_service.dart';
import 'package:my_project/services/qr_service.dart';
import 'package:my_project/providers/attendance_provider.dart';

void main() {
  group('EduTrack Attendance System Unit Tests', () {
    test('Student model serialization and fullName formatting', () {
      final student = Student(
        id: '2026-99999',
        firstName: 'Pedro',
        lastName: 'Penduko',
        email: 'pedro@jmc.edu.ph',
        photoPath: '/mock/path.png',
        course: 'BSIT',
        yearLevel: '3rd Year',
        section: 'BSIT-3B',
        registeredAt: DateTime(2026, 10, 27, 9, 30),
      );

      expect(student.fullName, 'Pedro Penduko');
      final map = student.toMap();
      expect(map['id'], '2026-99999');
      expect(map['email'], 'pedro@jmc.edu.ph');

      final fromMap = Student.fromMap(map);
      expect(fromMap.id, '2026-99999');
      expect(fromMap.fullName, 'Pedro Penduko');
      expect(fromMap.course, 'BSIT');
    });

    test('AttendanceRecord model serialization', () {
      final now = DateTime.now();
      final record = AttendanceRecord(
        id: 1,
        studentId: '2026-10492',
        studentName: 'Juan Dela Cruz',
        timestamp: now,
      );

      final map = record.toMap();
      expect(map['studentId'], '2026-10492');
      expect(map['studentName'], 'Juan Dela Cruz');

      final reconstructed = AttendanceRecord.fromMap(map);
      expect(reconstructed.studentId, '2026-10492');
      expect(reconstructed.studentName, 'Juan Dela Cruz');
    });

    test('QrService generates standardized JSON and parses payloads correctly', () {
      final student = Student(
        id: '2026-10492',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        email: 'juan@jmc.edu.ph',
        photoPath: '',
        course: 'BSIT',
        yearLevel: '3rd Year',
        section: 'BSIT-3A',
        registeredAt: DateTime.now(),
      );

      final payload = QrService.generateQrPayload(student);
      expect(payload, contains('"studentId":"2026-10492"'));
      expect(payload, contains('"fullName":"Juan Dela Cruz"'));

      final parsed = QrService.parseQrPayload(payload);
      expect(parsed, isNotNull);
      expect(parsed!.studentId, '2026-10492');
      expect(parsed.fullName, 'Juan Dela Cruz');

      // Also parses plain student ID barcode
      final plainParsed = QrService.parseQrPayload('2026-10492');
      expect(plainParsed, isNotNull);
      expect(plainParsed!.studentId, '2026-10492');
    });

    test('DatabaseService & AttendanceProvider 3-tier QR scan verification logic', () async {
      final provider = AttendanceProvider();
      await provider.loadData();

      // Ensure test student exists
      if (provider.findStudentById('2026-10492') == null) {
        await provider.registerStudent(Student(
          id: '2026-10492',
          firstName: 'Juan',
          lastName: 'Dela Cruz',
          email: 'juan.delacruz@jmc.edu.ph',
          photoPath: '',
          course: 'BSIT',
          yearLevel: '3rd Year',
          section: 'BSIT-3A',
          registeredAt: DateTime.now(),
        ));
      }

      final initialEnrolled = provider.totalEnrolled;
      expect(initialEnrolled, greaterThanOrEqualTo(1));

      // Test Case 1: Unregistered Student ID
      final unregResult = await provider.markAttendance('UNKNOWN-99999');
      expect(unregResult.status, AttendanceScanStatus.unregistered);
      expect(unregResult.message, contains('Unregistered Student ID'));

      // Test Case 2: Valid New Scan for registered student
      final validResult = await provider.markAttendance('2026-10492');
      expect(validResult.status, AttendanceScanStatus.success);
      expect(validResult.message, contains('Marked Present'));
      expect(provider.presentToday, greaterThanOrEqualTo(1));
      expect(provider.isStudentPresentToday('2026-10492'), isTrue);

      // Test Case 3: Already Scanned Today Check
      final alreadyResult = await provider.markAttendance('2026-10492');
      expect(alreadyResult.status, AttendanceScanStatus.alreadyCheckedIn);
      expect(alreadyResult.message, contains('Already Checked In'));

      // Test Case 4: Student Registration and Counter Update
      final newStudent = Student(
        id: '2026-99999',
        firstName: 'Jose',
        lastName: 'Rizal',
        email: 'jose.rizal@jmc.edu.ph',
        photoPath: '',
        course: 'BSIT',
        yearLevel: '4th Year',
        section: 'BSIT-4A',
        registeredAt: DateTime.now(),
      );
      await provider.registerStudent(newStudent);
      expect(provider.totalEnrolled, initialEnrolled + 1);

      // Test Case 5: Student Deletion & Counter Recalculation
      await provider.deleteStudent('2026-99999');
      expect(provider.totalEnrolled, initialEnrolled);
      expect(provider.findStudentById('2026-99999'), isNull);
    });
  });
}
