import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _service;

  StudentProvider(this._service);

  List<Student> _students = [];

  bool _isLoading = false;

  String? _error;
  String? _admissionNumberError;

  List<Student> get students => _students;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get admissionNumberError => _admissionNumberError;

  Future<void> loadStudents() async {
    _setLoading(true);

    try {
      _students = await _service.getStudents();

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> createStudent(Student student) async {
    _error = null;
    _admissionNumberError = null;

    notifyListeners();

    try {
      final result = await _service.createStudent(
        _normalizeStudent(student.copyWith(createdAt: DateTime.now())),
      );

      if (!result.success) {
        _admissionNumberError = result.admissionNumberError;

        notifyListeners();

        return false;
      }

      await loadStudents();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    _error = null;
    _admissionNumberError = null;

    notifyListeners();

    try {
      final result = await _service.updateStudent(_normalizeStudent(student));

      if (!result.success) {
        _admissionNumberError = result.admissionNumberError;

        notifyListeners();

        return false;
      }

      await loadStudents();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final success = await _service.deleteStudent(id);

      if (!success) {
        return false;
      }

      _students.removeWhere((student) => student.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Student? getStudentById(int id) {
    try {
      return _students.firstWhere((student) => student.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  void clearAdmissionNumberError() {
    _admissionNumberError = null;

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  Student _normalizeStudent(Student student) {
    return student.copyWith(
      admissionNumber: student.admissionNumber.trim().toUpperCase(),
      fullName: student.fullName.trim(),
      updatedAt: DateTime.now(),
    );
  }
}
