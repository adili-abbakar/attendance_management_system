class Student {
  final int? id;

  final String admissionNumber;
  final String fullName;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    this.id,
    required this.admissionNumber,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
  });

  Student copyWith({
    int? id,
    String? admissionNumber,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      admissionNumber: map['admission_number'] as String,
      fullName: map['full_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admission_number': admissionNumber,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Student.empty() {
    final now = DateTime.now();

    return Student(
      admissionNumber: '',
      fullName: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
