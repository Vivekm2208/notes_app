import 'package:flutter/material.dart';
import 'package:notes_app/core/features/auth/presentation/auth_text_field.dart';
import 'package:notes_app/core/features/notes/presentation/screens/login_screen.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/core/features/auth/data/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isloading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }

    setState(() => _isloading = true);

    try {
      await _authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      // if (!mounted) return;

      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (_) => const NotesScreen()),
      //   (route) => false,
      // );
    } on FirebaseAuthException catch (exception) {
      debugPrint('Firebase Auth error code: ${exception.code}');
      debugPrint('Firebase Auth error message: ${exception.message}');
      if (!mounted) return;

      final message = _authService.getAuthErrorMessage(exception);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CREATE ACCOUNT',
          style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 1.5),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Noted.',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 30),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Create an account to keep your thoughts organised.',
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    // Full name
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email address',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 8) {
                          return 'Use at least 8 characters';
                        }

                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Include at least one uppercase letter';
                        }

                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Include at least one lowercase letter';
                        }

                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Include at least one number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Confirm password
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 8) {
                          return 'Use at least 8 characters';
                        }

                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Include at least one uppercase letter';
                        }

                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Include at least one lowercase letter';
                        }

                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Include at least one number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Terms acceptance
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: colors.primary,
                      title: Text(
                        'I agree to the Terms of Service and Privacy Policy.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Create account
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isloading ? null : _createAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(NotedRadius.sm),
                          ),
                        ),
                        child: _isloading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Existing account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
