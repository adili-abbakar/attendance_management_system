import 'dart:math';

import 'package:attendance_management_system/features/sync/models/sync_models.dart';
import 'package:uuid/uuid.dart';

class PairingService {
  PairingService._();

  static final PairingService instance = PairingService._();

  final Map<String, PairingSession> _sessions = <String, PairingSession>{};

  PairingSession createSession({
    required String deviceId,
    required String groupId,
  }) {
    final code = _generateCode();
    final sessionId = const Uuid().v4();
    final session = PairingSession(
      code: code,
      sessionId: sessionId,
      deviceId: deviceId,
      groupId: groupId,
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
    );

    _sessions[code] = session;
    return session;
  }

  PairingSession? validateCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    final session = _sessions[code];

    if (session == null) {
      return null;
    }

    if (session.isExpired || session.isUsed) {
      _sessions.remove(code);
      return null;
    }

    return session;
  }

  void consumeCode(String code) {
    final session = _sessions[code.trim().toUpperCase()];
    if (session != null) {
      session.isUsed = true;
      _sessions.remove(code.trim().toUpperCase());
    }
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
