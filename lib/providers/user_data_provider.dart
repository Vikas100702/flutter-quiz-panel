// lib/providers/user_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';

/// **Why we used this Provider (userDataProvider):**
/// This provider acts as the "Profile Manager" for the application.
/// While `authStateProvider` tells us *if* a user is logged in (and gives us their technical ID),
/// this provider fetches the *actual details* (Name, Role, Phone Number) from our database.
///
/// **How it helps:**
/// Any screen (like the Dashboard or Profile page) can watch this provider to show "Welcome, [Name]!"
/// or check "Is this user a Teacher?". It automatically updates if the user logs in or out.
final userDataProvider = FutureProvider<UserModel?>(
      (ref) async {

    // 1. Watch the Authentication State.
    //    We use 'await ref.watch(authStateProvider.future)' to get the latest User object.
    //    This ensures that whenever the login status changes (e.g., user logs in),
    //    this provider runs again automatically to fetch the new user's data.
    final user = await ref.watch(authStateProvider.future);

    // 2. Handle "Logged Out" State.
    //    If 'user' is null, it means no one is currently logged in.
    //    We return null immediately because there is no profile to fetch from the database.
    if (user == null) {
      return null;
    }

    // 3. Get the User ID (UID).
    //    This is the unique key that links the Firebase Auth user to their Firestore Database document.
    final uid = user.uid;

    // 4. Get the Repository.
    //    We ask for the 'UserRepository' tool which knows how to talk to the database.
    final userRepo = ref.read(userRepositoryProvider);

    // 5. Fetch and Return Data.
    //    We ask the repository to find the document with this UID and return it as a 'UserModel'.
    //    Since this is a FutureProvider, the UI will show a loading spinner while this happens.
    return userRepo.getUserData(uid);
  },
);