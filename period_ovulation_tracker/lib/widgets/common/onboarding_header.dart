import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/widgets/button/text_button.dart';

class OnboardingHeader extends StatelessWidget {
  final VoidCallback onSkipTap;
  final String skipText;
  final double? progress;

  const OnboardingHeader({
    super.key,
    required this.onSkipTap,
    this.skipText = "Skip",
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [CustomTextButton(title: skipText, onTap: onSkipTap)],
        ),

        if (progress != null) ...[
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress!.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
