import 'package:file_selector/file_selector.dart';

class FileTypes {
  FileTypes._();

  static const png = XTypeGroup(label: 'PNG Image', extensions: ['png']);

  static const pdf = XTypeGroup(label: 'PDF Document', extensions: ['pdf']);

  static const zip = XTypeGroup(label: 'ZIP Archive', extensions: ['zip']);
}
