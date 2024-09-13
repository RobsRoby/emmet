import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For displaying network images
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:math';

class BuildScreen extends StatefulWidget {
  final String setNum;

  BuildScreen({Key? key, required this.setNum}) : super(key: key);

  @override
  _BuildScreenState createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  CameraImage? _cameraImage;
  List<Map<String, dynamic>>? _recognitionsList;
  bool isDetecting = false;
  List<String> instructionImages = [];
  List<Map<String, dynamic>> partsList = [];
  FlutterVision vision = FlutterVision();
  Map<String, Color> _classColors = {};
  String setName = '';
  String? _toggledPartNum;


  UserDatabaseHelper _databaseHelper = UserDatabaseHelper();

  double _iouThreshold = 0.5;
  double _confThreshold = 0.5;
  double _classThreshold = 0.5;
  String _cameraResolution = 'medium';

  Future<void> _loadSettings() async {
    Map<String, dynamic> settings = await _databaseHelper.getSettings();

    setState(() {
      _iouThreshold = settings['iouThreshold'] ?? 0.5;
      _confThreshold = settings['confThreshold'] ?? 0.5;
      _classThreshold = settings['classThreshold'] ?? 0.5;
      _cameraResolution = settings['cameraResolution'] ?? 'medium';
    });

    _initializeCamera();
    _loadModel();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchSetName();
    _fetchParts();
    _fetchInstructionImages();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    ResolutionPreset resolutionPreset;

    switch (_cameraResolution) {
      case 'low':
        resolutionPreset = ResolutionPreset.low;
        break;
      case 'high':
        resolutionPreset = ResolutionPreset.high;
        break;
      case 'medium':
      default:
        resolutionPreset = ResolutionPreset.medium;
    }

    _cameraController = CameraController(
      _cameras.first,
      resolutionPreset,
      enableAudio: false,
    );

    _initializeControllerFuture = _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _cameraController.startImageStream((CameraImage image) {
        _cameraImage = image;
        _runModel();
      });
    });
  }

  Future<void> _loadModel() async {
    int numThreads = Platform.numberOfProcessors;

    await vision.loadYoloModel(
      labels: GetModel.labelsPath,
      modelPath: GetModel.modelPath,
      modelVersion: "yolov8",
      quantization: false,
      numThreads: numThreads,
      useGpu: true,
    );
  }

  Future<void> _runModel() async {
    if (_cameraImage == null || isDetecting) return;

    isDetecting = true;

    try {
      final result = await vision.yoloOnFrame(
        bytesList: _cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: _cameraImage!.height,
        imageWidth: _cameraImage!.width,
        iouThreshold: _iouThreshold,
        confThreshold: _confThreshold,
        classThreshold: _classThreshold,
      );

      setState(() {
        _recognitionsList = result;
      });
    } finally {
      isDetecting = false;
    }
  }

  Future<void> _fetchSetName() async {
    final db = await DatabaseHelper().database;
    final results = await db.rawQuery('''
      SELECT name
      FROM setInfo
      WHERE set_num = ?
    ''', [widget.setNum]);

    if (results.isNotEmpty) {
      setState(() {
        setName = results.first['name'] as String;
      });
    }
  }

  Future<void> _fetchParts() async {
    final db = await DatabaseHelper().database;
    final results = await db.rawQuery(''' 
      SELECT p.part_num, p.img_url, COUNT(p.part_num) AS quantity 
      FROM sets s
      JOIN partsInfo p ON s.partsInfo_id = p.partsInfo_id
      WHERE s.set_num = ?
      GROUP BY p.part_num
    ''', [widget.setNum]);

    setState(() {
      partsList = results.map((row) => {
        'part_num': row['part_num'],
        'img_url': row['img_url'],
        'quantity': row['quantity']
      }).toList();
    });
  }

  Future<void> _fetchInstructionImages() async {
    final db = await DatabaseHelper().database;

    // Try fetching from instruction_pictures first
    final instructionResults = await db.rawQuery('''
    SELECT image_url
    FROM instruction_pictures
    WHERE set_num = ?
  ''', [widget.setNum]);

    if (instructionResults.isNotEmpty) {
      setState(() {
        instructionImages = instructionResults.map((row) => row['image_url'] as String).toList();
      });
    } else {
      // If no results in instruction_pictures, fall back to setInfo
      final setInfoResults = await db.rawQuery('''
      SELECT img_url
      FROM setInfo
      WHERE set_num = ?
    ''', [widget.setNum]);

      if (setInfoResults.isNotEmpty) {
        setState(() {
          instructionImages = [setInfoResults.first['img_url'] as String];
        });
      }
    }

  }

  @override
  void deactivate() {
    // Stop the camera stream to save resources when the screen goes away.
    _cameraController.stopImageStream();
    super.deactivate();
  }

  @override
  void dispose() {
    // Clean up resources when the screen is permanently disposed.
    _cameraController.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  List<Widget> _displayBoxesAroundRecognizedObjects(Size screen) {
    if (_recognitionsList == null) return [];

    final double factorX = screen.width / _cameraController.value.previewSize!.height;
    final double factorY = screen.height / _cameraController.value.previewSize!.width;

    return _recognitionsList!.where((result) {
      final tag = result["tag"];
      // Only show the box if no part is toggled or the part matches the toggled part_num
      return _toggledPartNum == null || _toggledPartNum == tag;
    }).map((result) {
      final box = result["box"];
      final tag = result["tag"];
      final confidence = box[4];

      if (!_classColors.containsKey(tag)) {
        _classColors[tag] = _getRandomColor();
      }

      final Color boxColor = _classColors[tag]!;

      return Positioned(
        left: box[0] * factorX,
        top: box[1] * factorY,
        width: (box[2] - box[0]) * factorX,
        height: (box[3] - box[1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: boxColor, width: 2.0),
          ),
          child: Text(
            "$tag ${(confidence * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = boxColor,
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            // Live Object Detection
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    // Camera preview
                    // ignore: unnecessary_null_comparison
                    child: _initializeControllerFuture == null
                        ? Center(child: CircularProgressIndicator())
                        : FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_cameraController);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),

                  // Text overlay when a part is toggled
                  if (_toggledPartNum != null)
                    Positioned(
                      top: 20, // Position at the top of the screen
                      left: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          "Now filtering: $_toggledPartNum",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Instruction Images
            Expanded(
              child: PageView.builder(
                itemCount: instructionImages.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: instructionImages[index],
                    // Add Shimmer for loading effect
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey[300], // Placeholder color for shimmer
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.contain, // Adjust this as per your design
                  );
                },
              ),
            ),
            // Parts List
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: min(120.v, constraints.maxHeight), // Adjust height dynamically
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: partsList.length,
                    itemBuilder: (context, index) {
                      final part = partsList[index];
                      final partNum = part['part_num'];

                      // Check if this part is recognized in object detection
                      final isDetected = _recognitionsList?.any((r) => r["tag"] == partNum) ?? false;
                      final isToggled = _toggledPartNum == partNum;

                      return GestureDetector(
                        onTap: () {
                          // Toggle the part filter
                          setState(() {
                            _toggledPartNum = _toggledPartNum == partNum ? null : partNum;
                          });
                        },
                        child: Container(
                          width: 100.h,
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: isToggled
                                  ? _classColors[partNum] ?? theme.colorScheme.primary // Use class color or fallback
                                  : isDetected ? _classColors[partNum] ?? Colors.grey : Colors.transparent,
                              width: isToggled || isDetected ? 4.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Clip the image to prevent it from overlapping the border
                              ClipRRect(
                                borderRadius: BorderRadius.circular(46.0), // Slightly less than the container's borderRadius
                                child: CachedNetworkImage(
                                  imageUrl: part['img_url'],
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  width: 80.h,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Text with part number and quantity
                              Container(
                                margin: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "${partNum} x${part['quantity']}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 54.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowLeft,
        margin: EdgeInsets.only(left: 20.h, top: 20.v, bottom: 20.v),
        onTap: () {
          onTapArrowLeft(context);
        },
      ),
      centerTitle: true,
      title: Column(children: [
        AppbarTitle(
          text: "Build",
        ),
        AppbarSubtitle(
          text: "Set ${widget.setNum} - $setName",
        ),
      ]),
      styleType: Style.bgShadow,
    );
  }

  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}
