// lib/screens/auth/phone_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    // India ke liye +91 add karein. Aap ise dynamic bana sakte hain.
    final fullPhoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await authRepo.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLoading = false;
          });
          // User ko OTP screen par bhej de
          context.pushNamed(AppRouteNames.otpVerify, extra: verificationId);
        },
        onVerificationFailed: (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification Failed: ${e.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        onVerificationCompleted: (credential) {
          // Yeh auto-retrieval hai, seedha sign in karein
          setState(() {
            _isLoading = false;
          });
          // Note: Auto-retrieval ke baad bhi user registration check karna hoga.
          // Abhi ke liye, hum onCodeSent par focus kar rahe hain.
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Phone')),
      body: ResponsiveAuthLayout(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              // Simple text field for phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '10-digit Mobile Number',
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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