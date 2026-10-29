class AttendanceRecord {
  final int? id;
  final String studentId;
  final String studentName;
  final DateTime timestamp;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AttendanceRecord.fromMap(Map<dynamic, dynamic> map) => AttendanceRecord(
    id: map['id'] is int
        ? map['id'] as int
        : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    studentId: map['studentId']?.toString() ?? '',
    studentName: map['studentName']?.toString() ?? '',
    timestamp: map['timestamp'] != null
        ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}
