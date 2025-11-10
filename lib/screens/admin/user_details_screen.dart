// lib/screens/admin/user_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/repositories/admin_repository.dart';
import 'package:quiz_panel/utils/constants.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    // Screen load hote hi extra profile data fetch karein
    _profileDataFuture = ref
        .read(adminRepositoryProvider)
        .getRoleProfileData(widget.user.uid, widget.user.role);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName),
        // AppBar ka color user role ke hisaab se
        backgroundColor: user.role == UserRoles.superAdmin
            ? AppColors.error
            : (user.role == UserRoles.admin
            ? AppColors.warning
            : AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 1: Main User Data (from 'users' collection)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core User Data',
                          style: AppTextStyles.titleLarge,
                        ),
                        const Divider(height: 20),
                        _buildDetailRow('Name', user.displayName),
                        _buildDetailRow('Email', user.email),
                        _buildDetailRow('UID', user.uid),
                        _buildDetailRow('Role', user.role),
                        _buildDetailRow('Status', user.status),
                        _buildDetailRow('Is Active', user.isActive.toString()),
                        _buildDetailRow('Phone', user.phoneNumber ?? 'N/A'),
                        _buildDetailRow('Photo URL', user.photoURL ?? 'N/A'),
                        _buildDetailRow('Created At',
                            user.createdAt.toDate().toLocal().toString()),
                        _buildDetailRow(
                            'Approved By', user.approvedBy ?? 'N/A'),
                        _buildDetailRow(
                            'Auth Providers', user.authProviders.join(', ')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Card 2: Role-Specific Profile Data
                if (user.role == UserRoles.student ||
                    user.role == UserRoles.teacher)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.role.capitalize()} Profile Data',
                            style: AppTextStyles.titleLarge,
                          ),
                          const Divider(height: 20),
                          // FutureBuilder profile data load karega
                          _buildProfileData(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget: Profile data ke liye FutureBuilder
  Widget _buildProfileData() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading profile: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No additional profile data found.'));
        }

        final profileData = snapshot.data!;
        // Map mein jitni bhi entries hain, un sab ke liye rows banayein
        return Column(
          children: profileData.entries.map((entry) {
            return _buildDetailRow(
              entry.key.capitalize(), // e.g., 'studentId' -> 'Studentid'
              entry.value?.toString() ?? 'N/A',
            );
          }).toList(),
        );
      },
    );
  }

  // Helper widget: Ek detail row banane ke liye
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: AppTextStyles.titleSmall
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// String ko capitalize karne ke liye ek chota helper
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}