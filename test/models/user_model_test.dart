import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/utils/constants.dart';

// Mock DocumentSnapshot to simulate Firestore data
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('UserModel Tests', () {
    test('fromFirestore creates valid UserModel with full data', () {
      // 1. Arrange
      final mockDoc = MockDocumentSnapshot();
      final data = <String, dynamic>{ // FIX: Explicitly typed map
        'role': 'teacher',
        'status': 'approved',
        'displayName': 'Test Teacher',
        'email': 'teacher@test.com',
        'phoneNumber': '1234567890',
        'photoURL': 'http://image.com/1.jpg',
        'authProviders': ['password'],
        'createdAt': Timestamp(100, 0),
        'approvedBy': 'admin_1',
        'isActive': true,
      };

      when(() => mockDoc.id).thenReturn('user_123');
      when(() => mockDoc.data()).thenReturn(data);

      // 2. Act
      final user = UserModel.fromFirestore(mockDoc);

      // 3. Assert
      expect(user.uid, 'user_123');
      expect(user.role, 'teacher');
      expect(user.email, 'teacher@test.com');
      expect(user.isActive, true);
      expect(user.authProviders, contains('password'));
    });

    test('fromFirestore applies DefaultValues when data is missing', () {
      // 1. Arrange
      final mockDoc = MockDocumentSnapshot();
      // FIX: Explicitly return an empty Map<String, dynamic>
      // The previous error happened because {} defaults to Map<dynamic, dynamic>
      when(() => mockDoc.id).thenReturn('user_456');
      when(() => mockDoc.data()).thenReturn(<String, dynamic>{});

      // 2. Act
      final user = UserModel.fromFirestore(mockDoc);

      // 3. Assert
      expect(user.uid, 'user_456');
      expect(user.role, DefaultValues.defaultRole);
      expect(user.status, DefaultValues.defaultStatus);
      expect(user.displayName, DefaultValues.defaultDisplayName);
      expect(user.createdAt, isNotNull);
    });

    test('toMap serializes UserModel correctly', () {
      // 1. Arrange
      final user = UserModel(
        uid: 'user_789',
        role: 'student',
        status: 'pending',
        displayName: 'Student One',
        email: 'student@test.com',
        authProviders: ['google'],
        createdAt: Timestamp(200, 0),
        isActive: false,
      );

      // 2. Act
      final map = user.toMap();

      // 3. Assert
      expect(map.containsKey('uid'), false);
      expect(map['role'], 'student');
      expect(map['email'], 'student@test.com');
      expect(map['isActive'], false);
    });
  });
}