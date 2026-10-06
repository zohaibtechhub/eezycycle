import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';

import '../common/custom_container.dart';
import '../text/text_widget.dart';

class AttentionContainer extends StatelessWidget {
  final String title;
  final String description;

  const AttentionContainer({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.warning,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: context.onPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: title,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  title: description,
                  fontSize: 13,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
