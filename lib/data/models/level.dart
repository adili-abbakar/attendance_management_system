class Level {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Level({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Level copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Level(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Level.empty() {
    final now = DateTime.now();

    return Level(
      name: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
