import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_suggestion_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_suggestion.dart';

/// Compact one-tip banner above the bottom nav (pregnancy + cycle).
class PregnancySuggestionBanner extends StatelessWidget {
  const PregnancySuggestionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PregnancySuggestionController>()) {
      Get.put(PregnancySuggestionController(), permanent: true);
    }
    final c = Get.find<PregnancySuggestionController>();

    return Obx(() {
      final tip = c.active.value;
      final show = c.visible.value && tip != null;
      return AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        offset: show ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 240),
          opacity: show ? 1 : 0,
          child: tip == null
              ? const SizedBox.shrink()
              : _TipCard(tip: tip, onClose: c.dismiss),
        ),
      );
    });
  }
}

class _TipCard extends StatelessWidget {
  final PregnancySuggestion tip;
  final VoidCallback onClose;

  const _TipCard({required this.tip, required this.onClose});

  ({IconData icon, Color bg, Color fg, String label}) get _style {
    switch (tip.category) {
      case 'food':
        return (
          icon: Icons.restaurant_rounded,
          bg: const Color(0xFFFFF0E6),
          fg: const Color(0xFFD97706),
          label: 'Food tip',
        );
      case 'exercise':
        return (
          icon: Icons.directions_walk_rounded,
          bg: const Color(0xFFE8F7F0),
          fg: AppColors.pregnancy,
          label: 'Move gently',
        );
      case 'rest':
        return (
          icon: Icons.hotel_rounded,
          bg: const Color(0xFFEEF2FC),
          fg: const Color(0xFF5B7CDA),
          label: 'Rest tip',
        );
      default:
        return (
          icon: Icons.spa_rounded,
          bg: const Color(0xFFF3E8FF),
          fg: const Color(0xFF9333EA),
          label: 'Wellness',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: s.fg.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tip.image != null && tip.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  tip.image!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: s.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(s.icon, color: s.fg, size: 22),
                  ),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icon, color: s.fg, size: 22),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tip.phase != null && tip.phase!.isNotEmpty
                        ? '${s.label} · ${tip.phase}'
                        : tip.week > 0
                            ? '${s.label} · Week ${tip.week}'
                            : s.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: s.fg,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tip.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
