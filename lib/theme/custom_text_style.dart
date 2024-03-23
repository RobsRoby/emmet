import 'package:flutter/material.dart';
import 'package:emmet/core/utils/size_utils.dart';
import 'package:emmet/theme/theme_helper.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  // Body text style
  static get bodyMediumGray500 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray500,
      );
  static get bodySmallBlack900 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.black900.withOpacity(0.3),
        fontSize: 11.fSize,
      );
  static get bodySmallGray500 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray500,
        fontSize: 9.fSize,
      );
  static get bodySmallOnPrimary => theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 9.fSize,
      );
  static get bodySmallOnPrimaryContainer => theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontSize: 11.fSize,
      );
  static get bodySmallff939393 => theme.textTheme.bodySmall!.copyWith(
        color: Color(0XFF939393),
        fontSize: 9.fSize,
      );
  // Label text style
  static get labelMedium10 => theme.textTheme.labelMedium!.copyWith(
        fontSize: 10.fSize,
      );
  static get labelMedium10_1 => theme.textTheme.labelMedium!.copyWith(
        fontSize: 10.fSize,
      );
  static get labelMediumYellow800 => theme.textTheme.labelMedium!.copyWith(
        color: appTheme.yellow800,
      );
  // Title text style
  static get titleLargeOnPrimary => theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
      );
}

extension on TextStyle {
  TextStyle get lato {
    return copyWith(
      fontFamily: 'Lato',
    );
  }
}
