// lib/main.dart

/*
/// **Why we used this file (main.dart):**
/// This is the **Entry Point** of our Flutter application. Every Flutter app starts executing from the `main()` function defined here.
/// It is responsible for setting up the global environment before the UI is even drawn.
///
/// **What it is doing:**
/// 1. **Initialization:** It ensures the Flutter engine is ready (`WidgetsFlutterBinding`).
/// 2. **Configuration:** It loads environment variables (like API keys) and connects to Firebase.
/// 3. **State Management:** It wraps the entire app in a `ProviderScope`, which is required for Riverpod to work.
/// 4. **Routing & Theming:** It launches the `MaterialApp` with our custom theme and the `GoRouter` configuration.
///
/// **How it helps:**
/// - **Global Setup:** By doing all the heavy lifting (Firebase, .env) here, we ensure that every screen in the app has access to these services immediately.
/// - **Dependency Injection:** The `ProviderScope` at the top level makes our state providers accessible anywhere in the widget tree.
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_panel/firebase_options.dart';
import 'package:quiz_panel/providers/app_router_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'config/theme/app_theme.dart';

// **The Starting Point:**
// This function is the first thing that runs when the app is launched.
void main() async {
  // **Step 1: Engine Binding**
  // Flutter needs to communicate with the native platform (Android/iOS/Web) before running any code.
  // This line ensures that the binding is initialized so we can call native code (like Firebase).
  WidgetsFlutterBinding.ensureInitialized();

  if (WebViewPlatform.instance == null) {
    /* * Note: The youtube_player_iframe package uses webview_flutter internally.
       * We explicitly set the platform implementation to ensure it works correctly
       * on Android devices that might have issues with the default SurfaceAndroidWebView.
       *
    */
    AndroidWebViewPlatform.registerWith(); // Try this if the below line fails in newer versions
  }

  // **Step 2: Firebase Initialization**
  // We connect our app to the specific Firebase project configured in `firebase_options.dart`.
  // This enables Auth, Firestore, and other backend services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // **Step 3: Load Environment Variables**
  // We load the `.env` file which contains sensitive keys (like YouTube API keys).
  // This keeps secrets out of our codebase.
  await dotenv.load(fileName: ".env");

  // **Step 4: Run the App**
  // We wrap `MyApp` in `ProviderScope`. This acts as the "Container" for all Riverpod providers.
  // Without this, `ref.watch` would crash.
  runApp(const ProviderScope(child: MyApp()));
}

/// **The Root Widget (MyApp):**
/// This widget sets up the visual structure of the application.
/// It is a `ConsumerWidget` because it needs to read the `routerProvider` to know how to navigate.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // **Watch the Router:**
    // We get the `GoRouter` instance from our provider. This object contains all the logic
    // for URL paths (`/login`, `/dashboard`) and redirection rules.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // **Configuration:**
      // Removes the "Debug" banner from the top-right corner.
      debugShowCheckedModeBanner: false,

      // **Theming:**
      // Applies our custom visual design (Colors, Fonts, Button Shapes) globally.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .light, // Forces light mode for now (can be made dynamic later).
      // **App Title:**
      // The name shown in the browser tab or recent apps list.
      title: 'Pro Olympiad',

      // **Routing Setup:**
      // We explicitly tell MaterialApp to use `GoRouter` for navigation.
      // This enables features like deep linking and web URL support.
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
