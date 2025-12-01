import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';

// Mocks for dependencies
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockAuthRepository extends Mock implements AuthRepository {}

// Helper to register fallback values if needed (for complex objects)
void registerFallbackValues() {
  registerFallbackValue(Uri()); // Example if you use Uri
}