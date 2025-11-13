
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_panel/utils/constants.dart';

// This class represents our 'subjects' document in Firestore.
class SubjectModel {
  final String subjectId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String createdBy;
  final Timestamp createdAt;
  final String status;

  // Constructor
  SubjectModel({
    required this.subjectId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  // Factory constructor to create a SubjectModel from a Firestore document.
  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return SubjectModel(
      subjectId: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? ContentStatus.draft, // <-- NEW (Default to 'draft')
    );
  }

  // Method to convert a SubjectModel instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
