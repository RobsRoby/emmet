import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:emmet/widgets/custom_outlined_button.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

class ExploreScreen extends StatefulWidget {
  final List<String> recognizedTags;

   const ExploreScreen({Key? key, required this.recognizedTags}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> _sets = [];

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  Future<void> _loadSets() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> sets = await dbHelper.fetchSetsByParts(widget.recognizedTags);

    // Debug print to check fetched sets
    print("Fetched sets: $sets"); // Check if sets are fetched correctly

    setState(() {
      _sets = sets;
    });

    // Debug print after setting state
    print("State updated with sets: $_sets");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _buildAppBar(context),
            body: SizedBox(
                width: SizeUtils.width,
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 25.v),
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                        child: _sets.isEmpty
                            ? Center(
                          child: Text(
                            "No LEGO sets found for the detected bricks.",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.black, // Customize as needed
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : Column(
                          children: _sets
                              .map((set) => Padding(
                            padding: EdgeInsets.only(bottom: 16.h), // Space between cards
                            child: _buildCard(context, set),
                          ))
                              .toList(),
                        ))))));
  }

  /// Top Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
        leadingWidth: 54.h,
        leading: AppbarLeadingImage(
            imagePath: ImageConstant.imgArrowLeft,
            margin: EdgeInsets.only(left: 30.h, top: 20.v, bottom: 20.v),
            onTap: () {
              onTapArrowLeft(context);
            }),
        centerTitle: true,
        title: Column(children: [
          AppbarTitle(text: "Explore"),
          AppbarSubtitle(
              text: "${widget.recognizedTags.length} bricks", margin: EdgeInsets.symmetric(horizontal: 3.h))
        ]),
        styleType: Style.bgShadow);
  }

  /// Save Button
  Widget _buildSave(BuildContext context, String setNum) {
    return CustomOutlinedButton(
        width: 100.h,
        text: "Save",
        leftIcon: Container(
            margin: EdgeInsets.only(right: 7.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgSave,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapSave(context, setNum);
        }
    );
  }

  /// Build Button
  Widget _buildBuild(BuildContext context, String setNum) {
    return CustomElevatedButton(
        width: 103.h,
        text: "Build",
        margin: EdgeInsets.only(left: 7.h),
        leftIcon: Container(
            margin: EdgeInsets.only(right: 8.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgBuild,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapBuild(context, setNum);
        });
  }

  /// LEGO Set Card
  Widget _buildCard(BuildContext context, Map<String, dynamic> set) {
    print("Building card for set: ${set['name']}"); // Debug print to check set data
    return Container(
      margin: EdgeInsets.all(5.h),
      decoration: AppDecoration.outlineBlack9001
          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder11),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              set['img_url'],
              height: 189.0,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
            SizedBox(height: 17.v),
            Padding(
              padding: EdgeInsets.only(left: 15.h),
              child: Text(set['name'], style: Theme.of(context).textTheme.titleSmall),
            ),
            SizedBox(height: 10.v),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSave(context, set['set_num']),
                    _buildBuild(context, set['set_num']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.v),
          ],
        ),
      ),
    );
  }

  void onTapBuild(BuildContext context, String setNum) {
    Navigator.pushNamed(context, AppRoutes.buildScreen, arguments: setNum);
  }

  void onTapSave(BuildContext context, String setNum) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('LEGO set $setNum saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void onTapArrowLeft(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Go back home or capture bricks?"),
          actions: <Widget>[
            TextButton(
              child: Text("Go Home"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
              },
            ),
            TextButton(
              child: Text("Capture Another"),
              onPressed: () {
                // Implement navigation to capture screen or take action
                Navigator.pushReplacementNamed(context, AppRoutes.cameraScreen);
              },
            ),
          ],
        );
      },
    );
  }
}
