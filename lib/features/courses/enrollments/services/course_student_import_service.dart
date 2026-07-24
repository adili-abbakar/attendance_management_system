import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/courses/enrollments/results/course_student_import_summary.dart';
import 'package:attendance_management_system/features/students/import/results/pick_file_result.dart';
import 'package:attendance_management_system/features/students/import/results/student_import_result.dart';
import 'package:attendance_management_system/features/students/import/results/student_validation_result.dart';
import 'package:attendance_management_system/features/students/import/services/student_import_service.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:attendance_management_system/features/courses/enrollments/models/course_student.dart';
import 'package:attendance_management_system/features/courses/enrollments/services/course_enrollment_service.dart';

class CourseStudentImportService {
  CourseStudentImportService._();

  static final instance = CourseStudentImportService._();

  Future<PickFileResult> pickFile() {
    return StudentImportService.instance.pickFile();
  }

  Future<StudentImportResult> readStudents(PlatformFile file) {
    return StudentImportService.instance.readStudents(file);
  }

  StudentValidationResult validateStudents(List<Student> students) {
    return StudentImportService.instance.validateStudents(students);
  }

  // ----------------------------------------------------------
  // Everything below is COURSE-SPECIFIC and will be implemented
  // ----------------------------------------------------------

  Future<StudentImportResult> validateImport(
    List<Student> students,
    int courseId,
  ) async {
    // Validate the spreadsheet itself
    final fileValidation = validateStudents(students);

    final existingStudents = await StudentService.instance
        .getStudentsByAdmissionNumbers(
          fileValidation.validStudents.map((e) => e.admissionNumber).toList(),
        );

    final validStudents = <Student>[];
    final warnings = [...fileValidation.warnings];
    final errors = [...fileValidation.errors];

    for (final student in fileValidation.validStudents) {
      if (existingStudents.containsKey(student.admissionNumber)) {
        warnings.add(
          'Student "${student.admissionNumber}" already exists and will be enrolled into the course if not already enrolled.',
        );
      }

      validStudents.add(student);
    }

    return StudentImportResult(
      success: true,
      totalRows: students.length,
      validStudents: validStudents,
      warnings: warnings,
      errors: errors,
    );
  }

  Future<CourseStudentImportSummary> importStudents(
    List<Student> students,
    int courseId,
  ) async {
    if (students.isEmpty) {
      return const CourseStudentImportSummary(
        createdStudents: 0,
        linkedExistingStudents: 0,
        alreadyEnrolled: 0,
        invalidRows: 0,
      );
    }

    final db = await DatabaseService.instance.database;

    return db.transaction((txn) async {
      final existingStudents = await StudentService.instance
          .getStudentsByAdmissionNumbers(
            students.map((e) => e.admissionNumber).toList(),
            executor: txn,
          );

      int createdStudents = 0;
      int linkedExistingStudents = 0;
      int alreadyEnrolled = 0;

      final enrollments = <CourseStudent>[];

      for (final student in students) {
        Student currentStudent;

        final existingStudent = existingStudents[student.admissionNumber];

        if (existingStudent != null) {
          currentStudent = existingStudent;
          linkedExistingStudents++;
        } else {
          final result = await StudentService.instance.createStudent(
            student,
            executor: txn,
          );

          if (!result.success || result.student == null) {
            continue;
          }

          currentStudent = result.student!;
          createdStudents++;
        }

        enrollments.add(
          CourseStudent(
            courseId: courseId,
            studentId: currentStudent.id!,
            createdAt: DateTime.now(),
          ),
        );
      }

      final enrolledIds = await CourseEnrollmentService.instance
          .alreadyEnrolledStudentIds(
            courseId,
            enrollments.map((e) => e.studentId).toList(),
            executor: txn,
          );

      enrollments.removeWhere((enrollment) {
        if (enrolledIds.contains(enrollment.studentId)) {
          alreadyEnrolled++;

          if (linkedExistingStudents > 0) {
            linkedExistingStudents--;
          }

          return true;
        }

        return false;
      });

      await CourseEnrollmentService.instance.enrollStudents(
        enrollments,
        executor: txn,
      );

      return CourseStudentImportSummary(
        createdStudents: createdStudents,
        linkedExistingStudents: linkedExistingStudents,
        alreadyEnrolled: alreadyEnrolled,
        invalidRows: 0,
      );
    });
  }
}
