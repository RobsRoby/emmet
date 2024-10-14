import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

Future<void> startServer() async {
  // Get the system's temporary directory
  Directory tempDir = await getTemporaryDirectory();

  // Define the target directory for your assets
  String targetDir = '${tempDir.path}/buildinginstructions';
  Directory(targetDir).createSync(recursive: true);

  // Copy all assets from the bundled assets to the temp directory
  await _copyAssetsToDirectory('assets/buildinginstructions', targetDir);

  // Check if files were copied correctly
  _listFilesInDirectory(targetDir);

  // Now serve the files from the temp directory
  var handler = createStaticHandler(
    targetDir,
    defaultDocument: 'preview.html',
  );

  // Start the HTTPS server
  var server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

void _listFilesInDirectory(String dirPath) {
  final dir = Directory(dirPath);
  dir.list().forEach((FileSystemEntity entity) {
    print('File: ${entity.path}');
  });
}

Future<void> _copyAssetsToDirectory(String assetPath, String targetPath) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  // Log the entire manifest for debugging
  print('Asset Manifest: ${manifestMap.keys}');

  // Filter the files under the assetPath including subdirectories
  final assetFiles = manifestMap.keys
      .where((String key) => key.startsWith(assetPath))
      .toList();

  // Log the assets that will be copied
  print('Assets to be copied: $assetFiles');

  for (String asset in assetFiles) {
    // Create the target file path by replacing the asset path with the target path
    final relativePath = asset.replaceFirst(assetPath, '');
    final file = File('$targetPath/$relativePath');

    // Debugging: Print what will be created
    print('Copying asset: $asset to ${file.path}');

    // Ensure the directory exists before creating the file
    await file.parent.create(recursive: true);
    await file.writeAsBytes(
      (await rootBundle.load(asset)).buffer.asUint8List(),
    );

    // Debugging: Confirm that the file was created
    print('File created: ${file.path}');
  }
}
