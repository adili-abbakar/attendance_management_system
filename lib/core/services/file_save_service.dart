import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class FileSaveService {
  const FileSaveService();

  Future<String?> saveFile({
    required Uint8List bytes,
    required String suggestedName,
    required List<XTypeGroup> acceptedTypeGroups,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: acceptedTypeGroups,
    );

    if (location == null) {
      return null;
    }

    final file = XFile.fromData(bytes, name: suggestedName, mimeType: null);

    await file.saveTo(location.path);

    return location.path;
  }
}
