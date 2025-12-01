// test/repositories/auth_repository_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';
import 'package:quiz_panel/utils/app_strings.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authRepository = AuthRepository(mockFirebaseAuth);
  });

  group('AuthRepository Tests', () {

    // --- Sign In Tests ---
    test('signInWithEmailAndPassword calls FirebaseAuth correctly', () async {
      // Arrange
      const email = 'test@test.com';
      const password = 'password123';

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      )).thenAnswer((_) async => MockUserCredential());

      // Act
      await authRepository.signInWithEmailAndPassword(email: email, password: password);

      // Assert
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      )).called(1);
    });

    test('signInWithEmailAndPassword throws friendly error on wrong-password', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password')
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act & Assert
      expect(
            () => authRepository.signInWithEmailAndPassword(email: 'a', password: 'b'),
        throwsA('Wrong password provided for that user.'),
      );
    });

    // --- Register Tests ---
    test('registerWithEmailAndPassword calls createUser correctly', () async {
      // Arrange
      const email = 'new@test.com';
      const password = 'pass';

      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      )).thenAnswer((_) async => MockUserCredential());

      // Act
      await authRepository.registerWithEmailAndPassword(email: email, password: password);

      // Assert
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      )).called(1);
    });

    test('registerWithEmailAndPassword throws weak-password error', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password')
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      // Act & Assert
      expect(
            () => authRepository.registerWithEmailAndPassword(email: 'a', password: 'b'),
        throwsA(AppStrings.weakPasswordError),
      );
    });

    // --- Sign Out Test ---
    test('signOut calls FirebaseAuth signOut', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authRepository.signOut();

      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    // --- Auth State Change Test ---
    test('authStateChanges emits stream from FirebaseAuth', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      expect(stream, emits(mockUser));
    });
  });
}