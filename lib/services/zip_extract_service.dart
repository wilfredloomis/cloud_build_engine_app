import 'dart:typed_data';
import 'package:archive/archive.dart';

class ZipExtractService {
  ZipInfo? inspectZip(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      String? projectType;
      String? packageName;

      for (final file in archive) {
        final name = file.name;

        if (name.endsWith('pubspec.yaml')) {
          projectType = 'flutter';
          final content = String.fromCharCodes(file.content as List<int>);
          packageName = _extractFromYaml(content, 'name');
          break;
        }

        if (name.endsWith('package.json') && !name.contains('node_modules')) {
          final content = String.fromCharCodes(file.content as List<int>);
          if (content.contains('"expo"')) {
            projectType = 'expo';
          } else if (content.contains('"react-native"')) {
            projectType = 'react_native';
          }
          packageName = _extractJsonField(content, 'name');
          break;
        }

        if (name.endsWith('settings.gradle') ||
            name.endsWith('build.gradle') ||
            name.endsWith('settings.gradle.kts') ||
            name.endsWith('build.gradle.kts')) {
          projectType = 'native_android';
        }
      }

      return ZipInfo(
        fileCount: archive.length,
        projectType: projectType,
        detectedPackageName: packageName,
      );
    } catch (_) {
      return null;
    }
  }

  String? _extractFromYaml(String content, String key) {
    final regex = RegExp('^$key:\\s*(.+)', multiLine: true);
    final match = regex.firstMatch(content);
    return match?.group(1)?.trim();
  }

  String? _extractJsonField(String content, String key) {
    final regex = RegExp('"$key"\\s*:\\s*"([^"]+)"');
    final match = regex.firstMatch(content);
    return match?.group(1);
  }
}

class ZipInfo {
  final int fileCount;
  final String? projectType;
  final String? detectedPackageName;

  ZipInfo({
    required this.fileCount,
    this.projectType,
    this.detectedPackageName,
  });
}
