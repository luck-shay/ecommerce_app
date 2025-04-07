import 'package:ecommerce_app/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/providers/auth_controller.dart';
import 'auth_screen_layout.dart'; // Import the layout

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerInstanceProvider);
      await authController.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: 'Welcome Back!',
      errorMessage: '',
      isLoading: _isLoading,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  // Basic email format check
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onChanged:
                  (_) =>
                      ref
                          .read(authControllerProvider.notifier)
                          .clearError(), // Clear error on typing
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility_off),
                  onPressed: () {
                    // No action needed for visibility toggle
                  },
                ),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                // Add more password strength validation if needed
                return null;
              },
              onChanged:
                  (_) =>
                      ref
                          .read(authControllerProvider.notifier)
                          .clearError(), // Clear error on typing
              onFieldSubmitted:
                  (_) => _signIn(), // Allow submitting from keyboard
            ),
            const SizedBox(height: 24), // Space before button
            // Submit Button
            ElevatedButton(
              onPressed:
                  _isLoading ? null : _signIn, // Disable button when loading
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ), // Rounded button
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
            ),
          ],
        ),
      ),
      switchText: "Don't have an account?",
      switchButtonText: 'Sign Up',
      onSwitchButtonPressed: () {
        ref
            .read(authControllerProvider.notifier)
            .clearError(); // Clear errors before switching
        Navigator.of(context).pushReplacement(
          // Replace Login with Sign Up
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
    );
  }
}
