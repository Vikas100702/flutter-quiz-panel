// lib/screens/auth/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/providers/user_data_provider.dart';
import 'package:quiz_panel/utils/app_strings.dart';
import 'package:quiz_panel/widgets/buttons/app_button.dart';
import 'package:quiz_panel/widgets/layout/responsive_layout.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isSending = false;
  bool _isChecking = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _cooldownSeconds = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isSending = true;
    });
    try {
      final authUser = ref.read(authStateProvider).value;
      if (authUser != null) {
        await ref.read(authRepositoryProvider).sendEmailVerification(authUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.resendEmailSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isChecking = true;
    });
    // authStateProvider (Firebase User) को रिफ्रेश करने के लिए कहें
    final authUser = ref.read(authStateProvider).value;
    await authUser?.reload();

    // userDataProvider (हमारे UserModel) को अमान्य करें
    // यह राउटर को फिर से जाँच करने के लिए ट्रिगर करेगा
    ref.invalidate(userDataProvider);
    ref.invalidate(authStateProvider);

    // एक छोटा विलंब दें ताकि प्रोवाइडर्स को रिफ्रेश होने का समय मिल सके
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).value;
    final bool canResend = _cooldownSeconds == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyEmailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logoutButton,
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: ResponsiveAuthLayout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.verifyEmailMessage,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authUser?.email ?? 'your email',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.checkYourInbox,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: AppStrings.refreshStatusButton,
                onPressed: _isChecking ? null : _refreshStatus,
                isLoading: _isChecking,
                type: AppButtonType.primary,
                icon: Icons.refresh,
              ),
              const SizedBox(height: 16),
              AppButton(
                text: canResend
                    ? AppStrings.resendEmailButton
                    : AppStrings.resendEmailCooldown
                    .replaceFirst('%s', _cooldownSeconds.toString()),
                onPressed: (_isSending || !canResend) ? null : _resendEmail,
                isLoading: _isSending,
                type: AppButtonType.outline,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}