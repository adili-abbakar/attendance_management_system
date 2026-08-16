import 'package:flutter/foundation.dart';

import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService;

  AttendanceProvider({AttendanceService? attendanceService})
    : _attendanceService = attendanceService ?? AttendanceService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  int? _lectureSessionId;
  List<AttendanceRecord> _records = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int? get lectureSessionId => _lectureSessionId;

  List<AttendanceRecord> get records => List.unmodifiable(_records);

  int get attendanceCount => _records.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void selectLectureSession(int lectureSessionId) {
    _lectureSessionId = lectureSessionId;
    _records = [];
    _clearError();

    notifyListeners();
  }

  void clearSelection() {
    _lectureSessionId = null;
    _records = [];
    _clearError();

    notifyListeners();
  }

  Future<bool> loadRecords(int lectureSessionId) async {
    _setLoading(true);
    _clearError();

    try {
      _lectureSessionId = lectureSessionId;

      _records = await _attendanceService.getRecordsByLectureSession(
        lectureSessionId,
      );

      return true;
    } catch (e) {
      _setError('Failed to load attendance records.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<AttendanceRecord?> recordAttendance({
    required int lectureSessionId,
    required int studentId,
  }) async {
    _clearError();

    try {
      final record = AttendanceRecord(
        lectureSessionId: lectureSessionId,
        studentId: studentId,
        status: AttendanceRecordStatus.present,
        scannedAt: DateTime.now(),
      );

      final recordId = await _attendanceService.addAttendanceRecord(record);

      final savedRecord = record.copyWith(id: recordId);

      _records = [..._records, savedRecord];

      _lectureSessionId = lectureSessionId;

      notifyListeners();

      return savedRecord;
    } catch (e) {
      _setError(e is StateError ? e.message : 'Failed to record attendance.');

      return null;
    }
  }

  Future<bool> hasStudentAttended({
    required int lectureSessionId,
    required int studentId,
  }) async {
    try {
      return await _attendanceService.hasStudentAttended(
        lectureSessionId: lectureSessionId,
        studentId: studentId,
      );
    } catch (e) {
      _setError('Failed to check attendance.');
      return false;
    }
  }

  Future<int> getAttendanceCount(int lectureSessionId) async {
    try {
      return await _attendanceService.getAttendanceCount(lectureSessionId);
    } catch (e) {
      _setError('Failed to get attendance count.');
      return 0;
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
