import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/main.dart';
import 'package:quiz_panel/providers/app_router_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // 1. Create a dummy router for testing.
    // This allows us to test the UI without initializing real Firebase/Auth.
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Mock Home Screen'),)
          )
        )
      ]
    );

    // 2. Pump the widget wrapped in ProviderScope.
    // We override 'routerProvider' to use our mockRouter instead of the real one.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(mockRouter),
        ],
        child: const MyApp(),
      )
    );

    // 3. Verify that the app loaded the mock screen.
    expect(find.text('Mock Home Screen'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}