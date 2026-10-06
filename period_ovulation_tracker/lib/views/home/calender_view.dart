import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';
import 'package:period_ovulation_tracker/widgets/common/yearly_calender.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/cycle_calender_controller.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  late final bool _isPartner;
  late final CalendarMode _mode;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _isPartner = PrefUtil.getBool(PrefUtil.isPartnerMode);
    _mode = _isPartner ? CalendarMode.partner : CalendarMode.tracker;
    _tag = CycleCalendarController.tagFor(_mode);
  }

  CycleCalendarController? get _ctrlOrNull {
    if (!Get.isRegistered<CycleCalendarController>(tag: _tag)) return null;
    return Get.find<CycleCalendarController>(tag: _tag);
  }

  Future<void> _handleBack() async {
    final ctrl = _ctrlOrNull;
    if (_isPartner || ctrl == null || !ctrl.hasUnsavedChanges.value) {
      Get.back();
      return;
    }
    await _showUnsavedWarning();
  }

  Future<void> _logAndExit() async {
    final ctrl = _ctrlOrNull;
    if (ctrl == null) {
      Get.back();
      return;
    }
    if (!ctrl.hasUnsavedChanges.value) {
      Get.back();
      return;
    }
    final ok = await ctrl.logPeriods();
    if (!mounted) return;
    if (ok) {
      Get.back();
    } else {
      Get.snackbar(
        'Couldn’t log',
        'Check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _showUnsavedWarning() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_calendar_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const TextWidget(
                title: 'Unsaved period changes',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              const TextWidget(
                title:
                    'You’ve updated period days that haven’t been logged yet. Log them before leaving?',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await _logAndExit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Log'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const TextWidget(
                  title: 'Keep editing',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isPartner,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: context.primaryColor,
            ),
            onPressed: _handleBack,
          ),
          title: TextWidget(
            title: _isPartner ? "Her Cycle" : "Cycle",
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          actions: [
            if (!_isPartner)
              Obx(() {
                final ctrl = _ctrlOrNull;
                final dirty = ctrl?.hasUnsavedChanges.value ?? false;
                final saving = ctrl?.isSaving.value ?? false;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: (!dirty || saving) ? null : _logAndExit,
                    child: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextWidget(
                            title: 'Log',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            textColor: dirty
                                ? context.primaryColor
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.45),
                          ),
                  ),
                );
              }),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(
                        color: AppColors.period,
                        label: _isPartner ? "Period" : "Past Period",
                        isSolid: true,
                      ),
                      _buildLegendItem(
                        color: AppColors.period.withValues(alpha: 0.5),
                        label: "Predicted period",
                        isSolid: false,
                      ),
                      if (_isPartner)
                        _buildLegendItem(
                          color: AppColors.fertility,
                          label: "Fertile",
                          isSolid: true,
                        ),
                    ],
                  ),
                ),
              ),
              if (_isPartner)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: TextWidget(
                    title: 'Read-only view — you can’t edit her period days.',
                    fontSize: 12,
                    textColor: AppColors.textSecondary,
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    CustomYearlyCalendar(
                      year: DateTime.now().year,
                      mode: _mode,
                    ),
                    Obx(() {
                      if (!Get.isRegistered<CycleCalendarController>(
                        tag: _tag,
                      )) {
                        return const SizedBox.shrink();
                      }
                      final ctrl =
                          Get.find<CycleCalendarController>(tag: _tag);
                      if (ctrl.isLoading.value) {
                        return const Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        );
                      }
                      if (ctrl.isSaving.value && !_isPartner) {
                        return Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.06,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  TextWidget(
                                    title: 'Logging…',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isSolid,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isSolid ? color : color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: isSolid ? null : Border.all(color: color, width: 1.5),
          ),
          child: isSolid
              ? const Icon(Icons.check, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        TextWidget(
          title: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }
}
