// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **Why we used this class (UserModel):**
/// This class acts as the "Identity Card" for every user in our system.
/// Whether it's a Student, Teacher, or Admin, we store their essential details here.
///
/// **How it helps:**
/// It creates a standard format for user data. Instead of guessing if a user has a 'name'
/// or 'displayName' field in different parts of the app, we always use this class.
class UserModel {
  // **Identity Fields:**
  final String uid; // The unique User ID provided by Firebase Authentication.
  final String displayName; // The name shown in the app (e.g., "John Doe").
  final String email; // The user's email address.
  final String? phoneNumber; // Optional phone number (nullable because not everyone registers with phone).
  final String? photoURL; // Optional profile picture URL.

  // **Role & Access Control:**
  final String role; // Defines what the user can do (e.g., 'student', 'teacher', 'admin').
  final String status; // Current account state (e.g., 'pending_approval', 'approved').
  final bool isActive; // A switch to quickly disable/ban a user without deleting them.
  final String? approvedBy; // If the user is a teacher, this stores the UID of the Admin who approved them.

  // **Metadata:**
  final List<String> authProviders; // How did they log in? (e.g., ['password', 'google.com']).
  final Timestamp createdAt; // When did they join?

  // **Constructor:**
  // Creates a complete User profile object.
  UserModel({
    required this.uid,
    required this.role,
    required this.status,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoURL,
    required this.authProviders,
    required this.createdAt,
    this.approvedBy,
    required this.isActive,
  });

  /// **What is this Factory Constructor? (fromFirestore)**
  /// This takes a snapshot from the database and turns it into a `UserModel`.
  ///
  /// **How it works:**
  /// 1. It grabs the document ID as the `uid`.
  /// 2. It reads the data fields.
  /// 3. It uses `DefaultValues` (from constants.dart) if critical fields like role or status are missing.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    // Safely cast the document data to a Map. If data is null, use an empty map.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      // The UID is the document's key (ID), not a field inside the data.
      uid: doc.id,

      // Use safe defaults if data is missing to prevent crashes.
      role: data['role'] ?? DefaultValues.defaultRole,
      status: data['status'] ?? DefaultValues.defaultStatus,
      displayName: data['displayName'] ?? DefaultValues.defaultDisplayName,
      email: data['email'] ?? '',

      // Nullable fields don't need defaults.
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],

      // Ensure authProviders is a List of Strings.
      authProviders: List<String>.from(data['authProviders'] ?? []),

      // If creation time is missing, assume it's happening right now.
      createdAt: data['createdAt'] ?? Timestamp.now(),
      approvedBy: data['approvedBy'],

      // Default to true (active) if not specified.
      isActive: data['isActive'] ?? true,
    );
  }

  /// **What is this method? (toMap)**
  /// Converts the user profile into a Map so it can be saved to Firestore.
  ///
  /// **Why do we need it?**
  /// Dart objects cannot be directly stored in the database. They must be serialized into JSON-like Maps.
  Map<String, dynamic> toMap() {
    return {
      // Note: We don't save 'uid' inside the map because it is the document ID itself.
      'role': role,
      'status': status,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'authProviders': authProviders,
      'createdAt': createdAt,
      'approvedBy': approvedBy,
      'isActive': isActive,
    };
  }
}