import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:emmet/core/app_export.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:async';

// BoundingBoxPainter class to draw bounding boxes
class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boxes;

  BoundingBoxPainter(this.boxes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Rect box in boxes) {
      // Scale the bounding box to fit the screen size (assuming 640x640 input for YOLOv7)
      final scaledBox = Rect.fromLTRB(
        box.left * size.width,
        box.top * size.height,
        box.right * size.width,
        box.bottom * size.height,
      );
      canvas.drawRect(scaledBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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
  bool _isDetecting = false;
  int _brickCount = 0;
  List<Rect> _boundingBoxes = [];

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
    _initializeControllerFuture = _cameraController.initialize().then((_) {
      _cameraController.startImageStream((image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _runObjectDetection(image);
        }
      });
    });
    setState(() {});
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(GetModel.modelPath);
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

  Future<void> _runObjectDetection(CameraImage cameraImage) async {
    try {
      final img.Image imageInput = _convertCameraImage(cameraImage);
      final img.Image resizedImage = img.copyResize(imageInput, width: 640, height: 640);
      Uint8List input = _imageToByteList(resizedImage);

      var output = List.generate(1, (index) => List.filled(25200 * 7, 0.0));

      _interpreter.run(input, output);

      final List<Rect> boxes = [];
      final brickCount = _processOutput(output, boxes);

      setState(() {
        _brickCount = brickCount;
        _boundingBoxes = boxes;
      });

      _isDetecting = false;
    } catch (e) {
      print("Error detecting bricks: $e");
      _isDetecting = false;
    }
  }

  img.Image _convertCameraImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final Uint8List yPlane = cameraImage.planes[0].bytes;
    final Uint8List uPlane = cameraImage.planes[1].bytes;
    final Uint8List vPlane = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    img.Image imgRGB = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        final int indexY = y * yRowStride + x;

        final int yValue = yPlane[indexY];
        final int uValue = uPlane[uvIndex] - 128;
        final int vValue = vPlane[uvIndex] - 128;

        final int r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final int g = (yValue - 0.344136 * uValue - 0.714136 * vValue).clamp(0, 255).toInt();
        final int b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

        imgRGB.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    return imgRGB;
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

  int _processOutput(List<List<double>> output, List<Rect> boxes) {
    int count = 0;
    List<double> detections = output[0];

    for (int i = 0; i < detections.length; i += 7) {
      double confidence = detections[i + 4];

      if (confidence > 0.5) {
        count++;

        double x_center = detections[i];
        double y_center = detections[i + 1];
        double width = detections[i + 2];
        double height = detections[i + 3];

        double left = x_center - width / 2;
        double top = y_center - height / 2;
        Rect boundingBox = Rect.fromLTWH(left, top, width, height);

        boxes.add(boundingBox);
      }
    }

    return count;
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
                  CustomPaint(
                    painter: BoundingBoxPainter(_boundingBoxes),
                    child: Container(),
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
                            "Detected Bricks: $_brickCount",
                            maxLines: 1,
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
                              // No need for manual capture button anymore since detection is real-time
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
                                    "Detecting...",
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
}
