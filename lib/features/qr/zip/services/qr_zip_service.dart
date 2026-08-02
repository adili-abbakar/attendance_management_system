import 'dart:typed_data';

import 'package:archive/archive.dart';

class QrZipService {
  const QrZipService();

  Future<Uint8List> generate({required Map<String, Uint8List> files}) async {
    final archive = Archive();

    for (final entry in files.entries) {
      archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
    }

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }
}
