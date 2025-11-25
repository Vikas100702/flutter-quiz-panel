// lib/screens/auth/otp_verify_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String verificationId;
  const OtpVerifyScreen({super.key, required this.verificationId});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final smsCode = _otpController.text.trim();

    try {
      // OTP verify karke sign in karein
      await authRepo.signInWithOtp(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      // Sign in safal!
      // Router provider ab redirect logic ka dhyan rakhega.
      // Hum seedha / par bhej denge, aur router provider check karega
      // ki user naya hai ya purana.
      if (mounted) {
        context.go(AppRoutePaths.splash);
      }
    } catch (e) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: ResponsiveAuthLayout(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Please enter a valid 6-digit OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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