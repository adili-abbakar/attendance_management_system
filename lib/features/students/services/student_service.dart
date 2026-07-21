import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/results/student_result.dart';

class StudentService {
  StudentService._();

  static final StudentService instance = StudentService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Student>> getStudents() async {
    final db = await _databaseService.database;

    final result = await db.query(
      StudentTable.tableName,
      orderBy: '${StudentTable.fullName} ASC',
    );

    return result.map((e) => Student.fromMap(e)).toList();
  }

  Future<Student?> getStudent(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      StudentTable.tableName,
      where: '${StudentTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Student.fromMap(result.first);
  }

  Future<StudentResult> createStudent(Student student) async {
    final db = await _databaseService.database;

    final existing = await db.query(
      StudentTable.tableName,
      where: '${StudentTable.admissionNumber} = ?',
      whereArgs: [student.admissionNumber],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const StudentResult(
        success: false,
        admissionNumberError: 'Admission number already exists.',
      );
    }

    await db.insert(StudentTable.tableName, student.toMap());

    return const StudentResult(success: true);
  }

  Future<StudentResult> updateStudent(Student student) async {
    final db = await _databaseService.database;

    final existing = await db.query(
      StudentTable.tableName,
      where:
          '${StudentTable.admissionNumber} = ? AND '
          '${StudentTable.id} != ?',
      whereArgs: [student.admissionNumber, student.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return const StudentResult(
        success: false,
        admissionNumberError: 'Admission number already exists.',
      );
    }

    await db.update(
      StudentTable.tableName,
      student.toMap(),
      where: '${StudentTable.id} = ?',
      whereArgs: [student.id],
    );

    return const StudentResult(success: true);
  }

  Future<bool> deleteStudent(int id) async {
    final db = await _databaseService.database;

    final rows = await db.delete(
      StudentTable.tableName,
      where: '${StudentTable.id} = ?',
      whereArgs: [id],
    );

    return rows > 0;
  }
}
