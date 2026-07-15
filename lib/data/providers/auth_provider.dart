import 'package:flutter/material.dart';

import '../models/auth/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    // TODO
  }

  Future<void> register(User user) async {
    // TODO
  }

  Future<void> logout() async {
    // TODO
  }
}
