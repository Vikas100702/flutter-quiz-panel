import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';

// -----------------------------------------------------------------
//  DATA LAYER PROVIDERS
// -----------------------------------------------------------------

// This provider creates an instance of FirebaseAuth and gives it to whoever asks.
final firebaseAuthProvider = Provider<FirebaseAuth>(
    (ref) => FirebaseAuth.instance,
);

// This provider creates our AuthRepository
// It depends on the provider above to get the FirebaseAuth instance.
final authRepositoryProvider = Provider<AuthRepository>(
    (ref) {
      // 'ref.watch' gets the instance from firebaseAuthProvider
      return AuthRepository(ref.watch(firebaseAuthProvider));
    }
);

// -----------------------------------------------------------------
//  STATE LAYER PROVIDERS (The 'Managers')
// -----------------------------------------------------------------

// This is the most important provider.
// It's a 'StreamProvider', meaning it watches for changes in real-time.
// It will tell our app if a user is LOGGED IN or LOGGED OUT.

final authStateProvider = StreamProvider<User?>(
    (ref) {
      // It asks the AuthRepository to get the auth status stream.
      // We ask our authRepositoryProvider to get the authStateChanges stream.
      // ref.watch() listens to the provider.

      return ref.watch(authRepositoryProvider).authStateChanges;
    }
);


