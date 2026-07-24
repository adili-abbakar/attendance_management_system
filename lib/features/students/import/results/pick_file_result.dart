import 'package:file_picker/file_picker.dart';

class PickFileResult {
  const PickFileResult({this.file, this.error});

  final PlatformFile? file;
  final String? error;

  bool get success => file != null;
}
