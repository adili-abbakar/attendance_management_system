import 'package:flutter/material.dart';

import '../models/academic_session.dart';
import '../services/academic_session_service.dart';

class AcademicSessionProvider extends ChangeNotifier {
  final AcademicSessionSerivce _service;

  AcademicSessionProvider(this._service);

  List<AcademicSession> _academicSessions = [];

  bool _isLoading = false;

  String? _error;

  List<AcademicSession> get academicSessions => _academicSessions;

  bool get isLoading => _isLoading;

  String? get error => _error;
  String? _academicSessionNameError;
  String? get academicSessionNameError => _academicSessionNameError;

  Future<void> loadAcademicSessions() async {
    _setLoading(true);

    try {
      _academicSessions = await _service.getAcademicSessions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> createAcademicSession(AcademicSession academicSession) async {
    _error = null;
    _academicSessionNameError = null;

    notifyListeners();

    try {
      final result = await _service.createAcademicSession(
        _normalizeAcademicSession(
          academicSession.copyWith(createdAt: DateTime.now())),
      );

      if (!result.success) {
        _academicSessionNameError = result.academicSessionNameError;

        notifyListeners();

        return false;
      }

      await loadAcademicSessions();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateAcademicSession(AcademicSession academicSession) async {
    _error = null;
    _academicSessionNameError = null;

    notifyListeners();

    try {
     final result = await _service.updateAcademicSession(_normalizeAcademicSession(academicSession));

      if (!result.success) {
        _academicSessionNameError = result.academicSessionNameError;

        notifyListeners();

        return false;
      }

      await loadAcademicSessions();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteAcademicSession(int id) async {
    try {
      await _service.deleteAcademicSession(id);

      _academicSessions.removeWhere((academicSession) => academicSession.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();

      return false;
    }
  }

  AcademicSession? getAcademicSessionById(int id) {
    try {
      return _academicSessions.firstWhere((academicSession) => academicSession.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearAcademicSessionNameError() {
    _academicSessionNameError = null;
    notifyListeners();
  }

  AcademicSession _normalizeAcademicSession(AcademicSession academicSession) {
    return academicSession.copyWith(
      name: academicSession.name.trim().toUpperCase(),
      updatedAt: DateTime.now(),
    );
  }
}
