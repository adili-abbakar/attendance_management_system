import 'package:flutter/material.dart';
import '../models/auth/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _emailError;
  String? _staffIdError;

  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get staffIdError => _staffIdError;

  Future<bool> register(User user) async {
    _isLoading = true;
    _emailError = null;
    _staffIdError = null;

    notifyListeners();

    try {
      final result = await AuthService.instance.register(user);

      _isLoading = false;
      _emailError = result.emailError;
      _staffIdError = result.staffIdError;

      notifyListeners();

      return result.success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  void clearEmailError() {
    _emailError = null;
    notifyListeners();
  }

  void clearStaffIdError() {
    _staffIdError = null;
    notifyListeners();
  }
}
