import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:emmet/core/app_export.dart';
import 'dart:io';
import 'dart:math';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  CameraImage? _cameraImage;
  List<Map<String, dynamic>>? _recognitionsList;
  bool _isRearCameraSelected = true;
  bool isDetecting = false;

  FlutterVision vision = FlutterVision();
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

  Map<String, Color> _classColors = {};  // Map to store colors for each class

  int _detectedClassCount = 0;

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
      1.0,  // Opacity
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
        _detectedClassCount = result.length;
      });
    } finally {
      isDetecting = false;
    }
  }

  @override
  void deactivate() {
    // Stop the camera stream when the screen is deactivated (e.g., navigating away)
    if (_cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // Ensure all resources are released when the widget is disposed
    if (_cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
    _cameraController.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  List<Widget> _displayBoxesAroundRecognizedObjects(Size screen) {
    if (_recognitionsList == null) return [];

    final double factorX = screen.width / _cameraController.value.previewSize!.height;
    final double factorY = screen.height / _cameraController.value.previewSize!.width;

    return _recognitionsList!.map((result) {
      final box = result["box"];
      final tag = result["tag"];
      final confidence = box[4];

      // Assign a color if the class doesn't have one yet
      if (!_classColors.containsKey(tag)) {
        _classColors[tag] = _getRandomColor();
      }

      final Color boxColor = _classColors[tag]!; // Retrieve the color for the current class

      return Positioned(
        left: box[0] * factorX,
        top: box[1] * factorY,
        width: (box[2] - box[0]) * factorX,
        height: (box[3] - box[1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: boxColor, width: 2.0), // Use the randomized color
          ),
          child: Text(
            "$tag ${(confidence * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = boxColor, // Match text background with box color
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _flipCamera() async {
    if (_cameras.length > 1) {
      _isRearCameraSelected = !_isRearCameraSelected;
      final camera = _isRearCameraSelected ? _cameras.first : _cameras.last;
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
        camera,
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        // ignore: unnecessary_null_comparison
        body: _initializeControllerFuture == null
            ? Center(child: CircularProgressIndicator())
            : FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_cameraController),
                  ),
                  ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 30.v),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTopBar(context),
                        Spacer(),
                        CustomImageView(
                          imagePath: _detectedClassCount > 0
                              ? ImageConstant.legoIcon // Use legoIcon when detectedClassCount > 0
                              : ImageConstant.imgTipsIcon, // Use the default icon otherwise
                          height: 60.adaptSize,
                          width: 60.adaptSize,
                        ),
                        SizedBox(
                          width: 164.h,
                          child: Text(
                            _detectedClassCount > 0
                                ? "Detected $_detectedClassCount LEGO bricks."
                                : "Press the capture button to freeze the current frame and analyze the LEGO bricks present.",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: CustomTextStyles.labelMedium10_1,
                          ),
                        ),
                        SizedBox(height: 10.v),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 39.h),
                          decoration: AppDecoration.outlineBlack900.copyWith(
                            borderRadius: BorderRadiusStyle.roundedBorder23,
                          ),
                          child: GestureDetector(
                            onTap: _detectedClassCount > 0 ? () async {
                              await onTapDetectBricks(context);
                            } : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 60.h,
                                vertical: 10.v,
                              ),
                              decoration: BoxDecoration(
                                color: _detectedClassCount > 0 ? theme.colorScheme.primary : Colors.grey, // Gray background when disabled
                                borderRadius: BorderRadiusStyle.roundedBorder23,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Capture",
                                    style: CustomTextStyles.titleLargeOnPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 17.v),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgClose,
            height: 30.adaptSize,
            width: 30.adaptSize,
            onTap: () {
              onTapCloseButton(context);
            },
          ),
          if (_cameras.length > 1)
            GestureDetector(
              onTap: _flipCamera,
              child: CustomImageView(
                imagePath: ImageConstant.imgCameraFlipButton,
                width: 55.h,
              ),
            ),
        ],
      ),
    );
  }

  void onTapCloseButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homeScreen);
  }

  bool _isCapturing = false; // Flag to manage capture operations

  Future<void> onTapDetectBricks(BuildContext context) async {
    if (_isCapturing) return;
    _isCapturing = true;

    late BuildContext loadingDialogContext;
    late BuildContext alertDialogContext;

    try {
      // Show loading spinner
      // ignore: unused_local_variable
      final loadingDialogFuture = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          loadingDialogContext = context;
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Ensure the camera is ready
      await _initializeControllerFuture;
      if (!_cameraController.value.isInitialized) {
        Navigator.of(context).pop();
        throw Exception("Camera initialization not complete or controller not ready.");
      }

      // Stop image stream before capturing
      await _cameraController.stopImageStream();

      // Capture the image
      XFile imageFile = await _cameraController.takePicture();

      // Load image as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to CameraImage equivalent for dimensions if necessary
      final decodedImage = await decodeImageFromList(bytes);
      final imageHeight = decodedImage.height;
      final imageWidth = decodedImage.width;

      // Run inference on the captured image
      final result = await vision.yoloOnImage(
        bytesList: bytes,               // Pass the captured image bytes
        imageHeight: imageHeight,         // Correct height from the decoded image
        imageWidth: imageWidth,           // Correct width from the decoded image
        iouThreshold: _iouThreshold,
        confThreshold: _confThreshold,
        classThreshold: _classThreshold,
      );

      // Extract recognized tags
      List<String> recognizedTags = result.map((detection) => detection['tag'].toString()).toList();

      if (recognizedTags.isEmpty) {
        // Show alert dialog if no bricks are detected
        showDialog(
          context: context,
          builder: (BuildContext context) {
            alertDialogContext = context;
            return AlertDialog(
              title: Text("No Bricks Detected"),
              content: Text("No LEGO bricks were detected in the captured image. Please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(alertDialogContext).pop(); // Close the alert dialog
                    Navigator.of(loadingDialogContext).pop(); // Close the loading spinner
                    _cameraController.startImageStream((CameraImage image) {
                      _cameraImage = image;
                      _runModel();
                    });
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Dismiss the loading spinner dialog
        Navigator.of(loadingDialogContext).pop();
        // Handle recognized tags
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.exploreScreen,
          arguments: recognizedTags,  // Pass recognized tags
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading spinner if an error occurs
      print("Error during image inference: $e");
    } finally {
      _isCapturing = false;
    }
  }

}