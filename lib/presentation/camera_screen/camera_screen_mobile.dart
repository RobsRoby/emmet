// camera_screen_mobile.dart
// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:emmet/core/app_export.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  bool _isRearCameraSelected = true;
  late tfl.Interpreter _interpreter;

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
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  // Load the YOLOv7 TFLite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(ModelConstant.yoloV7);
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  void _flipCamera() async {
    if (_cameras.length > 1) {
      _isRearCameraSelected = !_isRearCameraSelected;
      final camera = _isRearCameraSelected ? _cameras.first : _cameras.last;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _cameraController.initialize();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
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
                              await _detectBricks();
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

  // Detect bricks using the YOLOv7 model
  Future<void> _detectBricks() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      img.Image imageInput = img.decodeImage(await image.readAsBytes())!;

      // Resize the image to the input size of the YOLOv7 model
      img.Image resizedImage = img.copyResize(imageInput, width: 640, height: 640);
      Uint8List input = _imageToByteList(resizedImage);

      // Allocate input and output buffers
      var output = List.generate(1, (index) => List.filled(25200 * 7, 0.0));

      // Run inference
      _interpreter.run(input, output);

      // Process and display the results (bounding boxes)
      // TODO: Parse the output and draw bounding boxes on the camera preview

      print("Inference completed!");
    } catch (e) {
      print("Error detecting bricks: $e");
    }
  }

  Uint8List _imageToByteList(img.Image image) {
    var buffer = Uint8List(640 * 640 * 3);
    int index = 0;
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        var pixel = image.getPixel(x, y);
        buffer[index++] = img.getRed(pixel);
        buffer[index++] = img.getGreen(pixel);
        buffer[index++] = img.getBlue(pixel);
      }
    }
    return buffer;
  }

  /// Section Widget
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

  /// Navigates to the homeScreen when the action is triggered.
  void onTapCloseButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homeScreen);
  }
}
