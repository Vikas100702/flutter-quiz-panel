// lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/repositories/auth_repository.dart';

/// **What is this file for?**
/// This file acts as the "Dependency Injection" hub for Authentication.
/// In Riverpod, we don't create objects (like `new AuthRepository()`) directly inside our widgets.
/// Instead, we create "Providers" here, and our widgets "watch" or "read" them.
///
/// **Why is this helpful?**
/// 1. **Separation of Concerns:** The UI doesn't need to know *how* to create these objects.
/// 2. **Testing:** We can easily swap these providers with "Fake" versions during testing.
/// 3. **Efficiency:** Riverpod manages the lifecycle (creation and destruction) of these objects efficiently.

// -----------------------------------------------------------------
//  DATA LAYER PROVIDERS (The Tools)
// -----------------------------------------------------------------

/// **1. Provider: Firebase Auth Instance (firebaseAuthProvider)**
///
/// **Why we used this:**
/// This gives us access to the raw Firebase Authentication tool.
/// Instead of calling `FirebaseAuth.instance` everywhere (which is hard to test),
/// we ask for this provider.
///
/// **How it works:**
/// It simply returns the singleton instance of FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>(
      (ref) => FirebaseAuth.instance,
);

/// **2. Provider: Auth Repository (authRepositoryProvider)**
///
/// **Why we used this:**
/// The `AuthRepository` is our custom class that contains all the logic for
/// signing in, signing out, and registering. This provider makes that class available to the app.
///
/// **How it works:**
/// 1. It asks (watches) for the `firebaseAuthProvider` to get the tool it needs.
/// 2. It creates a new `AuthRepository` and passes that tool to it.
/// 3. Now, any widget can just ask for `authRepositoryProvider` to perform login actions.
final authRepositoryProvider = Provider<AuthRepository>(
        (ref) {
      // Dependency Injection: We inject the FirebaseAuth instance into the repository.
      return AuthRepository(ref.watch(firebaseAuthProvider));
    }
);

// -----------------------------------------------------------------
//  STATE LAYER PROVIDERS (The "Live" Status)
// -----------------------------------------------------------------

/// **3. Provider: Authentication State (authStateProvider)**
///
/// **Why we used this:**
/// This is the most critical provider for the app's flow. It tells us:
/// "Is the user currently logged in or logged out?"
///
/// **How it helps:**
/// It returns a `Stream` (a live connection).
/// - If the user logs in, this stream emits a `User` object.
/// - If the user logs out, this stream emits `null`.
///
/// **How it works:**
/// Our `AppRouterProvider` watches this. As soon as this value changes (e.g., becomes null),
/// the router automatically kicks the user back to the login screen.
final authStateProvider = StreamProvider<User?>(
        (ref) {
      // 1. Get the repository.
      final authRepository = ref.watch(authRepositoryProvider);

      // 2. Return the live stream of authentication changes.
      return authRepository.authStateChanges;
    }
);