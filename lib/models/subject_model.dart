import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectModel {
  final String subjectId;
  final String name;
  final String? description;
  final String? imageUrl; // Optional image for the subject
  final String createdBy; // UID of the teacher who created it
  final Timestamp createdAt;

  SubjectModel({
    required this.subjectId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
  });

  // Factory constructor to create a SubjectModel from a Firestore document.
  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return SubjectModel(
      subjectId: doc.id,
      // The document ID is the subjectId
      name: data['name'] ?? '',
      description: data['description'],
      // Can be null
      imageUrl: data['imageUrl'],
      // Can be null
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert a SubjectModel instance to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      // 'subjectId' is not in the map because it's the document ID
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
