import 'dart:collection';

import 'package:attendance_management_system/features/sync/models/sync_models.dart';

class SyncEngineService {
  SyncEngineService._();

  static final SyncEngineService instance = SyncEngineService._();

  SyncSummary reconcileManifests({
    required List<SyncManifestEntry> localManifest,
    required List<SyncManifestEntry> remoteManifest,
  }) {
    final localMap = <String, SyncManifestEntry>{
      for (final entry in localManifest)
        '${entry.tableName}:${entry.recordUuid}': entry,
    };

    final remoteMap = <String, SyncManifestEntry>{
      for (final entry in remoteManifest)
        '${entry.tableName}:${entry.recordUuid}': entry,
    };

    final allKeys = LinkedHashSet<String>.from(localMap.keys)..addAll(remoteMap.keys);

    var recordsSent = 0;
    var recordsReceived = 0;
    var recordsUpdated = 0;
    var recordsRestored = 0;
    var conflictsDetected = 0;
    var conflictsResolved = 0;
    var failedTransfers = 0;

    for (final key in allKeys) {
      final local = localMap[key];
      final remote = remoteMap[key];

      if (local == null && remote != null) {
        recordsReceived++;
        continue;
      }

      if (remote == null && local != null) {
        recordsSent++;
        continue;
      }

      if (local == null || remote == null) {
        failedTransfers++;
        continue;
      }

      if (local.contentHash == remote.contentHash) {
        continue;
      }

      conflictsDetected++;
      if (local.updatedAt.isAfter(remote.updatedAt)) {
        recordsUpdated++;
        conflictsResolved++;
      } else if (remote.updatedAt.isAfter(local.updatedAt)) {
        recordsUpdated++;
        conflictsResolved++;
      } else {
        final winner = key.compareTo('${local.tableName}:${local.recordUuid}') <= 0
            ? local
            : remote;
        if (winner == remote) {
          recordsUpdated++;
        } else {
          recordsRestored++;
        }
        conflictsResolved++;
      }
    }

    final totalRecordsCompared = allKeys.length;
    return SyncSummary(
      totalRecordsCompared: totalRecordsCompared,
      recordsSent: recordsSent,
      recordsReceived: recordsReceived,
      recordsUpdated: recordsUpdated,
      recordsRestored: recordsRestored,
      conflictsDetected: conflictsDetected,
      conflictsResolved: conflictsResolved,
      failedTransfers: failedTransfers,
      status: failedTransfers == 0 ? 'synchronized' : 'warning',
    );
  }
}
