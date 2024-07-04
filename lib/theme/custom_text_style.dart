import 'package:flutter/material.dart';
import 'package:emmet/core/utils/size_utils.dart';
import 'package:emmet/theme/theme_helper.dart';
import 'package:google_fonts/google_fonts.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  static get bodyMediumGray500 => GoogleFonts.lato(
    textStyle: theme.textTheme.bodyMedium!.copyWith(
      color: appTheme.gray500,
    ),
  );

  static get bodySmallBlack900 => GoogleFonts.lato(
    textStyle: theme.textTheme.bodySmall!.copyWith(
      color: appTheme.black900.withOpacity(0.3),
      fontSize: 11.fSize,
    ),
  );

  static get bodySmallGray500 => GoogleFonts.lato(
    textStyle: theme.textTheme.bodySmall!.copyWith(
      color: appTheme.gray500,
      fontSize: 9.fSize,
    ),
  );

  static get bodySmallOnPrimary => GoogleFonts.lato(
    textStyle: theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 9.fSize,
    ),
  );

  static get bodySmallOnPrimaryContainer => GoogleFonts.lato(
    textStyle: theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontSize: 11.fSize,
    ),
  );

  static get bodySmallff939393 => GoogleFonts.lato(
    textStyle: theme.textTheme.bodySmall!.copyWith(
      color: Color(0XFF939393),
      fontSize: 9.fSize,
    ),
  );

  static get labelMedium10 => GoogleFonts.lato(
    textStyle: theme.textTheme.labelMedium!.copyWith(
      fontSize: 10.fSize,
    ),
  );

  static get labelMedium10_1 => GoogleFonts.lato(
    textStyle: theme.textTheme.labelMedium!.copyWith(
      fontSize: 10.fSize,
    ),
  );

  static get labelMediumYellow800 => GoogleFonts.lato(
    textStyle: theme.textTheme.labelMedium!.copyWith(
      color: appTheme.yellow800,
    ),
  );

  static get titleLargeOnPrimary => GoogleFonts.lato(
    textStyle: theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w700,
    ),
  );
}