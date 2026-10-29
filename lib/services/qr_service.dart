import 'dart:convert';
import '../models/student.dart';

class QrPayloadData {
  final String studentId;
  final String? fullName;
  final String? course;

  QrPayloadData({
    required this.studentId,
    this.fullName,
    this.course,
  });
}

class QrService {
  /// Generates a standardized JSON string payload for the digital badge QR code
  static String generateQrPayload(Student student) {
    return jsonEncode({
      'studentId': student.id,
      'fullName': student.fullName,
      'course': student.course,
      'section': student.section,
    });
  }

  /// Parses the scanned QR code payload, supporting both JSON and direct raw student ID
  static QrPayloadData? parseQrPayload(String rawContent) {
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) return null;

    try {
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final Map<String, dynamic> data = jsonDecode(trimmed);
        final id = data['studentId']?.toString() ?? '';
        if (id.isNotEmpty) {
          return QrPayloadData(
            studentId: id,
            fullName: data['fullName']?.toString(),
            course: data['course']?.toString(),
          );
        }
      }
    } catch (_) {
      // If JSON parsing fails, fall back to treating it as raw student ID
    }

    // Direct student ID
    return QrPayloadData(studentId: trimmed);
  }
}
