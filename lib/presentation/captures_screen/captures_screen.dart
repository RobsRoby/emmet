import 'package:carousel_slider/carousel_slider.dart';
import 'widgets/fifteen_item_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:emmet/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class CapturesScreen extends StatelessWidget {
  CapturesScreen({Key? key}) : super(key: key);

  int sliderIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 33.h, vertical: 26.v),
                child: Column(children: [
                  SizedBox(height: 28.v),
                  Text("Recent Captures\r",
                      style: theme.textTheme.headlineLarge),
                  SizedBox(height: 3.v),
                  Text("View and manage your recent LEGO brick captures.",
                      style: theme.textTheme.bodyMedium),
                  SizedBox(height: 35.v),
                  _buildFifteen(context),
                  SizedBox(height: 23.v),
                  SizedBox(
                      height: 10.v,
                      child: AnimatedSmoothIndicator(
                          activeIndex: sliderIndex,
                          count: 1,
                          axisDirection: Axis.horizontal,
                          effect: ScrollingDotsEffect(
                              spacing: 4,
                              activeDotColor:
                                  theme.colorScheme.onPrimaryContainer,
                              dotColor: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.5),
                              dotHeight: 10.v,
                              dotWidth: 10.h)))
                ])),
            bottomNavigationBar: _buildBottomNavigationBar(context)));
  }

  /// Section Widget
  Widget _buildFifteen(BuildContext context) {
    return CarouselSlider.builder(
        options: CarouselOptions(
            height: 343.v,
            initialPage: 0,
            autoPlay: true,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              sliderIndex = index;
            }),
        itemCount: 1,
        itemBuilder: (context, index, realIndex) {
          return FifteenItemWidget();
        });
  }

  /// Section Widget
  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
        height: 88.v,
        width: double.maxFinite,
        child: Stack(alignment: Alignment.topCenter, children: [
          CustomImageView(
              imagePath: ImageConstant.imgBg,
              height: 63.v,
              alignment: Alignment.bottomCenter),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 50.h, right: 50.h, bottom: 8.v),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 3.v),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconButton(
                                      height: 45.adaptSize,
                                      width: 45.adaptSize,
                                      padding: EdgeInsets.all(12.h),
                                      onTap: () {
                                        onTapBtnSettings(context);
                                      },
                                      child: CustomImageView(
                                          imagePath:
                                              ImageConstant.imgSettings)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 15.v),
                                      child: Text("Home",
                                          style: theme.textTheme.bodySmall))
                                ])),
                        Spacer(flex: 50),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          CustomIconButton(
                              height: 49.adaptSize,
                              width: 49.adaptSize,
                              padding: EdgeInsets.all(12.h),
                              decoration: IconButtonStyleHelper.fillYellow,
                              child: CustomImageView(
                                  imagePath: ImageConstant.imgFrame1)),
                          Padding(
                              padding: EdgeInsets.only(top: 16.v),
                              child: Text("Recent Captures",
                                  style: theme.textTheme.bodySmall))
                        ]),
                        Spacer(flex: 50),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          CustomIconButton(
                              height: 49.adaptSize,
                              width: 49.adaptSize,
                              padding: EdgeInsets.all(12.h),
                              onTap: () {
                                onTapBtnIconButton(context);
                              },
                              child: CustomImageView(
                                  imagePath: ImageConstant.imgFrame49x49)),
                          Padding(
                              padding: EdgeInsets.only(top: 16.v),
                              child: Text("Settings",
                                  style: theme.textTheme.bodySmall))
                        ])
                      ])))
        ]));
  }

  onTapBtnSettings(BuildContext context) {
    // TODO: implement Actions
  }

  /// Navigates to the settingsScreen when the action is triggered.
  onTapBtnIconButton(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settingsScreen);
  }
}
