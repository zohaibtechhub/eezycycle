import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/auth_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/services/api_service.dart';

/// Circular avatar that prefers a network photo, then falls back to the brand asset.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxFit fit;

  /// When true and [imageUrl] is null, reads [AuthController.avatarUrl].
  final bool useAuthAvatar;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.fit = BoxFit.cover,
    this.useAuthAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useAuthAvatar) {
      return Obx(() => _buildFace(_effectiveUrl()));
    }
    return _buildFace(_effectiveUrl());
  }

  String? _effectiveUrl() {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return imageUrl!.trim();
    }
    if (useAuthAvatar && Get.isRegistered<AuthController>()) {
      final url = Get.find<AuthController>().avatarUrl.value;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    }
    return null;
  }

  Widget _buildFace(String? raw) {
    final networkUrl =
        raw == null || raw.isEmpty ? '' : ApiClient().resolveMediaUrl(raw);

    final Widget child;
    if (networkUrl.isNotEmpty) {
      child = Image.network(
        networkUrl,
        fit: fit,
        width: size,
        height: size,
        errorBuilder: (_, _, _) => Image.asset(
          AppImages.womanAvatar,
          fit: fit,
          width: size,
          height: size,
        ),
      );
    } else {
      child = Image.asset(
        AppImages.womanAvatar,
        fit: fit,
        width: size,
        height: size,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(child: child),
    );
  }
}
