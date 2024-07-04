import 'package:flutter/material.dart';
import 'capture_tile.dart'; // Import the new CaptureTile widget
import 'package:emmet/widgets/bottom_navigation_bar.dart';

class CapturesScreen extends StatefulWidget {
  CapturesScreen({Key? key}) : super(key: key);

  @override
  _CapturesScreenState createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  int currentIndex = 1; // Added to track the active screen
  int currentIndexPage = 0; // Added to track the active screen on pages

  PageController _pageController = PageController();

  int? clickedTileIndex;

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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0), // Add padding here
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 4, // 4 pages to accommodate 12 tiles (3x3 grid per page)
                  onPageChanged: (index) {
                    setState(() {
                      currentIndexPage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return GridView.builder(
                      itemCount: 9, // 3x3 grid
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8, // Adjust the aspect ratio if needed
                      ),
                      itemBuilder: (context, index) {
                        int tileIndex = pageIndex * 9 + index;
                        return CaptureTile(
                          tileIndex: tileIndex,
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
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
                      color: currentIndexPage == index ? Color.fromRGBO(33, 156, 144, 1) : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
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
