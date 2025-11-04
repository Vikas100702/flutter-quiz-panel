import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/repositories/user_repository.dart';

// This is our new "Manager"
final userDataProvider = FutureProvider<UserModel?>(
      (ref) async { // The entire function is 'async'

    // 1. We 'await' the result of the authStateProvider.
    //    'ref.watch' ensures this provider re-runs when the user
    //    logs in or out.
    //    '.future' gets the actual 'User?' object instead of the AsyncValue.
    final user = await ref.watch(authStateProvider.future);

    // 2. If user is null (logged out), we are done. Return null.
    //    Since the function is 'async', this 'null' is
    //    automatically wrapped in a 'Future<UserModel?>'.
    if (user == null) {
      return null;
    }

    // 3. If user is NOT null, get their UID.
    final uid = user.uid;

    // 4. Call our 'Chef' (UserRepository) to get the data.
    final userRepo = ref.read(userRepositoryProvider);

    // 5. Return the user data. This is also wrapped in a Future.
    return userRepo.getUserData(uid);
  },
);
