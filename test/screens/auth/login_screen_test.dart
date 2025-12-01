import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_panel/config/theme/app_theme.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/screens/auth/login_screen.dart';
import 'package:quiz_panel/utils/app_routes.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    // Set a realistic desktop/tablet size to simulate the "Card" view
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: AppRoutePaths.login,
      routes: [
        GoRoute(
          path: AppRoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        // Dummy route to verify navigation
        GoRoute(
          path: AppRoutePaths.register,
          builder: (context, state) => const Scaffold(body: Text('Register Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          // IMPORT: Use the actual app theme to ensure correct font sizing
          theme: AppTheme.lightTheme,
        ),
      ),
    );
  }

  group('LoginScreen UI Tests', () {
    testWidgets('Renders essential login elements', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      expect(find.text('Pro Olympiad'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Shows error SnackBar on login failure', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      when(() => mockAuthRepo.signInWithEmailAndPassword(
        email: 'wrong@test.com',
        password: 'wrongpassword',
      )).thenThrow('Invalid credentials');

      await tester.enterText(find.byType(TextFormField).first, 'wrong@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');

      await tester.ensureVisible(find.text('Login'));
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Calls signInWithEmailAndPassword on success', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      when(() => mockAuthRepo.signInWithEmailAndPassword(
        email: 'correct@test.com',
        password: 'password123',
      )).thenAnswer((_) async {});

      await tester.enterText(find.byType(TextFormField).first, 'correct@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.ensureVisible(find.text('Login'));
      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(() => mockAuthRepo.signInWithEmailAndPassword(
        email: 'correct@test.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets('Navigates to Register screen when Register is tapped', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      final registerFinder = find.textContaining('Register');

      await tester.ensureVisible(registerFinder.first);
      await tester.tap(registerFinder.first);
      await tester.pumpAndSettle();

      expect(find.text('Register Page'), findsOneWidget);
    });
  });
}