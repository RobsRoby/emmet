import 'dart:io';
import 'dart:math';
import 'package:webview_flutter/webview_flutter.dart';
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
  String generatedSet = '';
  String? _toggledPartNum;
  late WebViewController _webViewController;

  PageController _pageController = PageController();
  int _currentPage = 0;

  UserDatabaseHelper _databaseHelper = UserDatabaseHelper();
  DatabaseHelper _dbHelper = DatabaseHelper();

  bool useWebView = false;

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
    _checkSetExists();
  }

  Future<String> fetchGeneratedSet(String setNum) async {
    final db = await _databaseHelper.database;

    // Query to fetch the set_name and ldr_model from the captures table
    final result = await db.rawQuery(
        'SELECT set_num, ldr_model FROM generatedSets WHERE set_num = ?', [setNum]);

    if (result.isNotEmpty) {
      final ldrModel = result.first['ldr_model'] as String;
      final setName = result.first['set_num'] as String;

      // Set the setName in your state
      setState(() {
        this.setName = setName;
      });

      // Return the ldr_model to initialize the WebView or other logic
      return ldrModel;
    } else {
      throw Exception('Set not found in captures table');
    }
  }

  Future<void> _checkSetExists() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('SELECT name FROM setInfo WHERE set_num = ?', [widget.setNum]);

    if (results.isEmpty) {
      try {
        generatedSet = await fetchGeneratedSet(widget.setNum);
        setState(() {
          useWebView = true; // Use WebView instead of images
        });
        _initializeWebView(generatedSet);
      } catch (e) {
        print('Error: $e');
      }
    } else {
      _fetchSetName();
      _fetchParts();
      _fetchInstructionImages();
    }
  }

  Future<void> _initializeWebView(String generatedSet) async {
    print(generatedSet);
    _webViewController = WebViewController()
      ..loadRequest(Uri.parse('http://127.0.0.1:8080/buildinginstructions/instruction.html'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _webViewController.runJavaScript('updateLDrawCode($generatedSet);');
          },
        ),
      );
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
    int availableThreads = Platform.numberOfProcessors;
    int numThreads = (availableThreads / 2).floor(); // Use half of the available threads

    await vision.loadYoloModel(
      labels: GetBrickModel.labelsPath,
      modelPath: GetBrickModel.modelPath,
      modelVersion: GetBrickModel.modelVersion,
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
                    child: _initializeControllerFuture == null
                        ? Center(child: CircularProgressIndicator())
                        : AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                  ..._displayBoxesAroundRecognizedObjects(MediaQuery.of(context).size),
                ],
              ),
            ),

            // WebView or Content depending on the state of useWebView
            if (useWebView)
              Expanded(
                child: Container(
                  height: double.infinity,
                  child: ClipRRect(
                    child: WebViewWidget(controller: _webViewController),
                  ),
                ),
              )
            else ...[
              // Instruction Images Title
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Instruction Images',
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                ),
              ),
              // Instruction Images Carousel
              Expanded(
                child: Column(
                  children: [
                    // PageView to display images
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: instructionImages.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: instructionImages[index],
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.grey[300],
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.contain,
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    ),
                    // Indicator for Carousel
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "${_currentPage + 1} / ${instructionImages.length}",
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Parts List
              Container(
                 decoration: BoxDecoration(
                   color: Color.fromRGBO(255, 255, 182, 1), // Background color
                   borderRadius: BorderRadius.circular(10.0), // Optional: To give rounded corners
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1), // Shadow color
                       offset: Offset(0, 4), // Shadow position (vertical offset)
                       blurRadius: 8.0, // Spread of the shadow
                       spreadRadius: 2.0, // How much the shadow should spread
                     ),
                   ],
                 ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Parts List',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: min(100.v, constraints.maxHeight),
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
                                          ? _classColors[partNum] ?? theme.colorScheme.primary
                                          : isDetected ? _classColors[partNum] ?? Colors.grey : Colors.transparent,
                                      width: isToggled || isDetected ? 4.0 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Clip the image to prevent it from overlapping the border
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(46.0),
                                        child: CachedNetworkImage(
                                          imageUrl: part['img_url'],
                                          placeholder: (context, url) => CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                          width: 60.h,
                                          height: 60.h,
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
                  ]
                )
              ),




            ]
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
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline), // Help icon
          onPressed: () {
            _showHelpDialog(context);
          },
        ),
      ],
      styleType: Style.bgShadow,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpSection(
                  title: 'Live Object Detection',
                  description:
                  'This section uses the device\'s camera to detect LEGO parts in real-time. Recognized parts are highlighted with bounding boxes, and their names and confidence scores are displayed.',
                ),
                SizedBox(height: 10),
                _buildHelpSection(
                  title: 'WebView / Instruction Images',
                  description:
                  'Here, you can view the instructions for building your set. If a model has been generated, the instructions will be shown in a WebView. Otherwise, instruction images will be displayed in a carousel.',
                ),
                SizedBox(height: 10),
                _buildHelpSection(
                  title: 'Parts List',
                  description:
                  'This section lists the parts for the selected LEGO set. You can see the part number and quantity. If a part is detected by the camera, it will be highlighted in the list.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpSection({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 5),
        Text(description),
      ],
    );
  }


  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}