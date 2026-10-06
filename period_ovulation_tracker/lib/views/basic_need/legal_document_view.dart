import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

enum LegalDocType { privacyPolicy, termsOfUse }

class LegalDocumentView extends StatelessWidget {
  final LegalDocType type;

  const LegalDocumentView({super.key, required this.type});

  bool get isPrivacy => type == LegalDocType.privacyPolicy;
  String get title => isPrivacy ? "Privacy Policy" : "Terms of Use";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.onSurface,
            ),
          ),
        ),
        title: TextWidget(
          title: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: context.onSurface,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badge & Last Updated
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPrivacy
                          ? Icons.shield_outlined
                          : Icons.description_outlined,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          title: isPrivacy
                              ? "Your health data is safe & encrypted"
                              : "Guidelines for app usage & services",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          textColor: context.onSurface,
                        ),
                        const SizedBox(height: 2),
                        const TextWidget(
                          title: "Last updated: August 2026",
                          fontSize: 11,
                          textColor: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Document Content
            if (isPrivacy)
              ..._buildPrivacySections(context)
            else
              ..._buildTermsSections(context),

            const SizedBox(height: 24),

            // Contact / Inquiries Tile
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: context.surface,
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(
            //       color: context.primaryColor.withValues(alpha: 0.08),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.mail_outline_rounded,
            //         color: context.primaryColor,
            //         size: 22,
            //       ),
            //       const SizedBox(width: 12),
            //       const Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             TextWidget(
            //               title: "Questions about your data?",
            //               fontSize: 13,
            //               fontWeight: FontWeight.w600,
            //               textColor: AppColors.textPrimary,
            //             ),
            //             SizedBox(height: 2),
            //             TextWidget(
            //               title: "privacy@periodtracker.app",
            //               fontSize: 12,
            //               textColor: AppColors.textSecondary,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrivacySections(BuildContext context) {
    return [
      _buildSection(
        context,
        number: "1",
        title: "Information We Collect",
        body:
            "We collect cycle logs, symptom records, and dates solely to generate accurate predictions and insights. We do not sell your personal, health, or biometric data to third parties.",
      ),
      _buildSection(
        context,
        number: "2",
        title: "Partner Sharing Mode",
        body:
            "When linked via Partner Code, your partner receives read-only high-level cycle predictions and relationship advice. Specific intimate symptom notes and medical test logs remain strictly private to your device.",
      ),
      _buildSection(
        context,
        number: "3",
        title: "Data Encryption & Security",
        body:
            "All transmitted health data uses TLS 1.3 protocol and AES-256 encryption at rest. You have the right to request full export or permanent deletion of your account and records at any time.",
      ),
      _buildSection(
        context,
        number: "4",
        title: "Consent & Health Disclaimers",
        body:
            "By logging health information, you give explicit consent for algorithmic prediction calculation. This information is designed for lifestyle tracking and does not replace medical advice.",
      ),
    ];
  }

  List<Widget> _buildTermsSections(BuildContext context) {
    return [
      _buildSection(
        context,
        number: "1",
        title: "Medical & Health Disclaimer",
        body:
            "This application is an educational and personal tracking tool. It is not a certified contraceptive method or diagnostic medical device. Always consult a qualified healthcare provider for reproductive health decisions.",
      ),
      _buildSection(
        context,
        number: "2",
        title: "Account & Shared Codes",
        body:
            "You are responsible for maintaining the confidentiality of any partner linking codes generated. You may revoke shared access at any time through the app settings.",
      ),
      _buildSection(
        context,
        number: "3",
        title: "Acceptable Use",
        body:
            "You agree not to reverse engineer, copy, or misuse the application content, prediction algorithms, or daily relationship articles.",
      ),
      _buildSection(
        context,
        number: "4",
        title: "Changes to Service",
        body:
            "We reserve the right to modify, enhance, or discontinue features of the app with notice provided via app updates or notifications.",
      ),
    ];
  }

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: TextWidget(
                    title: number,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    textColor: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextWidget(
                  title: title,
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
