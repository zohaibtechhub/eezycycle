import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/api_service.dart';
import '../core/utils/short_message.dart';
import '../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString resetEmail = ''.obs;

  final ApiClient _api = ApiClient();

  void togglePasswordVisibility({required bool confirm}) {
    if (confirm) {
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
    } else {
      isPasswordVisible.value = !isPasswordVisible.value;
    }
  }

  Future<void> submitEmail() async {
    if (!(emailFormKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final email = emailController.text.trim();
      final response = await _api.post(ApiEndPoints.authForgotPassword, {
        'email': email,
      });
      ApiClient.unwrapData(response);
      resetEmail.value = email;
      otpController.clear();

      final message = (response is Map && response['message'] != null)
          ? response['message'].toString()
          : 'If an account exists for that email, we sent a reset code.';

      _showSuccess(message);
      Get.toNamed(AppPages.forgotPasswordOtp);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resetEmail.value.isEmpty) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _api.post(ApiEndPoints.authForgotPassword, {
        'email': resetEmail.value,
      });
      _showSuccess('A new code was sent if that email is registered.');
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitOtp() async {
    if (!(otpFormKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _api.post(ApiEndPoints.authVerifyResetOtp, {
        'email': resetEmail.value,
        'otp': otpController.text.trim(),
      });
      passwordController.clear();
      confirmPasswordController.clear();
      _showSuccess('Code verified. Choose a new password.');
      Get.toNamed(AppPages.forgotPasswordReset);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitNewPassword() async {
    if (!(resetFormKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _api.post(ApiEndPoints.authResetPassword, {
        'email': resetEmail.value,
        'otp': otpController.text.trim(),
        'password': passwordController.text,
      });
      _showSuccess('Password updated. Sign in with your new password.');
      emailController.clear();
      otpController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      Get.offNamedUntil(AppPages.login, (route) => false);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccess(String message) {
    final ctx = Get.context;
    if (ctx != null) ShortMessageUtils.showSuccess(ctx, message);
  }

  void _showError(Object e) {
    final ctx = Get.context;
    if (ctx == null) return;
    ShortMessageUtils.showError(
      ctx,
      e.toString().replaceFirst('Exception: ', ''),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
