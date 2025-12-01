// test/models/quiz_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_panel/models/quiz_model.dart';

// 1. Mock DocumentSnapshot to mock firebase data
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('QuizModel Tests', () {

    // Test 1: Empty Factory Constructor
    test('QuizModel.empty() should return a default draft quiz', () {
      // Act
      final quiz = QuizModel.empty();

      // Assert
      expect(quiz.title, '');
      expect(quiz.durationMin, 25);
      expect(quiz.status, 'draft');
      expect(quiz.createdAt, isA<Timestamp>());
    });

    // Test 2: fromFirestore (Valid Data)
    test('fromFirestore creates valid QuizModel with full data', () {
      // Arrange
      final mockDoc = MockDocumentSnapshot();
      final data = <String, dynamic>{
        'subjectId': 'math_101',
        'title': 'Algebra Quiz',
        'createdBy': 'teacher_123',
        'createdAt': Timestamp(500, 0),
        'durationMin': 45,
        'totalQuestions': 30,
        'marksPerQuestion': 2,
        'status': 'published',
      };

      when(() => mockDoc.id).thenReturn('quiz_abc');
      when(() => mockDoc.data()).thenReturn(data);

      // Act
      final quiz = QuizModel.fromFirestore(mockDoc);

      // Assert
      expect(quiz.quizId, 'quiz_abc'); // ID should match document ID
      expect(quiz.title, 'Algebra Quiz');
      expect(quiz.status, 'published');
      expect(quiz.durationMin, 45);
    });

    // Test 3: fromFirestore (Missing Data / Defaults)
    test('fromFirestore applies default values when data is missing', () {
      // Arrange
      final mockDoc = MockDocumentSnapshot();
      // खाली डेटा मैप
      when(() => mockDoc.id).thenReturn('quiz_empty');
      when(() => mockDoc.data()).thenReturn(<String, dynamic>{});

      // Act
      final quiz = QuizModel.fromFirestore(mockDoc);

      // Assert
      expect(quiz.quizId, 'quiz_empty');
      expect(quiz.durationMin, 25); // Default value
      expect(quiz.totalQuestions, 25); // Default value
      expect(quiz.status, 'draft'); // Default value
    });

    // Test 4: toMap Serialization
    test('toMap serializes QuizModel correctly for Firestore', () {
      // Arrange
      final quiz = QuizModel(
        quizId: 'quiz_XYZ', // यह Map में नहीं होना चाहिए
        subjectId: 'physics_202',
        title: 'Physics Test',
        createdBy: 'teacher_999',
        createdAt: Timestamp(1000, 0),
        durationMin: 60,
        totalQuestions: 50,
        marksPerQuestion: 1,
        status: 'draft',
      );

      // Act
      final map = quiz.toMap();

      // Assert
      expect(map.containsKey('quizId'), false); // ID map के अंदर सेव नहीं होती
      expect(map['title'], 'Physics Test');
      expect(map['durationMin'], 60);
      expect(map['status'], 'draft');
    });
  });
}