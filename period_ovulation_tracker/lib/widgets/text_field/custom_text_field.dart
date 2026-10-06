import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';
import '../image/custom_svg.dart';
import '../text/text_widget.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? assetName;
  final Color? hintColor;
  final VoidCallback? onSuffixIconClick;
  final String labelText;
  final String? imagePath;
  final bool isPhoneNumber;
  final bool obscureText;
  final bool readOnly;
  final bool isDropdown;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final int maxLine;
  final Color? iconColor;
  final double focusBorderWidth;
  final double unFocusBorderWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final void Function(String?)? onDropdownChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
    this.assetName,
    this.onSuffixIconClick,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.hintColor,
    this.maxLine = 1,
    this.fontSize = 15,
    this.validator,
    this.focusBorderWidth = 1.5,
    this.unFocusBorderWidth = 1,
    this.isPhoneNumber = false,
    this.horizontalPadding = 16,
    this.verticalPadding = 15,
    this.imagePath,
    this.textInputType = TextInputType.text,
    this.isDropdown = false,
    this.dropdownItems,
    this.dropdownValue,
    this.onDropdownChanged,
    this.iconColor,
  });

  InputBorder customInputBorder(
    BuildContext context,
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color hintClr =
        hintColor ?? context.onSurface.withValues(alpha: 0.55);

    final Color iconClr =
        iconColor ?? context.onSurface.withValues(alpha: 0.65);

    final Color enabledBorderColor = context.onSurface.withValues(alpha: 0.15);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: context.surface,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: fontSize, color: hintClr),
      enabledBorder: customInputBorder(
        context,
        enabledBorderColor,
        width: unFocusBorderWidth,
      ),
      focusedBorder: customInputBorder(
        context,
        context.primaryColor,
        width: focusBorderWidth,
      ),
      errorBorder: customInputBorder(
        context,
        context.error,
        width: focusBorderWidth,
      ),
      focusedErrorBorder: customInputBorder(
        context,
        context.error,
        width: focusBorderWidth,
      ),
      errorMaxLines: 2,
      errorStyle: TextStyle(color: context.error, fontSize: 12, height: 1.2),
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      prefixIcon: imagePath != null
          ? IconButton(
              onPressed: () {},
              icon: CustomSvgIcon(
                assetName: imagePath!,
                width: 18,
                height: 18,
                color: iconClr,
              ),
            )
          : isPhoneNumber
          ? Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    title: '+92',
                    textColor: context.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 26,
                    color: context.onSurface.withValues(alpha: 0.2),
                  ),
                ],
              ),
            )
          : null,
      suffixIcon: assetName != null
          ? IconButton(
              onPressed: onSuffixIconClick,
              icon: CustomSvgIcon(assetName: assetName!, color: iconClr),
            )
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) ...[
          TextWidget(
            title: labelText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            textColor: context.onSurface,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
        ],
        isDropdown
            ? DropdownButtonFormField<String>(
                initialValue: dropdownValue,
                items:
                    dropdownItems
                        ?.map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: fontSize,
                                color: context.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList() ??
                    [],
                onChanged: onDropdownChanged,
                decoration: inputDecoration,
                dropdownColor: context.surface,
                iconEnabledColor: iconClr,
              )
            : TextFormField(
                onTap: onTap,
                readOnly: readOnly,
                keyboardType: textInputType,
                maxLines: maxLine,
                controller: controller,
                obscureText: obscureText,
                onChanged: onChanged,
                validator: validator,
                style: TextStyle(fontSize: fontSize, color: context.onSurface),
                cursorColor: context.primaryColor,
                decoration: inputDecoration,
              ),
      ],
    );
  }
}
