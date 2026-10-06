import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/custom_container.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class SelectableContainer extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final bool showCheckIcon;
  final VoidCallback onTap;

  const SelectableContainer({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.description,
    this.showCheckIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        color: isSelected
            ? context.primaryColor
            : context.onPrimary.withValues(alpha: 0.7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title: title,
                      textColor: isSelected
                          ? context.onPrimary
                          : context.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      textAlign: TextAlign.left,
                    ),

                    if (isSelected && description != null) ...[
                      const SizedBox(height: 6),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1,
                              child: child,
                            ),
                          );
                        },
                        child: TextWidget(
                          key: ValueKey(description),
                          title: description!,
                          textColor: context.onPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (showCheckIcon && isSelected) ...[
              const SizedBox(width: 12),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.onPrimary,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: context.primaryColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
