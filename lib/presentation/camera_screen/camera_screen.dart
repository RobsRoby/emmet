import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:emmet/core/app_export.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Obtain a list of the available cameras on the device.
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false, // Disable audio
    );

    // Initialize the controller and store the Future for later use.
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
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

  /// Captures the image and navigates to the exploreScreen when the action is triggered.
  Future<void> onTapDetectBricks(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      Navigator.pushReplacementNamed(context, AppRoutes.exploreScreen, arguments: image.path);
    } catch (e) {
      print(e);
    }
  }
}
