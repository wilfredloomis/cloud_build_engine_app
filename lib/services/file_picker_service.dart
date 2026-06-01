import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<PickedFile?> pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes == null) return null;

    return PickedFile(
      name: file.name,
      bytes: file.bytes!,
      size: file.size,
    );
  }
}

class PickedFile {
  final String name;
  final Uint8List bytes;
  final int size;

  PickedFile({
    required this.name,
    required this.bytes,
    required this.size,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
