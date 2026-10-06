import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/short_message.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/drawer/drawer_controller.dart';
import '../../routes/app_pages.dart';

class PregnancyActivationView extends StatefulWidget {
  const PregnancyActivationView({super.key});

  @override
  State<PregnancyActivationView> createState() =>
      _PregnancyActivationViewState();
}

class _PregnancyActivationViewState extends State<PregnancyActivationView> {
  DateTime? _clinicianEdd;
  bool _saving = false;

  String get _clinicianLabel {
    final d = _clinicianEdd;
    if (d == null) return 'Optional — add clinician / ultrasound due date';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'Clinician due date: ${d.year}-$mm-$dd';
  }

  Future<void> _pickClinicianDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clinicianEdd ?? now.add(const Duration(days: 180)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 300)),
      helpText: 'Clinician or ultrasound due date',
    );
    if (picked != null) {
      setState(() => _clinicianEdd = picked);
    }
  }

  Future<void> _activate() async {
    if (_saving) return;
    setState(() => _saving = true);
    final drawerController = Get.find<DrawerViewController>();
    String? clinicianEdd;
    if (_clinicianEdd != null) {
      final d = _clinicianEdd!;
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      clinicianEdd = '${d.year}-$mm-$dd';
    }
    await drawerController.activatePregnancyMode(clinicianEdd: clinicianEdd);
    if (!mounted) return;
    Get.offAllNamed(AppPages.mainBottomNavView);
    ShortMessageUtils.showSuccess(
      Get.context ?? context,
      "Activation successful.",
    );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: Lottie.asset(
                  AppImages.confeti,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const TextWidget(
                title: "Congratulations!",
                fontSize: 26,
                fontWeight: FontWeight.w800,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextWidget(
                  title:
                      "If you activate the pregnancy mode, a countdown to the birth of your baby will be shown instead of cycle predictions. You can use your last period estimate or a clinician/ultrasound due date.",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                  maxLines: 6,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _pickClinicianDate,
                child: Text(
                  _clinicianLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (_clinicianEdd != null)
                TextButton(
                  onPressed: () => setState(() => _clinicianEdd = null),
                  child: const Text(
                    'Clear clinician date (use LMP estimate)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              const TextWidget(
                title: "Activate pregnancy mode?",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _activate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _saving ? "…" : "ACTIVATE",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
