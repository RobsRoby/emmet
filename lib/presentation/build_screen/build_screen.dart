import 'package:emmet/widgets/app_bar/custom_app_bar.dart';
import 'package:emmet/widgets/app_bar/appbar_leading_image.dart';
import 'package:emmet/widgets/app_bar/appbar_title.dart';
import 'package:emmet/widgets/app_bar/appbar_subtitle.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore_for_file: must_be_immutable
class BuildScreen extends StatelessWidget {
  BuildScreen({Key? key}) : super(key: key);

  Completer<GoogleMapController> googleMapController = Completer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: _buildAppBar(context),
            body: SizedBox(
                height: 580.v,
                width: double.maxFinite,
                child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(37.43296265331129, -122.08832357078792),
                        zoom: 14.4746),
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController.complete(controller);
                    },
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false))));
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
          AppbarTitle(
              text: "Build", margin: EdgeInsets.only(left: 11.h, right: 13.h)),
          AppbarSubtitle(text: "An Airplane")
        ]),
        styleType: Style.bgShadow);
  }

  /// Navigates back to the previous screen.
  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}
