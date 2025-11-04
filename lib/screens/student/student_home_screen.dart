import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/providers/auth_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Call the signOut function from our repository
              ref.read(authRepositoryProvider).signOut();
              // The AuthWrapper (in the next file) will automatically
              // detect this change and send the user to the LoginScreen.
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Logged-in User!'),
      ),
    );
  }
}