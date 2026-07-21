import 'dart:convert';

class User {
  final int? id;
  final String name;
  final String email;
  final String staffId;
  final String password;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.staffId,
    required this.password,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? staffId,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      staffId: staffId ?? this.staffId,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'staff_id': staffId,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      staffId: map['staff_id'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source));

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, staffId: $staffId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
            other.id == id &&
            other.name == name &&
            other.email == email &&
            other.staffId == staffId &&
            other.password == password;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, staffId, password);
  }
}
