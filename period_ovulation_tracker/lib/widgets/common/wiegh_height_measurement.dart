import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class WeightHeightMeasurement extends StatelessWidget {
  const WeightHeightMeasurement({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Obx(() {
      final isHeight = controller.measurementSubStep.value == 0;
      final isMetric = controller.isMetric.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIndicator(
            context,
            activeIndex: controller.measurementSubStep.value,
          ),
          SizedBox(height: AppSize.h2),
          TextWidget(
            title: isHeight ? 'How tall are you?' : 'How much do you weigh?',
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: AppSize.h1),
          TextWidget(
            title: isHeight
                ? 'This helps us personalize your fertility insights.'
                : 'This helps us provide more relevant insights.',
            fontSize: 15,
            textColor: context.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(height: AppSize.h2),
          _buildUnitToggle(context, controller: controller, isMetric: isMetric),
          SizedBox(height: AppSize.h10),
          _buildPicker(
            context,
            controller: controller,
            isHeight: isHeight,
            isMetric: isMetric,
          ),
        ],
      );
    });
  }

  Widget _buildIndicator(BuildContext context, {required int activeIndex}) {
    return Row(
      children: List.generate(2, (index) {
        final selected = activeIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 6),
          height: 4,
          width: selected ? 28 : 8,
          decoration: BoxDecoration(
            color: selected
                ? context.primaryColor
                : context.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  Widget _buildUnitToggle(
    BuildContext context, {
    required OnboardingController controller,
    required bool isMetric,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildUnitButton(
              context,
              title: 'Metric',
              selected: isMetric,
              onTap: () => controller.setMetric(true),
            ),
          ),
          Expanded(
            child: _buildUnitButton(
              context,
              title: 'Imperial',
              selected: !isMetric,
              onTap: () => controller.setMetric(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? context.primaryColor.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: TextWidget(
          title: title,
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          textColor: selected
              ? context.primaryColor
              : context.onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildPicker(
    BuildContext context, {
    required OnboardingController controller,
    required bool isHeight,
    required bool isMetric,
  }) {
    late final List<double> values;
    late final double selectedValue;

    if (isHeight) {
      if (isMetric) {
        values = List.generate(121, (index) => 120.0 + index);
        selectedValue = controller.heightCm.value.clamp(120.0, 240.0);
      } else {
        values = List.generate(48, (index) => 48.0 + index);
        selectedValue = (controller.heightCm.value / 2.54)
            .roundToDouble()
            .clamp(48.0, 95.0);
      }
    } else {
      if (isMetric) {
        values = List.generate(121, (index) => 30.0 + index);
        selectedValue = controller.weightKg.value.clamp(30.0, 150.0);
      } else {
        values = List.generate(265, (index) => 66.0 + index);
        selectedValue = (controller.weightKg.value * 2.20462)
            .roundToDouble()
            .clamp(66.0, 330.0);
      }
    }

    return _SnapPicker(
      key: ValueKey('${isHeight ? "height" : "weight"}_$isMetric'),
      values: values,
      selectedValue: selectedValue,
      labelBuilder: (value) => isHeight
          ? _heightLabel(value, isMetric)
          : _weightLabel(value, isMetric),
      onChanged: (value) {
        if (isHeight) {
          final heightCm = isMetric ? value : (value * 2.54).roundToDouble();
          controller.setHeight(heightCm);
        } else {
          final weightKg = isMetric ? value : (value / 2.20462).roundToDouble();
          controller.setWeight(weightKg);
        }
      },
    );
  }

  String _heightLabel(double value, bool isMetric) {
    if (isMetric) return '${value.round()} cm';
    final totalInches = value.round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet' $inches\"";
  }

  String _weightLabel(double value, bool isMetric) {
    if (isMetric) return '${value.round()} kg';
    return '${value.round()} lb';
  }
}

class _SnapPicker extends StatefulWidget {
  final List<double> values;
  final double selectedValue;
  final String Function(double value) labelBuilder;
  final ValueChanged<double> onChanged;

  const _SnapPicker({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  State<_SnapPicker> createState() => _SnapPickerState();
}

class _SnapPickerState extends State<_SnapPicker> {
  late FixedExtentScrollController controller;
  static const double itemHeight = 52;

  @override
  void initState() {
    super.initState();
    final index = widget.values.indexOf(widget.selectedValue);
    controller = FixedExtentScrollController(
      initialItem: index >= 0 ? index : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _SnapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      final index = widget.values.indexOf(widget.selectedValue);
      if (index >= 0 && controller.hasClients) {
        controller.animateToItem(
          index,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: itemHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: itemHeight,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 100,
            perspective: 0.00001,
            squeeze: 1,
            onSelectedItemChanged: (index) {
              widget.onChanged(widget.values[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, index) {
                final value = widget.values[index];
                final isSelected = value == widget.selectedValue;

                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 120),
                    style: TextStyle(
                      fontSize: isSelected ? 22 : 16,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? context.primaryColor
                          : context.onSurface.withValues(alpha: 0.35),
                    ),
                    child: Text(widget.labelBuilder(value)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
