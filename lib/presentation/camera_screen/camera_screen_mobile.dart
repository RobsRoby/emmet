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

  Map<String, Color> _classColors = {};  // Map to store colors for each class

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
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
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

    isDetecting = true; // Set the flag to prevent overlapping detections

    try {
      final result = await vision.yoloOnFrame(
        bytesList: _cameraImage!.planes.map((plane) => plane.bytes).toList(),
        imageHeight: _cameraImage!.height,
        imageWidth: _cameraImage!.width,
        iouThreshold: 0.5,  // Adjust based on your stability needs
        confThreshold: 0.5, // Adjust for confidence threshold
      );

      setState(() {
        _recognitionsList = result;  // Store detection results
      });
    } finally {
      isDetecting = false; // Release flag after detection completes
    }
  }

  @override
  void dispose() {
    _cameraController.stopImageStream();
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
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
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
                          imagePath: ImageConstant.imgTipsIcon,
                          height: 60.adaptSize,
                          width: 60.adaptSize,
                        ),
                        SizedBox(
                          width: 164.h,
                          child: Text(
                            "Press the capture button to freeze the current frame and analyze the LEGO bricks present.",
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
                            onTap: () async {
                              await onTapDetectBricks(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 60.h,
                                vertical: 10.v,
                              ),
                              decoration: AppDecoration.fillPrimary.copyWith(
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

    try {
      // Show loading spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
        iouThreshold: 0.8,                // Set the IoU threshold
        confThreshold: 0.4,               // Set the confidence threshold
        classThreshold: 0.7,              // Set the class probability threshold
      );

      // Extract recognized tags
      List<String> recognizedTags = result.map((detection) => detection['tag'].toString()).toList();

      // Handle recognized tags
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.exploreScreen,
        arguments: recognizedTags,  // Pass recognized tags
      );
    } catch (e) {
      Navigator.of(context).pop();
      print("Error during image inference: $e");
    } finally {
      _isCapturing = false;
    }
  }

}
