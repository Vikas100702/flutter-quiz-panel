// lib/models/subject_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_panel/utils/constants.dart';

/// **Why we used this class (SubjectModel):**
/// This class acts as a "blueprint" or data model for a Subject (e.g., "Mathematics", "Science").
///
/// **How it helps:**
/// Instead of passing around raw data (like a messy Map or JSON), we convert that data into
/// this structured class. This ensures that every Subject in our app has a name, an ID,
/// and a status, preventing errors and making the code easier to manage.
class SubjectModel {
  // **Data Fields:**
  // These variables hold the specific details for one single subject.

  final String subjectId; // The unique ID given by Firebase to identify this subject document.
  final String name; // The visible name of the subject (e.g., "History").
  final String? description; // Optional details about what this subject covers.
  final String? imageUrl; // Optional link to an image for the subject card.
  final String createdBy; // The User ID (UID) of the teacher who created this subject.
  final Timestamp createdAt; // The exact time when this subject was created (useful for sorting).

  // The status of the subject (e.g., 'draft' or 'published').
  // This controls whether students can see the subject or not.
  final String status;

  // **Constructor:**
  // This is used to create a real instance of a SubjectModel.
  // We use 'required' for essential data and allow others to be optional (nullable).
  SubjectModel({
    required this.subjectId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  /// **What is this Factory Constructor? (fromFirestore)**
  /// This is a special helper that takes raw data directly from the Firestore database
  /// and converts it into a clean `SubjectModel` object that our app can understand.
  ///
  /// **How it works:**
  /// 1. It takes a `DocumentSnapshot` (the data packet from Firebase).
  /// 2. It extracts the data as a Map.
  /// 3. It assigns each piece of data to the correct variable in our class.
  /// 4. It uses `??` (null check) to provide safe default values if something is missing in the database.
  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    // Safely cast the document data to a Map. If data is null, use an empty map {}.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return SubjectModel(
      // The document ID is distinct from the data map, so we get it from `doc.id`.
      subjectId: doc.id,

      name: data['name'] ?? '',
      description: data['description'], // Can be null, so no default value needed.
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',

      // If the creation time is missing, default to the current time.
      createdAt: data['createdAt'] ?? Timestamp.now(),

      // If status is missing, default to 'draft' so it doesn't accidentally become visible to students.
      status: data['status'] ?? ContentStatus.draft,
    );
  }

  /// **What is this method? (toMap)**
  /// This converts our nice Dart object *back* into a Map (JSON format).
  ///
  /// **Why do we need it?**
  /// Firestore only understands Maps (Key-Value pairs). When we want to save a new Subject
  /// or update an existing one, we must first convert our class instance into this Map format.
  Map<String, dynamic> toMap() {
    return {
      // Note: We usually don't save 'subjectId' inside the map because the document
      // name itself acts as the ID in Firestore.
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'status': status,
    };
  }
}