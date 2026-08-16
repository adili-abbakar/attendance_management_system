import 'package:flutter/foundation.dart';

import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService;

  AttendanceProvider({AttendanceService? attendanceService})
    : _attendanceService = attendanceService ?? AttendanceService.instance;

  bool _isLoading = false;
  bool _isScanning = false;

  String? _errorMessage;

  int? _lectureSessionId;

  List<AttendanceRecord> _records = [];

  bool get isLoading => _isLoading;

  bool get isScanning => _isScanning;

  String? get errorMessage => _errorMessage;

  int? get lectureSessionId => _lectureSessionId;

  List<AttendanceRecord> get records => List.unmodifiable(_records);

  int get attendanceCount => _records.length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setScanning(bool value) {
    _isScanning = value;
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

  Future<AttendanceResult> recordAttendance({
    required int lectureSessionId,
    required int studentId,
  }) async {
    _clearError();
    _setScanning(true);

    try {
      final result = await _attendanceService.recordAttendance(
        lectureSessionId: lectureSessionId,
        studentId: studentId,
      );

      if (result.isSuccess && result.record != null) {
        _records = [..._records, result.record!];
        notifyListeners();
      }

      return result;
    } catch (e) {
      final result = AttendanceResult.failure(
        status: AttendanceResultStatus.error,
        message: 'Failed to record attendance.',
      );

      _setError(result.message!);

      return result;
    } finally {
      _setScanning(false);
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
