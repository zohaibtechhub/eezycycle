import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/common/onboarding_header.dart';
import 'package:period_ovulation_tracker/widgets/common/wiegh_height_measurement.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/cycle_calender_controller.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/onboarding/onboarding_step.dart';
import '../../widgets/common/yearly_calender.dart';
import '../../widgets/container/selectable_container.dart';
import '../../widgets/text/custom_rich_text.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: Obx(() {
          final step = controller.currentStep;
          final syncing = controller.isSyncing.value;

          // Fallback if no steps are present
          if (step == null) {
            return const Center(
              child: TextWidget(title: 'Onboarding completed'),
            );
          }

          final isInsightAnalyzing =
              step.type == OnboardingStepType.insight &&
              controller.isInsightAnalyzing.value;

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step.canSkip && !isInsightAnalyzing) _buildHeader(step),
                  Expanded(child: _buildBodyContent(context, step)),
                  _buildBottomActionBar(),
                ],
              ),
              if (syncing)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFFE85078),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // SECTION BUILDERS
  // ===========================================================================

  /// Header containing the back/skip buttons and the step progress indicator
  Widget _buildHeader(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: OnboardingHeader(
        onSkipTap: controller.skipStep,
        progress: step.showProgress ? controller.progress : null,
      ),
    );
  }

  /// Manages content layout routing: Full-bleed Calendar vs. Scrollable Content
  Widget _buildBodyContent(BuildContext context, OnboardingStep step) {
    if (step.type == OnboardingStepType.calendar) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomYearlyCalendar(
          year: DateTime.now().year,
          mode: CalendarMode.onboarding,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: _buildStepContent(context, step),
    );
  }

  /// Bottom sticky continue button validated by `canContinueStep`
  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Obx(
        () => CustomButton(
          title: controller.isSyncing.value ? 'Saving…' : 'Continue',
          isLoading: controller.isSyncing.value,
          isDisabled:
              !controller.canContinueStep || controller.isSyncing.value,
          onTap: controller.nextStep,
        ),
      ),
    );
  }

  // ===========================================================================
  // STEP ROUTER & COMPONENT BUILDERS
  // ===========================================================================

  /// Resolves the specific widget to display based on the `OnboardingStepType`
  Widget _buildStepContent(BuildContext context, OnboardingStep step) {
    switch (step.type) {
      case OnboardingStepType.question:
        return _buildQuestion(context, step);

      case OnboardingStepType.measurement:
        return const WeightHeightMeasurement();

      case OnboardingStepType.calendar:
        return const SizedBox.shrink(); // Handled directly inside Expanded view

      case OnboardingStepType.socialProof:
      case OnboardingStepType.education:
      case OnboardingStepType.contentWarning:
      case OnboardingStepType.sectionIntro:
      case OnboardingStepType.reminder:
      case OnboardingStepType.testimonial:
      case OnboardingStepType.insight:
        return _buildInfoContent(context, step);
    }
  }

  /// Builds informational and educational card screens (Icon/Image + Rich Titles)
  Widget _buildInfoContent(BuildContext context, OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Optional Circular Icon
        if (step.icon != null) ...[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(step.icon, size: 40, color: context.primaryColor),
          ),
          SizedBox(height: AppSize.h3),
        ],

        // Optional Main Banner Image
        if (step.image != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              step.image!,
              height: AppSize.getHeight(30),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: AppSize.h3),
        ],

        // Title: Custom Rich Text or Standard Typography
        if (step.richTitle != null)
          _buildRichTitle(context, step)
        else if (step.title != null)
          TextWidget(
            title: step.title!,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),

        SizedBox(height: AppSize.h3),

        // Description: Custom Rich Text or Standard Body Text
        if (step.richDescription != null)
          CustomRichText(
            firstPart: step.richDescription!.firstPart,
            highlightedPart: step.richDescription!.highlightedPart,
            middlePart: step.richDescription!.middlePart,
            secondHighlightedPart: step.richDescription!.secondHighlightedPart,
            textAlign: TextAlign.center,
          )
        else if (step.description != null)
          TextWidget(
            title: step.description!,
            fontSize: 15,
            textColor: context.onSurface.withValues(alpha: 0.65),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  /// Builds single and multiple-choice question step options
  Widget _buildQuestion(BuildContext context, OnboardingStep step) {
    if (step.selectionType == OnboardingSelectionType.none) {
      return _buildPlaceholder(step);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (step.title != null) ...[
          TextWidget(
            title: step.title!,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: AppSize.h1),
        ],

        if (step.description != null) ...[
          TextWidget(
            title: step.description!,
            fontSize: 15,
            textColor: context.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: AppSize.h2),
        ],

        // Option Choices — each row Obx so selection updates immediately
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: step.options.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSize.h2),
          itemBuilder: (context, index) {
            final option = step.options[index];

            return Obx(
              () => SelectableContainer(
                title: option.title,
                description: option.description,
                isSelected: controller.isOptionSelected(option.id),
                showCheckIcon:
                    step.selectionType == OnboardingSelectionType.multiple,
                onTap: () => controller.selectOption(option),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Custom rich styled title for educational & proof steps
  Widget _buildRichTitle(BuildContext context, OnboardingStep step) {
    return CustomRichText(
      firstPart: step.richTitle!.firstPart,
      highlightedPart: step.richTitle!.highlightedPart,
      middlePart: step.richTitle!.middlePart,
      secondHighlightedPart: step.richTitle!.secondHighlightedPart,
      textAlign: TextAlign.center,
      firstPartStyle: TextStyle(
        color: context.onSurface,
        fontSize: 27,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      highlightedPartStyle: TextStyle(
        color: context.primaryColor,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      middlePartStyle: TextStyle(
        color: context.onSurface,
        fontSize: 27,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      secondHighlightedPartStyle: TextStyle(
        color: context.primaryColor,
        fontSize: 27,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  /// Debug fallback UI for unimplemented question types
  Widget _buildPlaceholder(OnboardingStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const TextWidget(
            title: 'UI will be displayed here',
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          TextWidget(title: 'Type: ${step.type.name}', textColor: Colors.grey),
        ],
      ),
    );
  }
}
