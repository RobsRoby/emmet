import '../widgets/twentyseven_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:emmet/core/app_export.dart';

// ignore: must_be_immutable
class FifteenItemWidget extends StatelessWidget {
  const FifteenItemWidget({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 165.v,
        crossAxisCount: 2,
        mainAxisSpacing: 19.h,
        crossAxisSpacing: 19.h,
      ),
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return TwentysevenItemWidget();
      },
    );
  }
}
