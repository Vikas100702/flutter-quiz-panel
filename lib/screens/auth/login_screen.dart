import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_panel/providers/auth_provider.dart';
import 'package:quiz_panel/utils/app_routes.dart';
import 'package:quiz_panel/utils/app_strings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // controllers to read text from TextFields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // state to manage loading
  bool _isLoading = false;

  // function to handle the login logic
  void _loginUser(BuildContext context) async {
    // start loading
    setState(() {
      _isLoading = true;
    });

    // Check for Internet first
    final connectivityResult = await (Connectivity().checkConnectivity());

    // if there is no connection
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // Use the string from AppStrings
            content: Text(AppStrings.noInternet),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      }); // Stop loading
      return; // Stop the function here
    }

    try {
      // Use 'ref.read(...)' to get our AuthRepository
      //We call the signIn function we created
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),

            // If login is successful, the 'authStateProvider' (in Step 6.8)
            // will automatically update.
          );
    } catch (e) {
      // If an error happens (e.g., wrong password), show a snack bar
      if (mounted) {
        // Check if the widget is still on screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      // Set isLoading = false ONLY on error.
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Clean up controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Panel'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraint) {
          // We define our breakpoint at 600px
          final bool isDesktop = constraint.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 450, minWidth: 300),
              child: Card(
                elevation: isDesktop ? 8.0 : 0.0, // No shadow on mobile
                margin: isDesktop
                    ? const EdgeInsets.all(24.0)
                    : EdgeInsets.zero,
                shape: isDesktop
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12.0),
                      )
                    : null,
                child: Padding(
                  // Dynamic padding based on screen size
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.0 : 20.0,
                    vertical: isDesktop ? 50.0 : 20.0,
                  ),
                  child: _buildLoginForm(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // This widget builds the actual form
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: AppStrings.emailLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: AppStrings.passwordLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),

          // Added onSubmitted for better UX (Press Enter to Login)
          onSubmitted: (_) => _isLoading ? null : _loginUser(context),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isLoading ? null : () => _loginUser(context),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(AppStrings.loginButton),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  // Disable button while loading
                  context.push(AppRoutePaths.register);
                },
          child: RichText(
            text: TextSpan(
              text: AppStrings.noAccount,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: AppStrings.registerNow,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              ]
            ),
          ),
        ),
      ],
    );
  }
}
