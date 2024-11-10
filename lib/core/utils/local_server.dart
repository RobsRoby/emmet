import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

Future<void> startServer() async {
  // Get the system's temporary directory
  Directory tempDir = await getTemporaryDirectory();

  // Define target directories for each asset set
  String brickBuilderDir = '${tempDir.path}/brick_builder';
  String minifigureMakerDir = '${tempDir.path}/minifigure_maker';
  String buildingInstructionsDir = '${tempDir.path}/buildinginstructions';

  // Create the directories
  Directory(brickBuilderDir).createSync(recursive: true);
  Directory(minifigureMakerDir).createSync(recursive: true);
  Directory(buildingInstructionsDir).createSync(recursive: true);

  // Copy assets for each application
  await _copyAssetsToDirectory('assets/brick_builder', brickBuilderDir);
  await _copyAssetsToDirectory('assets/minifigure_maker', minifigureMakerDir);
  await _copyAssetsToDirectory('assets/buildinginstructions', buildingInstructionsDir);

  // Check if files were copied correctly
  _listFilesInDirectory(brickBuilderDir);
  _listFilesInDirectory(minifigureMakerDir);
  _listFilesInDirectory(buildingInstructionsDir);

  // Create handlers for each application
  var brickBuilderHandler = createStaticHandler(
    brickBuilderDir,
    defaultDocument: 'preview.html',
  );

  var minifigureMakerHandler = createStaticHandler(
    minifigureMakerDir,
    defaultDocument: 'preview.html',
  );

  var buildingInstructionsHandler = createStaticHandler(
    buildingInstructionsDir,
    defaultDocument: 'preview.html',
  );

  // Define a 404 fallback handler for unmatched paths
  var fallbackHandler = (Request request) => Response.notFound('Page not found');

  // Mount each handler to its respective route and add fallback
  var cascade = Cascade()
      .add((Request request) {
    if (request.url.path.startsWith('brick_builder')) {
      return brickBuilderHandler(request.change(path: 'brick_builder'));
    }
    return fallbackHandler(request); // Ensure non-null response
  })
      .add((Request request) {
    if (request.url.path.startsWith('minifigure_maker')) {
      return minifigureMakerHandler(request.change(path: 'minifigure_maker'));
    }
    return fallbackHandler(request); // Ensure non-null response
  })
      .add((Request request) {
    if (request.url.path.startsWith('buildinginstructions')) {
      return buildingInstructionsHandler(request.change(path: 'buildinginstructions'));
    }
    return fallbackHandler(request); // Ensure non-null response
  })
      .handler;

  // Start the server with the cascaded handler
  var server = await shelf_io.serve(cascade, InternetAddress.loopbackIPv4, 8080);
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

