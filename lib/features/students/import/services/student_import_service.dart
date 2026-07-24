import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:attendance_management_system/features/students/import/results/pick_file_result.dart';
import 'package:attendance_management_system/features/students/import/results/student_validation_result.dart';
import 'package:attendance_management_system/features/students/import/utils/header_mapper.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:attendance_management_system/features/students/tables/student_table.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:attendance_management_system/features/students/import/results/student_import_result.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:csv/csv.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/foundation.dart';

class StudentImportService {
  StudentImportService._();

  static final instance = StudentImportService._();

  static const _allowedExtensions = ['xlsx', 'csv'];

  String _cellValue(dynamic cell) {
    if (cell == null) return '';

    final text = cell.toString().trim();

    if (text.toLowerCase() == 'null') return '';

    return text;
  }

  Future<PickFileResult> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return const PickFileResult();
    }

    final file = result.files.first;

    final extension = file.extension?.toLowerCase();

    if (!_allowedExtensions.contains(extension)) {
      return const PickFileResult(
        error: 'Only Excel (.xlsx) and CSV (.csv) files are supported.',
      );
    }

    return PickFileResult(file: file);
  }

  Future<StudentImportResult> _readCsv(PlatformFile file) async {
    if (file.path == null) {
      return const StudentImportResult(
        success: false,
        error: 'Unable to access the selected file.',
      );
    }

    try {
      final csv = await File(file.path!).readAsString();

      List<List<dynamic>> rows = [];
      const delimiters = [',', ';', '\t', '|'];
      for (final delimiter in delimiters) {
        try {
          rows = CsvToListConverter(
            fieldDelimiter: delimiter,
            eol: '\n',
          ).convert(csv);

          if (rows.isNotEmpty && rows.first.length > 1) {
            break;
          }
        } catch (_) {}
      }

      return _convertRows(rows);
    } catch (_) {
      return const StudentImportResult(
        success: false,
        error: 'Failed to read the selected CSV file.',
      );
    }
  }

  Future<StudentImportResult> _readExcel(PlatformFile file) async {
    if (file.path == null) {
      return const StudentImportResult(
        success: false,
        error: 'Unable to access the selected file.',
      );
    }

    try {
      final bytes = await File(file.path!).readAsBytes();

      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        return const StudentImportResult(
          success: false,
          error: 'The selected Excel file contains no worksheets.',
        );
      }

      final sheet = excel.tables.values.first;

      final rows = sheet.rows
          .map((row) => row.map((cell) => cell?.value).toList())
          .toList();

      return _convertRows(rows);
    } catch (_) {
      return const StudentImportResult(
        success: false,
        error: 'Failed to read the selected Excel file.',
      );
    }
  }

  StudentImportResult _convertRows(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      return const StudentImportResult(
        success: false,
        error: 'The selected file is empty.',
      );
    }

    final headers = rows.first;
    final admissionIndex = HeaderMapper.findAdmissionNumberColumn(headers);

    final fullNameIndex = HeaderMapper.findFullNameColumn(headers);

    if (admissionIndex == null) {
      return const StudentImportResult(
        success: false,
        error: 'Admission Number column was not found.',
      );
    }

    if (fullNameIndex == null) {
      return const StudentImportResult(
        success: false,
        error: 'Student Name column was not found.',
      );
    }

    if (rows.length == 1) {
      return const StudentImportResult(
        success: false,
        error:
            'The selected file contains only the header row. No student records were found.',
      );
    }

    final students = <Student>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.isEmpty) continue;

      final admissionNumber = row.length > admissionIndex
          ? _cellValue(row[admissionIndex])
          : '';

      final fullName = row.length > fullNameIndex
          ? _cellValue(row[fullNameIndex])
          : '';

      if (admissionNumber.isEmpty && fullName.isEmpty) {
        continue;
      }

      students.add(
        Student(
          admissionNumber: admissionNumber,
          fullName: fullName,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return StudentImportResult(
      success: true,
      validStudents: students,
      totalRows: students.length,
    );
  }

  Future<StudentImportResult> readStudents(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();

    switch (extension) {
      case 'csv':
        return _readCsv(file);

      case 'xlsx':
        return _readExcel(file);

      default:
        return const StudentImportResult(
          success: false,
          error: 'Unsupported file type.',
        );
    }
  }

  StudentValidationResult validateStudents(List<Student> students) {
    final validStudents = <Student>[];
    final errors = <String>[];
    final warnings = <String>[];
    final admissionNumbers = <String>{};

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final row = i + 2;

      if (student.admissionNumber.trim().isEmpty) {
        errors.add('Row $row');
        warnings.add(
          '⚠ Row $row\n'
          'Admission Number is required.\n'
          'This row will be skipped during import.',
        );
        continue;
      }

      if (admissionNumbers.contains(student.admissionNumber)) {
        errors.add('Row $row');

        warnings.add(
          '⚠ Row $row\n'
          'Duplicate admission number "${student.admissionNumber}".\n'
          'This row will be skipped during import.',
        );
        continue;
      }

      admissionNumbers.add(student.admissionNumber);

      if (student.fullName.trim().isEmpty) {
        warnings.add(
          '⚠ Row $row\n'
          'Student name is empty.\n'
          'The student will be imported without a name.',
        );
      }

      validStudents.add(student);
    }

    return StudentValidationResult(
      validStudents: validStudents,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<StudentValidationResult> validateAgainstDatabase(
    List<Student> students,
  ) async {
    final existingAdmissionNumbers = await StudentService.instance
        .existingAdmissionNumbers(
          students.map((e) => e.admissionNumber).toList(),
        );

    final validStudents = <Student>[];
    final warnings = <String>[];
    final errors = <String>[];

    for (final student in students) {
      if (existingAdmissionNumbers.contains(student.admissionNumber)) {
        errors.add(student.admissionNumber);

        warnings.add(
          '⚠ Admission number "${student.admissionNumber}" already exists.\n'
          'This row will be skipped during import.',
        );

        continue;
      }

      validStudents.add(student);
    }

    return StudentValidationResult(
      validStudents: validStudents,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<StudentImportResult> validateImport(List<Student> students) async {
    final fileValidation = validateStudents(students);

    final dbValidation = await validateAgainstDatabase(
      fileValidation.validStudents,
    );

    return StudentImportResult(
      success: true,
      totalRows: students.length,
      validStudents: dbValidation.validStudents,
      warnings: [...fileValidation.warnings, ...dbValidation.warnings],
      errors: [...fileValidation.errors, ...dbValidation.errors],
    );
  }

  Future<int> importStudents(List<Student> students) async {
    if (students.isEmpty) return 0;

    final db = await DatabaseService.instance.database;

    final batch = db.batch();

    for (final student in students) {
      batch.insert(StudentTable.tableName, student.toMap());
    }

    await batch.commit(noResult: true);

    return students.length;
  }
}
