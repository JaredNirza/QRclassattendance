class Student {
  final String id; // e.g., "2026-10492"
  final String firstName;
  final String lastName;
  final String email;
  final String photoPath;
  final String course;
  final String yearLevel;
  final String section;
  final DateTime registeredAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.photoPath,
    required this.course,
    required this.yearLevel,
    required this.section,
    required this.registeredAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'photoPath': photoPath,
    'course': course,
    'yearLevel': yearLevel,
    'section': section,
    'registeredAt': registeredAt.toIso8601String(),
  };

  factory Student.fromMap(Map<dynamic, dynamic> map) => Student(
    id: map['id']?.toString() ?? '',
    firstName: map['firstName']?.toString() ?? '',
    lastName: map['lastName']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    photoPath: map['photoPath']?.toString() ?? '',
    course: map['course']?.toString() ?? '',
    yearLevel: map['yearLevel']?.toString() ?? '',
    section: map['section']?.toString() ?? '',
    registeredAt: map['registeredAt'] != null
        ? DateTime.tryParse(map['registeredAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
  );
}
