import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class ArtifactService {
  Future<String> saveAndExtractApk({
    required Uint8List zipBytes,
    required String jobId,
    required String appName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${dir.path}/builds/$jobId');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final archive = ZipDecoder().decodeBytes(zipBytes);

    String? apkPath;
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.apk')) {
        final outputFile = File('${outputDir.path}/${file.name}');
        outputFile.createSync(recursive: true);
        outputFile.writeAsBytesSync(file.content as List<int>);
        apkPath = outputFile.path;
        break;
      }
    }

    if (apkPath == null) {
      throw Exception('No APK found in artifact ZIP');
    }

    return apkPath;
  }

  Future<void> cleanupBuild(String jobId) async {
    final dir = await getApplicationDocumentsDirectory();
    final buildDir = Directory('${dir.path}/builds/$jobId');
    if (buildDir.existsSync()) {
      buildDir.deleteSync(recursive: true);
    }
  }
}
