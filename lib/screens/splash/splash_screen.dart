import 'package:flutter/material.dart';

// This is a "dumb" screen. It only shows a loading indicator.
// The actual routing logic is now handled by GoRouter's redirect.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}