import 'dart:convert';

import 'package:crypto/crypto.dart';

class SyncManifestEntry {
  const SyncManifestEntry({
    required this.tableName,
    required this.recordUuid,
    required this.updatedAt,
    required this.contentHash,
    required this.record,
  });

  final String tableName;
  final String recordUuid;
  final DateTime updatedAt;
  final String contentHash;
  final Map<String, dynamic> record;

  static String hashRecord(Map<String, dynamic> record) {
    final normalized = _normalize(record);
    final json = const JsonEncoder.withIndent('  ').convert(normalized);
    final bytes = utf8.encode(json);
    return sha256.convert(bytes).toString();
  }

  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final map = <String, dynamic>{};
      final keys = value.keys.cast<String>().toList()..sort();
      for (final key in keys) {
        map[key] = _normalize(value[key]);
      }
      return map;
    }

    if (value is List) {
      return value.map(_normalize).toList();
    }

    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }

    return value;
  }
}

class SyncSummary {
  const SyncSummary({
    this.totalRecordsCompared = 0,
    this.recordsSent = 0,
    this.recordsReceived = 0,
    this.recordsUpdated = 0,
    this.recordsRestored = 0,
    this.conflictsDetected = 0,
    this.conflictsResolved = 0,
    this.failedTransfers = 0,
    this.status = 'ready',
  });

  final int totalRecordsCompared;
  final int recordsSent;
  final int recordsReceived;
  final int recordsUpdated;
  final int recordsRestored;
  final int conflictsDetected;
  final int conflictsResolved;
  final int failedTransfers;
  final String status;

  SyncSummary copyWith({
    int? totalRecordsCompared,
    int? recordsSent,
    int? recordsReceived,
    int? recordsUpdated,
    int? recordsRestored,
    int? conflictsDetected,
    int? conflictsResolved,
    int? failedTransfers,
    String? status,
  }) {
    return SyncSummary(
      totalRecordsCompared: totalRecordsCompared ?? this.totalRecordsCompared,
      recordsSent: recordsSent ?? this.recordsSent,
      recordsReceived: recordsReceived ?? this.recordsReceived,
      recordsUpdated: recordsUpdated ?? this.recordsUpdated,
      recordsRestored: recordsRestored ?? this.recordsRestored,
      conflictsDetected: conflictsDetected ?? this.conflictsDetected,
      conflictsResolved: conflictsResolved ?? this.conflictsResolved,
      failedTransfers: failedTransfers ?? this.failedTransfers,
      status: status ?? this.status,
    );
  }
}

class PairingSession {
  PairingSession({
    required this.code,
    required this.sessionId,
    required this.deviceId,
    required this.groupId,
    required this.expiresAt,
    this.isUsed = false,
  });

  final String code;
  final String sessionId;
  final String deviceId;
  final String groupId;
  final DateTime expiresAt;
  bool isUsed;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  PairingPayload toPayload() => PairingPayload(
    deviceId: deviceId,
    groupId: groupId,
    sessionId: sessionId,
    code: code,
    expiresAt: expiresAt,
  );
}

class PairingPayload {
  const PairingPayload({
    required this.deviceId,
    required this.groupId,
    required this.sessionId,
    required this.code,
    required this.expiresAt,
  });

  final String deviceId;
  final String groupId;
  final String sessionId;
  final String code;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'groupId': groupId,
    'sessionId': sessionId,
    'code': code,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  factory PairingPayload.fromJson(Map<String, dynamic> map) {
    return PairingPayload(
      deviceId: map['deviceId'] as String,
      groupId: map['groupId'] as String,
      sessionId: map['sessionId'] as String,
      code: map['code'] as String,
      expiresAt: DateTime.parse(map['expiresAt'] as String).toUtc(),
    );
  }
}
