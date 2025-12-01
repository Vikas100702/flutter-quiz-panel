// lib/screens/auth/otp_verify_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (OtpVerifyScreen):**
/// This screen is the second step in the Phone Login process. It handles the verification
/// of the One-Time Password (OTP) sent to the user's mobile number.
///
/// **How it helps:**
/// It proves the user physically possesses the phone number, completing the secure sign-in process
/// using Firebase Phone Authentication.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  // **Required Data:**
  // This unique ID is received in the first step (PhoneLoginScreen) after Firebase successfully sends the SMS.
  final String verificationId;
  const OtpVerifyScreen({super.key, required this.verificationId});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  // **State Variables:**
  final _otpController =
      TextEditingController(); // Captures the 6-digit code entered by the user.
  final _formKey = GlobalKey<FormState>(); // Used to validate the input field.
  bool _isLoading = false; // Controls the loading spinner on the button.

  // --- Logic: Verify OTP and Sign In ---

  /// **What is this function doing?**
  /// It takes the user-entered SMS code and combines it with the `verificationId`
  /// to authenticate the user with Firebase.
  ///
  /// **How it works:**
  /// 1. **Validation:** Checks if the form is valid (i.e., exactly 6 digits entered).
  /// 2. **Loading:** Sets `_isLoading = true` to show the spinner.
  /// 3. **API Call:** Calls `authRepository.signInWithOtp` with the `verificationId` and `smsCode`.
  /// 4. **Success:** If successful, the user is authenticated. We navigate to the root path (`/`),
  ///    and the `AppRouterProvider` handles the final redirect (e.g., to `/register/phone` for new users
  ///    or directly to the dashboard for existing users).
  /// 5. **Failure:** Shows an error message (e.g., "Invalid OTP code").
  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate())
      return; // Stop if OTP is invalid length.

    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final smsCode = _otpController.text.trim();

    try {
      // Step 1: Attempt to sign in with the OTP credential.
      await authRepo.signInWithOtp(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      // Step 2: Authentication successful! Redirect to Splash/Wrapper for flow control.
      if (mounted) {
        context.go(AppRoutePaths.splash);
      }
    } catch (e) {
      // Step 3: Handle error (e.g., wrong code, session expired).
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      // **Responsive Layout:** Centers the OTP card on the screen.
      body: ResponsiveAuthLayout(
        child: Form(
          key: _formKey, // Attach Form Key for validation.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Icon and Text
              Icon(Icons.password, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to your phone',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // OTP Input Field
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: '6-digit OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6, // Enforce max length for OTP format.
                validator: (value) {
                  // Ensure exactly 6 digits are entered.
                  if (value == null || value.length != 6) {
                    return 'Please enter a valid 6-digit OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Verification Button
              AppButton(
                text: 'Verify & Sign In',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
                type: AppButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
