import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'capture_tile.dart'; // Import the new CaptureTile widget
import 'package:emmet/widgets/bottom_navigation_bar.dart';
import 'package:emmet/core/app_export.dart';
import 'package:shimmer/shimmer.dart';

class CapturesScreen extends StatefulWidget {
  CapturesScreen({Key? key}) : super(key: key);

  @override
  _CapturesScreenState createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  int currentIndex = 1; // Track the active screen
  int currentIndexPage = 0; // Track the active screen on pages
  PageController _pageController = PageController();
  int? clickedTileIndex;
  List<Map<String, dynamic>> _captures = [];
  bool _isLoading = true;  // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCaptures();
  }

  Future<void> _fetchCaptures() async {
    UserDatabaseHelper dbHelper = UserDatabaseHelper();
    List<Map<String, dynamic>> captures = await dbHelper.fetchAllCaptures();
    setState(() {
      _captures = captures;
      _isLoading = false;  // Stop loading when data is fetched
    });
  }

  Future<void> _deleteCapture(String setNum, bool isGeneratedSet) async {
    UserDatabaseHelper dbHelper = UserDatabaseHelper();
    await dbHelper.deleteCapture(setNum, isGeneratedSet);
    await _fetchCaptures(); // Refresh the list after deletion
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 47.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 49.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("Recent Captures",
                        style: Theme.of(context).textTheme.headlineLarge),
                  ),
                  SizedBox(height: 3.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "View and manage your recent LEGO brick captures.",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: _isLoading
                  ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: 9,  // Number of shimmer tiles to show
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return _buildShimmerTile();  // Display shimmer tile
                  },
                ),
              )
                  : _captures.isEmpty
                  ? Center(
                child: Text(
                  "No captures available. \n You haven't saved any LEGO sets yet.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
                  : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: (_captures.length / 9).ceil(), // Calculate pages based on number of tiles
                  onPageChanged: (index) {
                    setState(() {
                      currentIndexPage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return GridView.builder(
                      itemCount: (_captures.length - pageIndex * 9).clamp(0, 9),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        int tileIndex = pageIndex * 9 + index;
                        var capture = _captures[tileIndex];
                        return CaptureTile(
                          tileIndex: tileIndex,
                          imgUrl: capture['img_url'] as String?,
                          imgData: capture['img_data'] as Uint8List?,
                          setNum: capture['set_num'],
                          isClicked: clickedTileIndex == tileIndex,
                          onTileClick: () {
                            setState(() {
                              if (clickedTileIndex == tileIndex) {
                                clickedTileIndex = null;
                              } else {
                                clickedTileIndex = tileIndex;
                              }
                            });
                          },
                          onDelete: () {
                            if (capture['img_data'] != null) {
                              _deleteCapture(capture['set_num'], true);
                            }else{
                              _deleteCapture(capture['set_num'], false);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            if (_captures.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate((_captures.length / 9).ceil(), (index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      width: currentIndexPage == index ? 12.0 : 8.0,
                      height: currentIndexPage == index ? 12.0 : 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndexPage == index
                            ? Color.fromRGBO(33, 156, 144, 1)
                            : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 30.0),
          ],
        ),

        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
