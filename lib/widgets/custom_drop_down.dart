import 'package:flutter/material.dart';
import '../core/app_export.dart';

class CustomDropDown extends StatelessWidget {
  CustomDropDown({
    Key? key,
    this.alignment,
    this.width,
    this.focusNode,
    this.icon,
    this.autofocus = true,
    this.textStyle,
    this.items,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = false,  // Set filled to false by default
    this.validator,
    this.onChanged,
  }) : super(key: key);

  final Alignment? alignment;
  final double? width;
  final FocusNode? focusNode;
  final Widget? icon;
  final bool? autofocus;
  final TextStyle? textStyle;
  final List<String>? items;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? prefix;
  final BoxConstraints? prefixConstraints;
  final Widget? suffix;
  final BoxConstraints? suffixConstraints;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Color? fillColor;
  final bool? filled;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: dropDownWidget,
    )
        : dropDownWidget;
  }

  Widget get dropDownWidget => SizedBox(
    width: width ?? double.maxFinite,
    child: DropdownButtonFormField(
      isDense: true, // Ensure consistent item height
      isExpanded: true, // Ensures the dropdown takes full width
      hint: Text(
        hintText ?? "",
        style: CustomTextStyles.bodySmallOnPrimary.copyWith(color: Colors.black),
        textAlign: TextAlign.center, // Aligns hint to the center
      ),
      items: items?.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: CustomTextStyles.bodySmallOnPrimary.copyWith(color: Colors.black),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.0, // Horizontal padding
          vertical: 16.0,   // Vertical padding to adjust centering
        ),
      ),
      onChanged: (value) {
        onChanged!(value.toString());
      },
    )
  );

  InputDecoration get decoration => InputDecoration(
    hintText: hintText ?? "",
    hintStyle: CustomTextStyles.bodySmallOnPrimary.copyWith(color: Colors.black),
    contentPadding: contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 5.h,
          vertical: 9.v,
        ),
    fillColor: fillColor,
    filled: filled,
    border: borderDecoration ?? OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.h),
      borderSide: BorderSide(color: Color.fromRGBO(33, 156, 144, 1)), // Set the color of the border
    ),
    enabledBorder: borderDecoration ?? OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.h),
      borderSide: BorderSide(color: Color.fromRGBO(33, 156, 144, 1)), // Set the color of the enabled border
    ),
    focusedBorder: borderDecoration ?? OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.h),
      borderSide: BorderSide(color: Color.fromRGBO(33, 156, 144, 1)), // Set the color of the focused border
    ),

  );
}

