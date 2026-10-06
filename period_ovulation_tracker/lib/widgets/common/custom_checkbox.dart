import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?)? onChanged;
  final Widget title;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      splashRadius: 0,
      titleAlignment: ListTileTitleAlignment.titleHeight,
      horizontalTitleGap: 3,
      title: title,
    );
  }
}
