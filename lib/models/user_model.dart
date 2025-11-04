import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_panel/utils/constants.dart';

class UserModel {
  final String uid;
  final String role;
  final String status;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? photoURL;
  final List<String> authProviders;
  final Timestamp createdAt;
  final String? approvedBy;
  final bool isActive;

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

  // A factory constructor to create a UserModel from a Firestore document.
  // This is a helper function to easily convert data.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    // 'data' will be null if the document doesn't exist.
    // We use 'doc.data() as Map<String, dynamic>' to safely get the data.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    return UserModel(
      // We use doc.id as the uid
      uid: doc.id,

      // We provide default values ('') in case a field is missing
      role: data['role'] ?? DefaultValues.defaultRole,
      status: data['status'] ?? DefaultValues.defaultStatus,
      displayName: data['displayName'] ?? DefaultValues.defaultDisplayName,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'], // Can be null
      photoURL: data['photoURL'], // Can be null

      // Handle the array (List)
      authProviders: List<String>.from(data['authProviders'] ?? []),

      // Handle the timestamp
      createdAt: data['createdAt'] ?? Timestamp.now(),
      approvedBy: data['approvedBy'], // Can be null
      isActive: data['isActive'] ?? true,

    );
  }

  // A method to convert our UserModel object TO a Map.
  // This is what Firestore understands.
  Map<String, dynamic> toMap() {
    return {
      // 'uid' is not included here because it's the document ID
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
