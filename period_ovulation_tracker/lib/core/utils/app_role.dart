import '../utils/pref_util.dart';
import '../../routes/app_pages.dart';

/// Resolves post-auth / post-onboarding shell from profile role.
class AppRole {
  AppRole._();

  /// Partner shell only after a real invite link (code stored) — never just
  /// because they tapped "I have a partner code" on Usage.
  static bool isPartnerFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return PrefUtil.getBool(PrefUtil.isPartnerMode);
    final usage = profile['usage_path']?.toString();
    final mode = profile['experience_mode']?.toString();
    if (usage != 'partner' && mode != 'partner') return false;

    final code = profile['partner_code_entered']?.toString();
    return code != null && code.isNotEmpty;
  }

  /// Chose partner path but has not successfully linked a code yet.
  static bool needsPartnerCode(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    final usage = profile['usage_path']?.toString();
    if (usage != 'partner') return false;
    final code = profile['partner_code_entered']?.toString();
    return code == null || code.isEmpty;
  }

  static Future<void> persistFromProfile(Map<String, dynamic>? profile) async {
    final isPartner = isPartnerFromProfile(profile);
    await PrefUtil.setBool(PrefUtil.isPartnerMode, isPartner);
    if (isPartner) {
      await PrefUtil.setString(PrefUtil.experienceMode, 'partner');
    } else {
      final mode = profile?['experience_mode']?.toString();
      if (mode != null && mode.isNotEmpty && mode != 'partner') {
        await PrefUtil.setString(PrefUtil.experienceMode, mode);
      }
    }
  }

  static String homeRoute({bool? isPartner}) {
    final partner = isPartner ?? PrefUtil.getBool(PrefUtil.isPartnerMode);
    return partner ? AppPages.partnerHome : AppPages.mainBottomNavView;
  }
}
