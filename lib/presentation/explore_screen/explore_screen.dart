import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:emmet/widgets/custom_outlined_button.dart';
import 'package:emmet/widgets/custom_elevated_button.dart';
import 'package:emmet/widgets/custom_search_view.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class ExploreScreen extends StatelessWidget {
  ExploreScreen({Key? key}) : super(key: key);

  TextEditingController searchController = TextEditingController();

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
                        padding: EdgeInsets.symmetric(horizontal: 4.h),
                        child: Column(children: [
                          _buildCard(context),
                          SizedBox(height: 25.v),
                          _buildCard1(context)
                        ]))))));
  }

  /// Section Widget
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
              text: "215 bricks", margin: EdgeInsets.symmetric(horizontal: 3.h))
        ]),
        styleType: Style.bgShadow);
  }

  /// Section Widget
  Widget _buildSave(BuildContext context) {
    return CustomOutlinedButton(
        width: 100.h,
        text: "Save",
        leftIcon: Container(
            margin: EdgeInsets.only(right: 7.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgFrameYellow800,
                height: 24.adaptSize,
                width: 24.adaptSize)));
  }

  /// Section Widget
  Widget _buildBuild(BuildContext context) {
    return CustomElevatedButton(
        width: 103.h,
        text: "Build",
        margin: EdgeInsets.only(left: 7.h),
        leftIcon: Container(
            margin: EdgeInsets.only(right: 8.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgFrameOnprimary,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapBuild(context);
        });
  }

  /// Section Widget
  Widget _buildCard(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 5.h, right: 3.h),
        decoration: AppDecoration.outlineBlack9001
            .copyWith(borderRadius: BorderRadiusStyle.roundedBorder11),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageView(imagePath: ImageConstant.imgMedia, height: 189.v),
              SizedBox(height: 17.v),
              Padding(
                  padding: EdgeInsets.only(left: 15.h),
                  child:
                      Text("An Airplane", style: theme.textTheme.titleSmall)),
              SizedBox(height: 10.v),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: EdgeInsets.only(right: 15.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildSave(context),
                            _buildBuild(context)
                          ]))),
              SizedBox(height: 15.v)
            ]));
  }

  /// Section Widget
  Widget _buildSave1(BuildContext context) {
    return CustomOutlinedButton(
        width: 100.h,
        text: "Save",
        leftIcon: Container(
            margin: EdgeInsets.only(right: 7.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgFrameYellow800,
                height: 24.adaptSize,
                width: 24.adaptSize)));
  }

  /// Section Widget
  Widget _buildBuild1(BuildContext context) {
    return CustomElevatedButton(
        width: 103.h,
        text: "Build",
        margin: EdgeInsets.only(left: 7.h),
        leftIcon: Container(
            margin: EdgeInsets.only(right: 7.h),
            child: CustomImageView(
                imagePath: ImageConstant.imgFrameOnprimary,
                height: 24.adaptSize,
                width: 24.adaptSize)),
        onPressed: () {
          onTapBuild1(context);
        });
  }

  /// Section Widget
  Widget _buildCard1(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 8.h),
        decoration: AppDecoration.outlineBlack9001
            .copyWith(borderRadius: BorderRadiusStyle.roundedBorder11),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 15.v),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadiusStyle.roundedBorder11),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: 194.v,
                        width: 342.h,
                        child:
                            Stack(alignment: Alignment.bottomCenter, children: [
                          CustomImageView(
                              imagePath: ImageConstant.imgMedia,
                              height: 189.v,
                              alignment: Alignment.center),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: CustomSearchView(
                                  width: 335.h,
                                  controller: searchController,
                                  hintText: "Generate more ideas..",
                                  alignment: Alignment.bottomCenter))
                        ])),
                    SizedBox(height: 12.v),
                    Padding(
                        padding: EdgeInsets.only(left: 15.h),
                        child: Text("An Airplane",
                            style: theme.textTheme.titleSmall)),
                    SizedBox(height: 10.v),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(right: 15.h),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildSave1(context),
                                  _buildBuild1(context)
                                ])))
                  ]))
        ]));
  }

  /// Navigates back to the previous screen.
  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }

  onTapBuild(BuildContext context) {
    // TODO: implement Actions
  }

  onTapBuild1(BuildContext context) {
    // TODO: implement Actions
  }
}
