// lib/screens/auth/phone_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

/// **Why we used this Widget (PhoneLoginScreen):**
/// This screen is the first step for users opting to log in or register using their mobile phone number
/// instead of email/password.
///
/// **How it helps:**
/// It collects the phone number and initiates the OTP request process with Firebase Phone Authentication.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  // **State Variables:**
  final _phoneController = TextEditingController(); // Captures the 10-digit number.
  final _formKey = GlobalKey<FormState>(); // Used for input validation.
  bool _isLoading = false; // Controls the loading spinner.

  // --- Logic: Send OTP ---

  /// **What is this function doing?**
  /// It asks Firebase to send an SMS verification code (OTP) to the entered number.
  ///
  /// **How it works (Asynchronous Callbacks):**
  /// 1. **Validation & Loading:** Validates the input and sets `_isLoading = true`.
  /// 2. **Format Number:** Prepends the country code (`+91` for India) to create the full phone number for Firebase.
  /// 3. **API Call:** Calls `authRepository.verifyPhoneNumber`. This method uses asynchronous callbacks:
  ///    - `onCodeSent`: If the SMS is successfully sent, we stop loading and navigate to the `OtpVerifyScreen`, passing the `verificationId`.
  ///    - `onVerificationFailed`: If the number is invalid or another error occurs, we show a SnackBar.
  ///    - `onVerificationCompleted`: Handled by Firebase for instant verification (auto-retrieval).
  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return; // Stop if input is invalid.

    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    // **Important:** Hardcoding +91 for India. This should be made dynamic in a fully international app.
    final fullPhoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await authRepo.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        // **Callback 1: SMS Sent Successfully**
        onCodeSent: (verificationId, resendToken) {
          // Stop loading and prepare to move to the next screen.
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            // Pass the crucial verificationId to the OTP screen for the next step.
            context.pushNamed(AppRouteNames.otpVerify, extra: verificationId);
          }
        },

        // **Callback 2: Verification Failed**
        onVerificationFailed: (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification Failed: ${e.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },

        // **Callback 3: Auto Verification Completed**
        onVerificationCompleted: (credential) {
          // This path is for devices that can instantly read the SMS code.
          // Note: While auto-completed, the user's registration details still need checking
          // by the AppRouterProvider (which will redirect to phone_register_details if they are new).
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      // General failure (e.g., repository error, network timeout).
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Phone')),
      body: ResponsiveAuthLayout(
        child: Form(
          key: _formKey, // Attach Form Key for validation.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Icon and Text
              Icon(Icons.phone_android, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Enter Your Phone Number',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We will send you a one-time password (OTP)',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Phone Number Input Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '10-digit Mobile Number',
                  prefixText: '+91 ', // Visual hint of the country code.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Enforce validation for a standard 10-digit mobile number.
                  if (value == null || value.length != 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Button
              AppButton(
                text: 'Send OTP',
                onPressed: _isLoading ? null : _sendOtp,
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