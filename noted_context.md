This file is a merged representation of a subset of the codebase, containing specifically included files and files not matching ignore patterns, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: lib/**, test/**, pubspec.yaml
- Files matching these patterns are excluded: **/*.g.dart, **/*.freezed.dart
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
````
lib/
  core/
    constants/
      note_colors.dart
    features/
      auth/
        data/
          services/
            auth_service.dart
        presentation/
          screens/
            auth_gate.dart
            authenticated_app.dart
          auth_text_field.dart
      notes/
        data/
          datasources/
            local_note_datasources.dart
          models/
            checklist_item_model.dart
            note_model.dart
          repositories/
            note_repository_impl.dart
        domain/
          entities/
            checklist_item.dart
            note.dart
          repositories/
            note_repositories.dart
        presentation/
          provider/
            notes_provider.dart
          screens/
            add_note_screen.dart
            archive_screen.dart
            edit_note_screen.dart
            login_screen.dart
            notes_screen.dart
            sign_up_screen.dart
            trash_screen.dart
          widgets/
            app_drawer.dart
            category_clip.dart
            category_filterbar.dart
            checklist_editor.dart
            checklist_item_tile.dart
            checklist_preview.dart
            color_picker.dart
            create_note_bottom_sheet.dart
            create_note_option.dart
            format_toobar.dart
            note_action_options.dart
            note_action_sheet.dart
            note_card.dart
            note_color_option.dart
            note_editor_header.dart
            note_editor_toolbar.dart
            note_search_field.dart
            noted_color_dot.dart
            notes_view_options.dart
            reminder_field.dart
            reminder_picker_controller.dart
            reminder_picker.dart
            reminder_recurrence_option.dart
    services/
      notification_service.dart
      rich_text_converter.dart
    theme/
      app_radius.dart
      app_spacing.dart
      app_theme.dart
      app_typography.dart
      noted_colors.dart
    utils/
      date_formatter.dart
      id_generator.dart
      reminder_formatter.dart
      string_formatter.dart
  firebase_options.dart
  main.dart
pubspec.yaml
````

# Files

## File: lib/core/features/auth/data/services/auth_service.dart
````dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> initializeGoogleSignIn() async {
    await _googleSignIn.initialize();
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    await initializeGoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String getAuthErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Your password does not meet the requirements.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
````

## File: lib/core/features/auth/presentation/screens/auth_gate.dart
````dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/auth/presentation/screens/authenticated_app.dart';

import 'package:notes_app/core/features/notes/presentation/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return AuthenticatedApp(key: ValueKey(user.uid), user: user);
        }

        return const LoginScreen();
      },
    );
  }
}
````

## File: lib/core/features/auth/presentation/screens/authenticated_app.dart
````dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/data/datasources/local_note_datasources.dart';
import 'package:notes_app/core/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:provider/provider.dart';

class AuthenticatedApp extends StatefulWidget {
  const AuthenticatedApp({super.key, required this.user});

  final User user;

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  late final Future<LocalNoteDatasources> _datasourceFuture;

  @override
  void initState() {
    super.initState();
    _datasourceFuture = _initializeDatasource();
  }

  Future<LocalNoteDatasources> _initializeDatasource() async {
    final datasource = LocalNoteDatasources();
    await datasource.init(userId: widget.user.uid);
    return datasource;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalNoteDatasources>(
      future: _datasourceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Datasource initialization failed: ${snapshot.error}');

          return const Scaffold(
            body: Center(
              child: Text('Unable to load your notes. Please restart the app.'),
            ),
          );
        }

        final repository = NoteRepositoryImpl(snapshot.data!);

        return ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(repositories: repository)..loadNotes(),
          child: const _AuthenticatedNotesHost(),
        );
      },
    );
  }
}

class _AuthenticatedNotesHost extends StatelessWidget {
  const _AuthenticatedNotesHost();

  @override
  Widget build(BuildContext context) {
    return const NotesScreen();
  }
}
````

## File: lib/core/features/auth/presentation/auth_text_field.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixPressed,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: theme.textTheme.bodyMedium,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(onPressed: onSuffixPressed, icon: Icon(suffixIcon)),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}
````

## File: lib/core/features/notes/data/models/checklist_item_model.dart
````dart
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistItemModel extends ChecklistItem {
  ChecklistItemModel({
    required super.id,
    required super.text,
    super.isCompleted = false,
  });

  factory ChecklistItemModel.fromEntity(ChecklistItem item) {
    return ChecklistItemModel(
      id: item.id,
      text: item.text,
      isCompleted: item.isCompleted,
    );
  }

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id'] as String,
      text: map['text'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isCompleted': isCompleted};
  }
}
````

## File: lib/core/features/notes/domain/entities/checklist_item.dart
````dart
class ChecklistItem {
  final String id;
  final String text;
  final bool isCompleted;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  ChecklistItem copyWith({String? id, String? text, bool? isCompleted}) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
````

## File: lib/core/features/notes/domain/repositories/note_repositories.dart
````dart
import '../entities/note.dart';

abstract class NoteRepositories {
  Future<void> addNote(Note note);
  Future<List<Note>> getNotes();

  Future<void> deleteNote(String id);

  Future<void> updateNote(Note note);
}
````

## File: lib/core/features/notes/presentation/screens/sign_up_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/auth/presentation/auth_text_field.dart';
import 'package:notes_app/core/features/notes/presentation/screens/login_screen.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/core/features/auth/data/services/auth_service.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';

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

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NotesScreen()),
        (route) => false,
      );
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
````

## File: lib/core/features/notes/presentation/widgets/category_clip.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class CategoryClip extends StatelessWidget {
  const CategoryClip({
    super.key,
    required this.label,
    required this.category,
    required this.onSelectedCategory,
    required this.selectedCategory,
  });

  final String label;

  final NoteCategory? category;

  final ValueChanged<NoteCategory?> onSelectedCategory;

  final NoteCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final isSelected = category == selectedCategory;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        selectedColor: theme.colorScheme.primary,
        label: Text(label, style: theme.textTheme.titleMedium),
        onSelected: (selected) {
          onSelectedCategory(selected ? category : null);
        },
        selected: isSelected,
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/format_toobar.dart
````dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FormatToolBar extends StatefulWidget {
  const FormatToolBar({
    super.key,
    required this.onFormat,
    required this.controller,
  });

  final ValueChanged<Attribute> onFormat;
  final QuillController controller;

  @override
  State<FormatToolBar> createState() => _FormatToolBarState();
}

class _FormatToolBarState extends State<FormatToolBar> {
  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final style = widget.controller.getSelectionStyle();

    // Text formatting
    final isBold = style.containsKey(Attribute.bold.key);
    final isItalic = style.containsKey(Attribute.italic.key);
    final isUnderline = style.containsKey(Attribute.underline.key);
    final isStrikeThrough = style.containsKey(Attribute.strikeThrough.key);

    // Headings
    final header = style.attributes[Attribute.header.key];

    final isH1 = header?.value == 1;
    final isH2 = header?.value == 2;
    final isH3 = header?.value == 3;

    // Lists
    final listAttribute = style.attributes[Attribute.list.key];

    final isBulletList = listAttribute?.value == 'bullet';
    final isNumberedList = listAttribute?.value == 'ordered';

    // Alignment
    final alignmentAttribute = style.attributes[Attribute.align.key];

    final isLeft = alignmentAttribute?.value == 'left';
    final isCenter = alignmentAttribute?.value == 'center';
    final isRight = alignmentAttribute?.value == 'right';
    final isJustify = alignmentAttribute?.value == 'justify';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -------------------------
        // TEXT FORMATTING
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.bold);
          },
          style: IconButton.styleFrom(
            backgroundColor: isBold ? colorScheme.primary : null,
            foregroundColor: isBold ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_bold),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.italic);
          },
          style: IconButton.styleFrom(
            backgroundColor: isItalic ? colorScheme.primary : null,
            foregroundColor: isItalic ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_italic),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.underline);
          },
          style: IconButton.styleFrom(
            backgroundColor: isUnderline ? colorScheme.primary : null,
            foregroundColor: isUnderline ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_underline),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.strikeThrough);
          },
          style: IconButton.styleFrom(
            backgroundColor: isStrikeThrough ? colorScheme.primary : null,
            foregroundColor: isStrikeThrough ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_strikethrough),
        ),

        // -------------------------
        // HEADINGS
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h1);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH1 ? colorScheme.primary : null,
            foregroundColor: isH1 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H1',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h2);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH2 ? colorScheme.primary : null,
            foregroundColor: isH2 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H2',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.h3);
          },
          style: IconButton.styleFrom(
            backgroundColor: isH3 ? colorScheme.primary : null,
            foregroundColor: isH3 ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Text(
            'H3',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        // -------------------------
        // LISTS
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.ul);
          },
          style: IconButton.styleFrom(
            backgroundColor: isBulletList ? colorScheme.primary : null,
            foregroundColor: isBulletList ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_list_bulleted),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.ol);
          },
          style: IconButton.styleFrom(
            backgroundColor: isNumberedList ? colorScheme.primary : null,
            foregroundColor: isNumberedList ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_list_numbered),
        ),

        // -------------------------
        // ALIGNMENT
        // -------------------------
        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.leftAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isLeft ? colorScheme.primary : null,
            foregroundColor: isLeft ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_left),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.centerAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isCenter ? colorScheme.primary : null,
            foregroundColor: isCenter ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_center),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.rightAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isRight ? colorScheme.primary : null,
            foregroundColor: isRight ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_right),
        ),

        IconButton(
          onPressed: () {
            widget.onFormat(Attribute.justifyAlignment);
          },
          style: IconButton.styleFrom(
            backgroundColor: isJustify ? colorScheme.primary : null,
            foregroundColor: isJustify ? colorScheme.onPrimary : null,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.format_align_justify),
        ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_color_option.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class NoteColorOption extends StatelessWidget {
  const NoteColorOption({
    super.key,
    required this.color,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  final String label;

  final VoidCallback onTap;

  final bool isSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: NotedSpacing.xs),
        Text(label),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_editor_header.dart
````dart
import 'package:flutter/material.dart';

class NoteEditorHeader extends StatelessWidget {
  const NoteEditorHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSave,
  });
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: onSave,
            icon: const Icon(Icons.check_circle),
          ),
        ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/noted_color_dot.dart
````dart
import 'package:flutter/material.dart';

final class NotedColorDot extends StatelessWidget {
  const NotedColorDot({super.key, required this.color});

  final Color color;

  static const double _size = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      width: _size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/reminder_field.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class ReminderField extends StatelessWidget {
  const ReminderField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NotedRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(NotedSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(NotedRadius.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: NotedSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/reminder_picker_controller.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class ReminderPickerController {
  ReminderPickerController({
    DateTime? reminder,
    required ReminderRecurrence recurrence,
  }) {
    _selectedRecurrence = recurrence;

    if (reminder != null) {
      _selectedDate = DateTime(reminder.year, reminder.month, reminder.day);

      _selectedTime = TimeOfDay.fromDateTime(reminder);
    }
  }

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ReminderRecurrence _selectedRecurrence;

  DateTime? get selectedDate => _selectedDate;

  TimeOfDay? get selectedTime => _selectedTime;

  ReminderRecurrence get selectedRecurrence => _selectedRecurrence;

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
  }

  void setTime(TimeOfDay time) {
    _selectedTime = time;
  }

  void setRecurrence(ReminderRecurrence recurrence) {
    _selectedRecurrence = recurrence;
  }

  bool get canSetReminder => _selectedDate != null && _selectedTime != null;

  DateTime? buildReminder() {
    if (!canSetReminder) return null;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/reminder_recurrence_option.dart
````dart
import 'package:flutter/material.dart';

class ReminderRecurrenceOption extends StatelessWidget {
  const ReminderRecurrenceOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selectedColor: Theme.of(context).colorScheme.primary,
      label: Text(label, style: Theme.of(context).textTheme.titleMedium),
      selected: selected,
      onSelected: (_) {
        onSelected();
      },
    );
  }
}
````

## File: lib/core/services/rich_text_converter.dart
````dart
import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class RichTextConverter {
  static Document plainTextToDocument(String text) {
    final normaalizedText = text.endsWith('\n') ? text : '$text\n';
    return Document.fromJson([
      {'insert': normaalizedText},
    ]);
  }

  static Document jsonToDocument(String content) {
    if (content.trim().isEmpty) {
      return Document();
    }
    final json = jsonDecode(content);

    return Document.fromJson(json);
  }

  static String documentToJsonString(Document document) {
    final json = document.toDelta().toJson();

    return jsonEncode(json);
  }

  static String jsonToPlainText(String plainText) {
    final document = jsonToDocument(plainText);

    return document.toPlainText().trim();
  }

  static String documentToPlainText(Document document) {
    return document.toPlainText().trim();
  }
}
````

## File: lib/core/theme/app_spacing.dart
````dart
final class NotedSpacing {
  NotedSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
````

## File: lib/core/utils/date_formatter.dart
````dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(date)}';
    }

    if (date.year == now.year) {
      return DateFormat('dd MMM, hh:mm a').format(date);
    }

    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
````

## File: lib/core/utils/id_generator.dart
````dart
import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  static String generator() {
    return _uuid.v4();
  }
}
````

## File: lib/core/utils/reminder_formatter.dart
````dart
import 'package:intl/intl.dart';
import 'package:notes_app/core/utils/date_formatter.dart';

class ReminderFormatter {
  static String format(DateTime reminder) {
    final now = DateTime.now();

    final tomorrow = now.add(const Duration(days: 1));

    final time = DateFormat('hh:mm a').format(reminder);

    if (reminder.day == tomorrow.day &&
        reminder.month == tomorrow.month &&
        reminder.year == tomorrow.year) {
      return 'Tomorrow • $time';
    }

    final date = DateFormatter.format(reminder);

    return '$date • $time';
  }
}
````

## File: lib/core/utils/string_formatter.dart
````dart
class StringFormatter {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
````

## File: lib/firebase_options.dart
````dart
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAUuJWVpo-HvIC-TVW_yOZpsvcxT7VIac',
    appId: '1:922648575110:web:9d1554399eb96ec9526507',
    messagingSenderId: '922648575110',
    projectId: 'noted-b8820',
    authDomain: 'noted-b8820.firebaseapp.com',
    storageBucket: 'noted-b8820.firebasestorage.app',
    measurementId: 'G-WVPFFEQ65D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCte70FXhRu1kmvpvTZHa-927RBnzKC9tY',
    appId: '1:922648575110:android:5735f0251c051096526507',
    messagingSenderId: '922648575110',
    projectId: 'noted-b8820',
    storageBucket: 'noted-b8820.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCVNYVjro5dMvM8JGCMZJTR6nQvte7diA',
    appId: '1:922648575110:ios:d19c67acb99f92a5526507',
    messagingSenderId: '922648575110',
    projectId: 'noted-b8820',
    storageBucket: 'noted-b8820.firebasestorage.app',
    iosBundleId: 'com.example.notesApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCVNYVjro5dMvM8JGCMZJTR6nQvte7diA',
    appId: '1:922648575110:ios:d19c67acb99f92a5526507',
    messagingSenderId: '922648575110',
    projectId: 'noted-b8820',
    storageBucket: 'noted-b8820.firebasestorage.app',
    iosBundleId: 'com.example.notesApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAUuJWVpo-HvIC-TVW_yOZpsvcxT7VIac',
    appId: '1:922648575110:web:d5964b32418a293d526507',
    messagingSenderId: '922648575110',
    projectId: 'noted-b8820',
    authDomain: 'noted-b8820.firebaseapp.com',
    storageBucket: 'noted-b8820.firebasestorage.app',
    measurementId: 'G-ZPZ709PCJZ',
  );
}
````

## File: lib/core/features/notes/presentation/screens/login_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/screens/sign_up_screen.dart';
import 'package:notes_app/core/features/auth/presentation/auth_text_field.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/core/features/auth/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotesScreen()),
      );
    } on FirebaseAuthException catch (exception) {
      debugPrint('Login error code: ${exception.code}');
      debugPrint('Login error message: ${exception.message}');

      if (!mounted) return;

      final message = _authService.getAuthErrorMessage(exception);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (exception) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await AuthService().signInWithGoogle();

      // AuthGate will automatically open NotesScreen.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService().getAuthErrorMessage(e))),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand
                    Text(
                      'NOTED',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Brand icon
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.onSurface, width: 2),
                          borderRadius: BorderRadius.circular(NotedRadius.sm),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 42,
                              color: colors.onSurface,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to your account.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 36),

                    // Email
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
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
                      textInputAction: TextInputAction.done,
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
                          return 'Please enter your password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter your email address first.',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            await _authService.sendPasswordResetEmail(
                              email: email,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'If an account exists for this email, '
                                  'you will receive a password reset email.',
                                ),
                              ),
                            );
                          } on FirebaseAuthException catch (exception) {
                            if (!context.mounted) return;

                            final message = _authService.getAuthErrorMessage(
                              exception,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          } catch (_) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Something went wrong. Please try again.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: colors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign in button
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(NotedRadius.sm),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 22,
                            width: 22,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.g_mobiledata, size: 28);
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text('Continue with Google'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.outline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'YOUR NOTES, YOUR SPACE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.outline)),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Sign up navigation placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to Noted?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Create account',
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
````

## File: lib/core/features/notes/presentation/screens/trash_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/notes_view_options.dart';
import 'package:provider/provider.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.trashedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.trash),

      appBar: AppBar(
        title: const Text('Trash Bin'),

        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<NotesProvider>();

              provider.updateViewType(
                provider.viewType == NoteViewType.gridView
                    ? NoteViewType.listView
                    : NoteViewType.gridView,
              );
            },

            icon: Icon(
              provider.viewType == NoteViewType.gridView
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryFilterbar(
              selectedCategory: provider.selectedCategory,
              onChanged: provider.updateSelectedCategory,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: NoteSearchfield(
              hintText: 'Search in Trash...',
              onChanged: provider.updateSearchQuery,
            ),
          ),

          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('Empty Trash Bin'))
                : NotesViewOptions(
                    notes: notes,
                    onLeftSwipeText: 'Delete',
                    onLeftSwipe: (note) async {
                      await provider.deleteForever(note.id);
                    },
                    onRghtSwipeText: 'Restore',
                    onRightSwipe: (note) async {
                      await provider.restoreNote(note);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/color_picker.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/constants/note_colors.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_color_option.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  static const List<String> labels = [
    'Default',
    'Amber',
    'Green',
    'Blue',
    'Purple',
    'Red',
  ];
  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Note colour', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: NotedSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: NoteColors.colors.asMap().entries.map((entry) {
            return NoteColorOption(
              color: entry.value,
              isSelected: selectedColor == entry.value,
              label: labels[entry.key],
              onTap: () {
                onColorSelected(entry.value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/create_note_bottom_sheet.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/create_note_option.dart';

class CreateNoteBottomSheet extends StatelessWidget {
  const CreateNoteBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create New', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),
            CreateNoteOption(
              icon: Icons.note_outlined,
              title: 'Text Note',
              subtitle: 'Write Notes Freely',
              onTap: () {
                Navigator.pop(context, NoteType.text);
              },
            ),
            const SizedBox(height: 16),
            CreateNoteOption(
              icon: Icons.checklist,
              title: 'Checklist',
              subtitle: 'Track tasks with ckeckbox',
              onTap: () {
                Navigator.pop(context, NoteType.checklist);
              },
            ),
          ],
        ),
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/create_note_option.dart
````dart
import 'package:flutter/material.dart';

class CreateNoteOption extends StatelessWidget {
  const CreateNoteOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_action_options.dart
````dart
import 'package:flutter/material.dart';

class NoteActionOptions extends StatelessWidget {
  const NoteActionOptions({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_action_sheet.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_action_options.dart';
import 'package:provider/provider.dart';

class NoteActionSheet extends StatelessWidget {
  final Note note;

  const NoteActionSheet({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            NoteActionOptions(
              title: note.isPinned ? 'UnPin Note' : 'Pin Note',
              icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              onTap: () async {
                await context.read<NotesProvider>().togglePin(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Archive Note',
              icon: Icons.archive,
              onTap: () async {
                await context.read<NotesProvider>().archiveNote(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Delete Note',
              icon: Icons.delete,
              onTap: () async {
                await context.read<NotesProvider>().moveToTrash(note);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            NoteActionOptions(
              title: 'Cancel',
              icon: Icons.cancel,
              onTap: () async {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_search_field.dart
````dart
import 'package:flutter/material.dart';

class NoteSearchfield extends StatelessWidget {
  const NoteSearchfield({
    super.key,
    required this.onChanged,
    this.hintText = 'Search Notes...',
  });

  final ValueChanged<String> onChanged;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/notes_view_options.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_action_sheet.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';

class NotesViewOptions extends StatelessWidget {
  const NotesViewOptions({
    super.key,
    required this.notes,
    required this.onRightSwipe,
    required this.onLeftSwipe,
    required this.onLeftSwipeText,
    required this.onRghtSwipeText,
  });

  final List<Note> notes;
  final Future<void> Function(Note note) onLeftSwipe;
  final String onLeftSwipeText;
  final String onRghtSwipeText;
  final Future<void> Function(Note note) onRightSwipe;

  // ----------------------------------------------------------
  // GRID VIEW
  // ----------------------------------------------------------

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 220,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,

        // Start here and tune visually.
        childAspectRatio: 0.9,
      ),

      itemCount: notes.length,

      itemBuilder: (context, index) {
        final note = notes[index];

        return _buildNote(context, note);
      },
    );
  }

  // ----------------------------------------------------------
  // LIST VIEW
  // ----------------------------------------------------------

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),

      itemCount: notes.length,

      itemBuilder: (context, index) {
        final note = notes[index];

        return _buildNote(context, note);
      },

      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }

  // ----------------------------------------------------------
  // NOTE
  // ----------------------------------------------------------

  Widget _buildNote(BuildContext context, Note note) {
    return Dismissible(
      key: ValueKey(note.id),

      direction: DismissDirection.horizontal,

      // Swipe right → Archive
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: NotedSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.archive),
            const SizedBox(width: 8),
            Text(
              onRghtSwipeText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),

      // Swipe left → Delete
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: NotedSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              onLeftSwipeText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outlined),
          ],
        ),
      ),

      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await onLeftSwipe(note);
        }

        if (direction == DismissDirection.startToEnd) {
          await onRightSwipe(note);
        }
      },

      child: NoteCard(
        note: note,

        // Global Grid/List preference
        viewType: context.read<NotesProvider>().viewType,

        onTap: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider<NotesProvider>.value(
                value: context.read<NotesProvider>(),
                child: EditNoteScreen(note: note),
              ),
            ),
          );
        },

        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return NoteActionSheet(note: note);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return switch (provider.viewType) {
      NoteViewType.gridView => _buildGridView(context),
      NoteViewType.listView => _buildListView(context),
    };
  }
}
````

## File: lib/core/features/notes/presentation/widgets/reminder_picker.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker_controller.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_recurrence_option.dart';
import 'package:notes_app/core/theme/app_spacing.dart';

class ReminderPicker extends StatefulWidget {
  const ReminderPicker({
    super.key,
    required this.reminder,
    required this.onReminderChanged,
    required this.recurrence,
    required this.onRecurrenceChanged,
  });

  final DateTime? reminder;
  final ValueChanged<DateTime?> onReminderChanged;

  final ReminderRecurrence recurrence;
  final ValueChanged<ReminderRecurrence> onRecurrenceChanged;

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  late final ReminderPickerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReminderPickerController(
      reminder: widget.reminder,
      recurrence: widget.recurrence,
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) return;

    setState(() {
      _controller.setDate(date);
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime ?? TimeOfDay.now(),
    );

    if (!mounted || time == null) return;

    setState(() {
      _controller.setTime(time);
    });
  }

  void _selectRecurrence(ReminderRecurrence recurrence) {
    setState(() {
      _controller.setRecurrence(recurrence);
    });

    widget.onRecurrenceChanged(recurrence);
  }

  void _setReminder() {
    final reminder = _controller.buildReminder();

    if (reminder == null) return;

    widget.onReminderChanged(reminder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Set reminder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        const SizedBox(height: NotedSpacing.md),

        Wrap(
          spacing: NotedSpacing.sm,
          runSpacing: NotedSpacing.sm,
          children: [
            ReminderRecurrenceOption(
              label: 'Never',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.none,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.none);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryDay',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.daily,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.daily);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryWeek',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.weekly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.weekly);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryMonth',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.monthly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.monthly);
              },
            ),

            ReminderRecurrenceOption(
              label: 'EveryYear',
              selected:
                  _controller.selectedRecurrence == ReminderRecurrence.yearly,
              onSelected: () {
                _selectRecurrence(ReminderRecurrence.yearly);
              },
            ),
          ],
        ),

        const SizedBox(height: NotedSpacing.md),

        Row(
          children: [
            ReminderField(
              label: 'DATE',
              value: _controller.selectedDate == null
                  ? 'Select date'
                  : '${_controller.selectedDate!.day.toString().padLeft(2, '0')}/'
                        '${_controller.selectedDate!.month.toString().padLeft(2, '0')}/'
                        '${_controller.selectedDate!.year}',
              onTap: _pickDate,
            ),

            const SizedBox(width: NotedSpacing.sm),

            ReminderField(
              label: 'TIME',
              value: _controller.selectedTime == null
                  ? 'Select time'
                  : _controller.selectedTime!.format(context),
              onTap: _pickTime,
            ),
          ],
        ),

        const SizedBox(height: NotedSpacing.md),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _controller.canSetReminder ? _setReminder : null,
            child: Text(
              widget.reminder == null ? 'Set Reminder' : 'Update Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),

        if (widget.reminder != null) ...[
          const SizedBox(height: NotedSpacing.sm),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                widget.onReminderChanged(null);

                widget.onRecurrenceChanged(ReminderRecurrence.none);
              },
              child: Text(
                'Remove Reminder',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
````

## File: lib/core/theme/app_radius.dart
````dart
final class NotedRadius {
  NotedRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 32;
}
````

## File: lib/core/theme/app_theme.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_typography.dart';
import 'package:notes_app/core/theme/noted_colors.dart';

class NotedTheme {
  NotedTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: NotedColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: NotedColors.accent,
        surface: NotedColors.darkSurface,
        onSurface: NotedColors.darkTextPrimary,
        surfaceContainerHighest: NotedColors.darkSurfaceVariant,
        outline: NotedColors.darkBorder,
      ),

      textTheme: TextTheme(
        titleMedium: NotedTypography.title.copyWith(
          color: NotedColors.darkTextPrimary,
        ),
        bodyMedium: NotedTypography.body.copyWith(
          color: NotedColors.darkTextSecondary,
        ),
        bodySmall: NotedTypography.caption.copyWith(
          color: NotedColors.darkTextMuted,
        ),
        titleLarge: NotedTypography.appTitle.copyWith(
          color: NotedColors.darkTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: NotedColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.xs),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor: NotedColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: NotedColors.accent,
        surface: NotedColors.lightSurface,
        onSurface: NotedColors.lightTextPrimary,
        surfaceContainerHighest: NotedColors.lightSurfaceVariant,
        outline: NotedColors.lightBorder,
      ),

      textTheme: TextTheme(
        titleMedium: NotedTypography.title.copyWith(
          color: NotedColors.lightTextPrimary,
        ),
        bodyMedium: NotedTypography.body.copyWith(
          color: NotedColors.lightTextSecondary,
        ),
        bodySmall: NotedTypography.caption.copyWith(
          color: NotedColors.lightTextMuted,
        ),
        titleLarge: NotedTypography.appTitle.copyWith(
          color: NotedColors.lightTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: NotedColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.xs),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
````

## File: lib/core/theme/noted_colors.dart
````dart
import 'package:flutter/material.dart';

final class NotedColors {
  const NotedColors._();

  // ---------- DARK ----------

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF666666);

  static const Color darkTextPrimary = Color(0xFFEAEAEA);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextMuted = Color(0xFF666666);

  // ---------- LIGHT ----------

  static const Color lightBackground = Color(0xFFF7F7F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F0);
  static const Color lightBorder = Color(0xFFD0D0D0);

  static const Color lightTextPrimary = Color(0xFF171717);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextMuted = Color(0xFF888888);

  // ---------- COMMON ----------

  static const Color accent = Color(0xFFD71921);
}
````

## File: lib/core/constants/note_colors.dart
````dart
import 'package:flutter/material.dart';

class NoteColors {
  static const List<Color> colors = [
    Colors.grey,
    Color.fromARGB(255, 250, 225, 2),
    Color.fromARGB(255, 2, 213, 9),
    Color.fromARGB(255, 1, 138, 251),
    Color.fromARGB(255, 209, 1, 246),
    Color.fromARGB(255, 247, 1, 1),
  ];
}
````

## File: lib/core/features/notes/data/datasources/local_note_datasources.dart
````dart
import 'package:hive/hive.dart';

import '../models/note_model.dart';

class LocalNoteDatasources {
  late Box notesBox;

  Future<void> init({required String userId}) async {
    notesBox = await Hive.openBox('notes_$userId');
  }

  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    return notesBox.values
        .map((note) => NoteModel.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    await notesBox.put(updatedNote.id, updatedNote.toMap());
  }
}
````

## File: lib/core/features/notes/presentation/screens/archive_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/notes_view_options.dart';
import 'package:provider/provider.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.archivedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.archive),

      appBar: AppBar(
        title: const Text('Archived'),

        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<NotesProvider>();

              provider.updateViewType(
                provider.viewType == NoteViewType.gridView
                    ? NoteViewType.listView
                    : NoteViewType.gridView,
              );
            },

            icon: Icon(
              provider.viewType == NoteViewType.gridView
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryFilterbar(
              selectedCategory: provider.selectedCategory,
              onChanged: provider.updateSelectedCategory,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: NoteSearchfield(
              hintText: 'Search Archive Notes...',
              onChanged: provider.updateSearchQuery,
            ),
          ),

          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No Archived Notes'))
                : NotesViewOptions(
                    notes: notes,
                    onLeftSwipeText: 'Delete',
                    onLeftSwipe: (note) async {
                      await provider.moveToTrash(note);
                    },
                    onRghtSwipeText: 'Unarchive',
                    onRightSwipe: (note) async {
                      await provider.restoreNote(note);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/category_filterbar.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class CategoryFilterbar extends StatelessWidget {
  const CategoryFilterbar({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final ValueChanged<NoteCategory?> onChanged;
  final NoteCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: [
          CategoryClip(
            label: 'All',
            category: null,
            onSelectedCategory: onChanged,
            selectedCategory: selectedCategory,
          ),
          ...NoteCategory.values.map(
            (category) => CategoryClip(
              label: StringFormatter.capitalize(category.name),
              category: category,
              onSelectedCategory: onChanged,
              selectedCategory: selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/checklist_editor.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_item_tile.dart';

class ChecklistEditor extends StatelessWidget {
  const ChecklistEditor({
    super.key,
    required this.items,
    required this.focusedItemId,
    required this.onAdd,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
  });

  final List<ChecklistItem> items;

  final String? focusedItemId;

  final VoidCallback onAdd;
  final ValueChanged<String> onToggle;
  final ValueChanged<ChecklistItem> onUpdate;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ChecklistItemTile(
                item: item,
                autoFocus: item.id == focusedItemId,
                onRemove: onRemove,
                onToggle: onToggle,
                onUpdate: onUpdate,
              );
            },
          ),
        ),

        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(
            'Add Item',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/checklist_item_tile.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistItemTile extends StatefulWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onToggle,
    required this.onUpdate,
    this.autoFocus = false,
  });

  final ChecklistItem item;

  final ValueChanged<String> onToggle;
  final ValueChanged<ChecklistItem> onUpdate;
  final ValueChanged<String> onRemove;

  final bool autoFocus;

  @override
  State<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.item.text);

    _focusNode = FocusNode();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.text != widget.item.text &&
        _controller.text != widget.item.text) {
      _controller.value = TextEditingValue(
        text: widget.item.text,
        selection: TextSelection.collapsed(offset: widget.item.text.length),
      );
    }

    if (!oldWidget.autoFocus && widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.item.isCompleted,
          onChanged: (_) {
            widget.onToggle(widget.item.id);
          },
        ),

        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              decoration: widget.item.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (text) {
              widget.onUpdate(widget.item.copyWith(text: text));
            },
          ),
        ),

        IconButton(
          onPressed: () {
            widget.onRemove(widget.item.id);
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/checklist_preview.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistPreview extends StatelessWidget {
  const ChecklistPreview({super.key, required this.items});

  final List<ChecklistItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const previewLimit = 4;
    final visibleItems = items.take(previewLimit).toList();
    final remainingItems = items.length - visibleItems.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visibleItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.isCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: item.isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (remainingItems > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$remainingItems more',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/note_editor_toolbar.dart
````dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/color_picker.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/format_toobar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NoteEditorToolbar extends StatefulWidget {
  const NoteEditorToolbar({
    super.key,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.reminder,
    required this.onSelectedReminder,
    required this.onFormat,
    required this.recurrence,
    required this.onSelectedRecurrence,
    required this.controller,
  });

  final QuillController? controller;
  final ValueChanged<Attribute> onFormat;
  final ValueChanged<Color> onSelectedColor;
  final ValueChanged<ReminderRecurrence> onSelectedRecurrence;
  final ValueChanged<DateTime?> onSelectedReminder;
  final ReminderRecurrence recurrence;
  final DateTime? reminder;
  final Color selectedColor;

  @override
  State<NoteEditorToolbar> createState() => _NoteEditorToolbarState();
}

class _NoteEditorToolbarState extends State<NoteEditorToolbar> {
  bool _showFormatToolbar = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==============================
        // FORMAT TOOLBAR
        // ==============================
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _showFormatToolbar && widget.controller != null
              ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: NotedSpacing.sm,
                      vertical: 4,
                    ),
                    child: FormatToolBar(
                      onFormat: widget.onFormat,
                      controller: widget.controller!,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ==============================
        // MAIN TOOLBAR
        // ==============================
        Row(
          children: [
            // COLOR
            Expanded(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(NotedSpacing.md),
                          child: ColorPicker(
                            selectedColor: widget.selectedColor,
                            onColorSelected: (color) {
                              widget.onSelectedColor(color);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.color_lens_outlined),
              ),
            ),

            // REMINDER
            Expanded(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(NotedSpacing.md),
                          child: ReminderPicker(
                            reminder: widget.reminder,
                            recurrence: widget.recurrence,
                            onReminderChanged: (reminder) {
                              widget.onSelectedReminder(reminder);
                              Navigator.pop(context);
                            },
                            onRecurrenceChanged: widget.onSelectedRecurrence,
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
              ),
            ),

            // FORMAT
            if (widget.controller != null)
              Expanded(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showFormatToolbar = !_showFormatToolbar;
                    });
                  },
                  icon: Icon(
                    Icons.text_format,
                    color: _showFormatToolbar
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
````

## File: lib/core/services/notification_service.dart
````dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'notes_channel',
    'Notes Reminder',
    description: 'Reminder notifications for notes',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // Load timezone database
    tz.initializeTimeZones();

    // Get device timezone
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    String timezone = timezoneInfo.identifier;

    // Older Android versions/emulators sometimes return Asia/Calcutta
    if (timezone == 'Asia/Calcutta') {
      timezone = 'Asia/Kolkata';
    }

    tz.setLocalLocation(tz.getLocation(timezone));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(settings: initializationSettings);

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      // Android 13+
      await android.requestNotificationsPermission();

      // Android 14+
      await android.requestExactAlarmsPermission();

      // Explicitly create notification channel
      await android.createNotificationChannel(_channel);

      final canScheduleExact = await android.canScheduleExactNotifications();

      debugPrint('Can schedule exact alarms: $canScheduleExact');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required ReminderRecurrence recurrence,
  }) async {
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'notes_channel',
        'Notes Reminder',
        channelDescription: 'Reminder notifications for notes',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,

        onlyAlertOnce: false,
      ),
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _dateTimeComponents(recurrence),
      payload: id.toString(),
    );

    final pending = await _notifications.pendingNotificationRequests();

    for (final notification in pending) {
      debugPrint(
        'ID: ${notification.id}, '
        'Title: ${notification.title}',
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'notes_channel',
        'Notes Reminder',
        channelDescription: 'Reminder notifications for notes',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      id: 0,
      title: 'Test Notification',
      body: 'If you see this, notifications work.',
      notificationDetails: details,
    );
  }

  DateTimeComponents? _dateTimeComponents(ReminderRecurrence recurrence) {
    switch (recurrence) {
      case ReminderRecurrence.none:
        return null;

      case ReminderRecurrence.daily:
        return DateTimeComponents.time;

      case ReminderRecurrence.weekly:
        return DateTimeComponents.dayOfWeekAndTime;

      case ReminderRecurrence.monthly:
        return DateTimeComponents.dayOfMonthAndTime;

      case ReminderRecurrence.yearly:
        return DateTimeComponents.dateAndTime;
    }
  }
}
````

## File: lib/core/theme/app_typography.dart
````dart
import 'package:flutter/material.dart';

final class NotedTypography {
  NotedTypography._();

  static const TextStyle title = TextStyle(
    fontFamily: 'SpaceMono',
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  static const TextStyle appTitle = TextStyle(
    fontFamily: 'SpaceMono',
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 16,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 12,
  );
}
````

## File: lib/core/features/notes/presentation/widgets/note_card.dart
````dart
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_preview.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/noted_color_dot.dart';
import 'package:notes_app/core/services/rich_text_converter.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/utils/date_formatter.dart';
import 'package:notes_app/core/utils/string_formatter.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.viewType,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final Note note;
  final NoteViewType viewType;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Optional actions such as:
  /// Restore / Delete
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hasBeenEdited = note.createdAt != note.lastEdited;

    final previewContent =
        note.contentFormat == NoteContentFormat.richText &&
            note.content.trim().isNotEmpty
        ? RichTextConverter.jsonToPlainText(note.content)
        : note.content;

    final displayText = hasBeenEdited
        ? 'Last Edited ${DateFormatter.format(note.lastEdited)}'
        : 'Created ${DateFormatter.format(note.createdAt)}';

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(NotedRadius.sm),
        color: Theme.of(context).colorScheme.outline,
        strokeWidth: 1,
        dashPattern: const [4, 3],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NotedRadius.sm),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(NotedRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(NotedSpacing.md),
            child: viewType == NoteViewType.gridView
                ? _buildGridCard(context, previewContent, displayText)
                : _buildListCard(context, previewContent, displayText),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // GRID CARD
  // ----------------------------------------------------------

  Widget _buildGridCard(
    BuildContext context,
    String previewContent,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context),

        const SizedBox(height: NotedSpacing.sm),

        // Content
        Expanded(
          child: ClipRect(
            child: note.type == NoteType.text
                ? Text(
                    previewContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  )
                : ChecklistPreview(items: note.checklistItems),
          ),
        ),

        const SizedBox(height: NotedSpacing.sm),

        // Footer
        _buildFooter(context, displayText),
      ],
    );
  }

  // ----------------------------------------------------------
  // LIST CARD
  // ----------------------------------------------------------

  Widget _buildListCard(
    BuildContext context,
    String previewContent,
    String displayText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context),

        const SizedBox(height: NotedSpacing.sm),

        // Content
        note.type == NoteType.text
            ? Text(
                previewContent,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            : ChecklistPreview(items: note.checklistItems),

        const SizedBox(height: NotedSpacing.md),

        // Footer
        _buildFooter(context, displayText),
      ],
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Note color
        NotedColorDot(color: Color(note.colorValue)),

        const SizedBox(width: NotedSpacing.xs),

        // Title
        Expanded(
          child: Text(
            StringFormatter.capitalize(note.title),
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Pin
        if (note.isPinned == true)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.push_pin,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // FOOTER
  // ----------------------------------------------------------

  Widget _buildFooter(BuildContext context, String displayText) {
    return Row(
      children: [
        // Date / edited text
        Expanded(
          child: Text(
            displayText,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Reminder
        if (note.reminderAt != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.notifications_none,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

        // Optional actions
        if (trailing != null) trailing!,
      ],
    );
  }
}
````

## File: lib/core/features/notes/presentation/widgets/app_drawer.dart
````dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/auth/data/services/auth_service.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/archive_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/trash_screen.dart';
import 'package:provider/provider.dart';

enum DrawerItem { notes, archive, trash }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.selected});

  final DrawerItem selected;

  void _navigateTo(
    BuildContext context, {
    required DrawerItem destination,
    required Widget screen,
  }) {
    if (selected == destination) {
      Navigator.pop(context);
      return;
    }

    final notesProvider = context.read<NotesProvider>();

    notesProvider.updateSearchQuery('');

    Navigator.pop(context);

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<NotesProvider>.value(
          value: notesProvider,
          child: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.notes, size: 40),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'NOTED',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  'Organize your Ideas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          ListTile(
            selected: selected == DrawerItem.notes,
            leading: const Icon(Icons.notes_outlined),
            title: Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.notes,
              screen: const NotesScreen(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.archive,
            leading: const Icon(Icons.archive_outlined),
            title: Text(
              'Archived',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.archive,
              screen: const ArchiveScreen(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.trash,
            leading: const Icon(Icons.delete_outlined),
            title: Text(
              'Trash Bin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.trash,
              screen: const TrashScreen(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              Navigator.pop(context);

              try {
                await AuthService().signOut();
              } catch (e, stackTrace) {
                debugPrint('Logout error: $e');
                debugPrintStack(stackTrace: stackTrace);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to log out. Please try again.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
````

## File: lib/core/features/notes/data/repositories/note_repository_impl.dart
````dart
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repositories.dart';

import '../datasources/local_note_datasources.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepositories {
  NoteRepositoryImpl(this.datasource);

  final LocalNoteDatasources datasource;

  @override
  Future<void> addNote(Note note) async {
    await datasource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await datasource.deleteNote(id);
  }

  @override
  Future<List<Note>> getNotes() async {
    final models = await datasource.getNotes();

    return List<Note>.from(models);
  }

  @override
  Future<void> updateNote(Note note) async {
    await datasource.updateNote(NoteModel.fromEntity(note));
  }
}
````

## File: lib/core/features/notes/domain/entities/note.dart
````dart
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

enum NoteCategory { personal, study, work, ideas }

enum SortType { recent, alphabetical }

enum NoteStatus { active, archived, trashed }

enum NoteType { text, checklist }

enum ReminderRecurrence { none, daily, weekly, monthly, yearly }

enum NoteContentFormat { plainText, richText }

class Note {
  const Note({
    required this.title,
    required this.id,
    required this.content,
    required this.contentFormat,
    this.type = NoteType.text,
    this.checklistItems = const [],
    this.category = NoteCategory.personal,
    this.status = NoteStatus.active,
    this.colorValue = 0xFFFFFFFF,
    required this.createdAt,
    required this.lastEdited,
    this.reminderAt,
    this.notificationId,
    this.recurrence = ReminderRecurrence.none,
    this.isPinned = false,
  });

  final NoteCategory category;
  final List<ChecklistItem> checklistItems;
  final int colorValue;
  final String content;
  final NoteContentFormat contentFormat;
  final DateTime createdAt;
  final String id;
  final bool isPinned;
  final DateTime lastEdited;
  final DateTime? reminderAt;
  final ReminderRecurrence recurrence;
  final int? notificationId;
  final NoteStatus status;
  final String title;
  final NoteType type;

  static const Object _unset = Object();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteContentFormat? contentFormat,
    NoteType? type,
    List<ChecklistItem>? checklistItems,
    bool? isPinned,
    int? colorValue,
    NoteCategory? category,
    NoteStatus? status,
    DateTime? createdAt,
    DateTime? lastEdited,
    Object? reminderAt = _unset,
    ReminderRecurrence? recurrence,
    Object? notificationId = _unset,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentFormat: contentFormat ?? this.contentFormat,
      type: type ?? this.type,
      checklistItems: checklistItems ?? this.checklistItems,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
      reminderAt: reminderAt == _unset
          ? this.reminderAt
          : reminderAt as DateTime?,
      recurrence: recurrence ?? this.recurrence,
      notificationId: notificationId == _unset
          ? this.notificationId
          : notificationId as int?,
    );
  }
}
````

## File: lib/core/features/notes/data/models/note_model.dart
````dart
import '../../domain/entities/note.dart';
import 'package:notes_app/core/features/notes/data/models/checklist_item_model.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.contentFormat = NoteContentFormat.plainText,
    required super.type,
    super.checklistItems = const [],
    super.isPinned = false,
    super.category = NoteCategory.personal,
    super.status = NoteStatus.active,
    super.colorValue = 0xFFFFFFFF,
    required super.createdAt,
    required super.lastEdited,
    super.reminderAt,
    super.notificationId,
    super.recurrence = ReminderRecurrence.none,
  });

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      contentFormat: note.contentFormat,
      type: note.type,
      checklistItems: note.checklistItems,
      isPinned: note.isPinned,
      category: note.category,
      status: note.status,
      colorValue: note.colorValue,
      createdAt: note.createdAt,
      lastEdited: note.lastEdited,
      reminderAt: note.reminderAt,
      notificationId: note.notificationId,
      recurrence: note.recurrence,
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      contentFormat: NoteContentFormat.values.byName(
        map['contentFormat'] ?? 'plainText',
      ),
      type: NoteType.values.byName(map['type'] ?? 'text'),
      checklistItems:
          (map['checklistItems'] as List?)
              ?.map(
                (item) => ChecklistItemModel.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const [],

      isPinned: map['isPinned'] as bool? ?? false,
      category: NoteCategory.values.byName(map['category'] ?? 'personal'),
      status: NoteStatus.values.byName(map['status'] ?? 'active'),
      colorValue: map['colorValue'] as int? ?? 0xFFFFFFFF,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      lastEdited: map['lastEdited'] != null
          ? DateTime.parse(map['lastEdited'] as String)
          : DateTime.now(),
      reminderAt: map['reminderAt'] != null
          ? DateTime.parse(map['reminderAt'] as String)
          : null,
      notificationId: map['notificationId'] as int?,
      recurrence: ReminderRecurrence.values.byName(map['recurrence'] ?? 'none'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentFormat': contentFormat.name,
      'type': type.name,
      'checklistItems': checklistItems
          .map((item) => ChecklistItemModel.fromEntity(item).toMap())
          .toList(),

      'isPinned': isPinned,

      'category': category.name,
      'status': status.name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'notificationId': notificationId,
      'recurrence': recurrence.name,
    };
  }
}
````

## File: pubspec.yaml
````yaml
name: notes_app
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.10.8

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  intl: ^0.20.2
  uuid: ^4.6.0
  flutter_local_notifications: ^22.2.0
  timezone: ^0.11.1
  flutter_timezone: ^5.1.0
  dotted_border: ^3.1.0
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_localizations: 
    sdk: flutter
  flutter_quill: ^11.5.1
  firebase_core: ^4.15.0
  firebase_auth: ^6.7.0
  google_sign_in: ^7.2.0
  

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
  fonts:
   - family: SpaceMono
     fonts: 
      - asset: assets/fonts/SpaceMono-Regular.ttf
      - asset: assets/fonts/SpaceMono-Bold.ttf
        weight: 700
  

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
````

## File: lib/core/features/notes/presentation/provider/notes_provider.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/services/notification_service.dart';

enum NoteViewType { listView, gridView }

class NotesProvider extends ChangeNotifier {
  NotesProvider({required this.repositories});

  final NoteRepositories repositories;

  bool _isLoading = false;
  List<Note> _notes = [];
  String _searchQuery = '';
  NoteCategory? _selectedCategory;
  SortType _sortType = SortType.recent;
  NoteViewType _viewType = NoteViewType.gridView;

  NoteCategory? get selectedCategory => _selectedCategory;

  String get searchQuery => _searchQuery;

  List<Note> get notes => _notes;

  bool get isLoading => _isLoading;

  SortType get sortType => _sortType;

  List<Note> get activeNotes => _filterNotes(NoteStatus.active);

  List<Note> get archivedNotes => _filterNotes(NoteStatus.archived);

  List<Note> get trashedNotes => _filterNotes(NoteStatus.trashed);

  NoteViewType get viewType => _viewType;

  void updateViewType(NoteViewType type) {
    _viewType = type;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateSelectedCategory(NoteCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSortType(SortType value) {
    _sortType = value;
    _sortNotes();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notes = await repositories.getNotes();

      _sortNotes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    await repositories.addNote(note);

    _notes.add(note);

    _sortNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await repositories.deleteNote(id);

    _notes.removeWhere((note) => note.id == id);

    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = notes.indexWhere(
      (existingNote) => existingNote.id == note.id,
    );

    if (index != -1) {
      _notes[index] = note;
    }
    _sortNotes();
    notifyListeners();

    await repositories.updateNote(note);
  }

  Future<void> togglePin(Note note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);

    await updateNote(updatedNote);
  }

  Future<void> deleteForever(String id) async {
    await deleteNote(id);
  }

  Future<void> archiveNote(Note note) async {
    final archiveNote = note.copyWith(status: NoteStatus.archived);

    await updateNote(archiveNote);
  }

  Future<void> moveToTrash(Note note) async {
    if (note.notificationId != null) {
      await NotificationService.instance.cancelNotification(
        note.notificationId!,
      );
    }

    final trashedNote = note.copyWith(
      status: NoteStatus.trashed,
      reminderAt: null,
      notificationId: null,
    );

    await updateNote(trashedNote);
  }

  Future<void> restoreNote(Note note) async {
    final restoreNote = note.copyWith(status: NoteStatus.active);

    await updateNote(restoreNote);
  }

  Future<void> toggleCheckListItem(Note note, String itemId) async {
    final updatedItems = note.checklistItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    final updatedNote = note.copyWith(checklistItems: updatedItems);

    await updateNote(updatedNote);
  }

  Future<void> addCheckListItem(Note note, ChecklistItem item) async {
    final updatedItem = [...note.checklistItems, item];

    final updatedNote = note.copyWith(checklistItems: updatedItem);

    await updateNote(updatedNote);
  }

  Future<void> updateChecklistItem(Note note, ChecklistItem updatedItem) async {
    final updatedItems = note.checklistItems.map((currentItem) {
      if (currentItem.id == updatedItem.id) {
        return updatedItem;
      }

      return currentItem;
    }).toList();

    final updatedNote = note.copyWith(checklistItems: updatedItems);

    await updateNote(updatedNote);
  }

  Future<void> removeCheckListItem(Note note, String itemId) async {
    final updatedItem = note.checklistItems
        .where((item) => item.id != itemId)
        .toList();

    final updatedNote = note.copyWith(checklistItems: updatedItem);

    await updateNote(updatedNote);
  }

  List<Note> _filterNotes(NoteStatus status) {
    List<Note> filtered = _notes;
    filtered = filtered.where((note) => note.status == status).toList();

    if (_selectedCategory != null) {
      filtered = filtered
          .where((note) => note.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      filtered = filtered.where((note) {
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content.toLowerCase().contains(query);

        final matchesChecklist = note.checklistItems.any(
          (item) => item.text.toLowerCase().contains(query),
        );

        return matchesTitle || matchesContent || matchesChecklist;
      }).toList();
    }
    return filtered;
  }

  void _sortNotes() {
    switch (_sortType) {
      case SortType.recent:
        _notes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.lastEdited.compareTo(a.lastEdited);
        });
        break;
      case SortType.alphabetical:
        _notes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return a.title.compareTo(b.title);
        });
        break;
    }
  }
}
````

## File: lib/core/features/notes/presentation/screens/add_note_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_header.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_toolbar.dart';

import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/services/rich_text_converter.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/utils/id_generator.dart';
import 'package:notes_app/core/utils/string_formatter.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key, required this.type});

  final NoteType type;

  @override
  State<StatefulWidget> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final now = DateTime.now();
  NoteCategory selectedCategory = NoteCategory.personal;
  Color selectedColor = Colors.grey;
  ReminderRecurrence selectedRecurrence = ReminderRecurrence.none;
  DateTime? selectedReminder;

  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _focusedItemId;
  final _formkey = GlobalKey<FormState>();
  List<ChecklistItem> _items = [];
  late final QuillController _quillController;
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _quillController = QuillController.basic();
  }

  String _getNotificationBody() {
    if (widget.type == NoteType.text) {
      return RichTextConverter.documentToPlainText(_quillController.document);
    }

    return _descriptionController.text.trim();
  }

  void _toggleFormat(Attribute attribute) {
    final style = _quillController.getSelectionStyle();

    final isActive = style.containsKey(attribute.key);

    if (isActive) {
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _quillController.formatSelection(attribute);
    }
  }

  bool _hasContent() {
    final title = _titleController.text.trim();

    final content = _quillController.document.toPlainText().trim();
    final description = _descriptionController.text.trim();

    return title.isNotEmpty ||
        content.isNotEmpty ||
        description.isNotEmpty ||
        _items.isNotEmpty;
  }

  Future<void> _saveNote() async {
    if (!_hasContent()) {
      return;
    }
    final content = widget.type == NoteType.text
        ? RichTextConverter.documentToJsonString(_quillController.document)
        : _descriptionController.text;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final notesProvider = context.read<NotesProvider>();
    final recurrence = selectedReminder == null
        ? ReminderRecurrence.none
        : selectedRecurrence;
    int? notificationId;

    if (_formkey.currentState!.validate()) {
      if (selectedReminder != null) {
        try {
          notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
            1 << 31,
          );

          await NotificationService.instance.scheduleNotification(
            id: notificationId,
            title: _titleController.text,
            body: _getNotificationBody(),
            scheduledTime: selectedReminder!,
            recurrence: selectedRecurrence,
          );
          // await NotificationService.instance.showNotification();
        } catch (e, stackTrace) {
          debugPrint('Notification error: $e');
          debugPrintStack(stackTrace: stackTrace);
          messenger.showSnackBar(
            const SnackBar(content: Text('Unable to schedule reminder')),
          );

          return;
        }
      }
      final note = Note(
        title: _titleController.text,
        id: IdGenerator.generator(),
        checklistItems: _items,
        content: content,
        category: selectedCategory,
        colorValue: selectedColor.toARGB32(),
        createdAt: now,
        lastEdited: now,
        type: widget.type,
        reminderAt: selectedReminder,
        notificationId: notificationId,
        recurrence: recurrence,
        contentFormat: widget.type == NoteType.text
            ? NoteContentFormat.richText
            : NoteContentFormat.plainText,
      );
      await notesProvider.addNote(note);
      if (!mounted) return;
      navigator.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTextNote = widget.type == NoteType.text;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  NoteEditorHeader(
                    title: widget.type == NoteType.text
                        ? 'Text Note'
                        : 'Checklist',
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onSave: _saveNote,
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: NotedSpacing.sm,
                      children: [
                        ...NoteCategory.values.map((category) {
                          return CategoryClip(
                            onSelectedCategory: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                            selectedCategory: selectedCategory,
                            label: StringFormatter.capitalize(category.name),
                            category: category,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Theme.of(context).textTheme.titleLarge,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (widget.type == NoteType.text)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(NotedRadius.sm),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            textAlignVertical: TextAlignVertical.top,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Add Description',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              border: InputBorder.none,
                            ),
                          ),

                          Expanded(
                            child: ChecklistEditor(
                              items: _items,
                              focusedItemId: _focusedItemId,

                              onAdd: () {
                                final id = IdGenerator.generator();

                                setState(() {
                                  _items.add(
                                    ChecklistItem(
                                      id: id,
                                      text: '',
                                      isCompleted: false,
                                    ),
                                  );

                                  _focusedItemId = id;
                                });
                              },

                              onRemove: (id) {
                                setState(() {
                                  _items.removeWhere((item) => item.id == id);
                                });
                              },

                              onToggle: (id) {
                                setState(() {
                                  _items = _items.map((item) {
                                    if (item.id == id) {
                                      return item.copyWith(
                                        isCompleted: !item.isCompleted,
                                      );
                                    }

                                    return item;
                                  }).toList();
                                });
                              },

                              onUpdate: (updatedItem) {
                                setState(() {
                                  _items = _items.map((item) {
                                    if (item.id == updatedItem.id) {
                                      return updatedItem;
                                    }

                                    return item;
                                  }).toList();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(NotedRadius.sm),
                    ),
                    child: NoteEditorToolbar(
                      selectedColor: selectedColor,
                      onSelectedColor: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      recurrence: selectedRecurrence,
                      onSelectedRecurrence: (recurrence) {
                        setState(() {
                          selectedRecurrence = recurrence;
                        });
                      },
                      reminder: selectedReminder,
                      onSelectedReminder: (reminder) {
                        setState(() {
                          selectedReminder = reminder;
                        });
                      },
                      controller: isTextNote ? _quillController : null,
                      onFormat: (attribute) {
                        _toggleFormat(attribute);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
````

## File: lib/main.dart
````dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/core/features/auth/presentation/screens/auth_gate.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: NotedTheme.light,
      darkTheme: NotedTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
````

## File: lib/core/features/notes/presentation/screens/edit_note_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_header.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/services/rich_text_converter.dart';
import 'package:notes_app/core/theme/app_radius.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/utils/id_generator.dart';
import 'package:notes_app/core/utils/string_formatter.dart';
import 'package:provider/provider.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late NoteCategory selectedCategory;
  late Color selectedColor;
  late ReminderRecurrence selectedRecurrence;
  late DateTime? selectedReminder;

  late final TextEditingController _contentController;
  late final TextEditingController _descriptionController;
  late String? _focusedItemId;
  final _formKey = GlobalKey<FormState>();
  late List<ChecklistItem> _items;
  late final QuillController _quillController;
  late final TextEditingController _titleController;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    if (widget.note.type == NoteType.text) {
      _quillController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note.title);

    _contentController = TextEditingController();
    if (widget.note.type == NoteType.text) {
      final document = widget.note.contentFormat == NoteContentFormat.plainText
          ? RichTextConverter.plainTextToDocument(widget.note.content)
          : RichTextConverter.jsonToDocument(widget.note.content);

      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    _descriptionController = TextEditingController(
      text: widget.note.type == NoteType.checklist ? widget.note.content : '',
    );

    selectedCategory = widget.note.category;
    selectedColor = Color(widget.note.colorValue);
    selectedReminder = widget.note.reminderAt;
    selectedRecurrence = widget.note.recurrence;

    _items = List<ChecklistItem>.from(widget.note.checklistItems);
    _focusedItemId = widget.note.id;
  }

  String _getNotificationBody() {
    if (widget.note.type == NoteType.text) {
      return RichTextConverter.documentToPlainText(_quillController.document);
    }

    return _descriptionController.text.trim();
  }

  bool _isAttributeActive(Attribute attribute) {
    final style = _quillController.getSelectionStyle();

    return style.containsKey(attribute.key);
  }

  void _toggleAttribute(Attribute attribute) {
    final isActive = _isAttributeActive(attribute);

    if (isActive) {
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _quillController.formatSelection(attribute);
    }
  }

  bool _hasContent() {
    final title = _titleController.text.trim();

    if (widget.note.type == NoteType.text) {
      final content = _quillController.document.toPlainText().trim();

      return title.isNotEmpty || content.isNotEmpty;
    }

    final description = _descriptionController.text.trim();

    return title.isNotEmpty || description.isNotEmpty || _items.isNotEmpty;
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_hasContent()) {
      return;
    }

    final notesProvider = context.read<NotesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final content = widget.note.type == NoteType.text
        ? RichTextConverter.documentToJsonString(_quillController.document)
        : _descriptionController.text;

    // A recurrence without a reminder is invalid.
    final recurrence = selectedReminder == null
        ? ReminderRecurrence.none
        : selectedRecurrence;

    try {
      int? notificationId = widget.note.notificationId;

      /*
       * CASE 1:
       * Reminder was removed.
       */
      if (selectedReminder == null) {
        if (notificationId != null) {
          await NotificationService.instance.cancelNotification(notificationId);
        }

        notificationId = null;
      }
      /*
       * CASE 2:
       * A reminder exists.
       *
       * We use the existing notification ID when possible.
       * Scheduling with the same ID updates/replaces the
       * existing pending notification.
       */
      else {
        notificationId ??= DateTime.now().millisecondsSinceEpoch.remainder(
          1 << 31,
        );

        await NotificationService.instance.scheduleNotification(
          id: notificationId,
          title: _titleController.text.trim(),
          body: _getNotificationBody(),
          scheduledTime: selectedReminder!,
          recurrence: recurrence,
        );
      }

      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim(),
        content: content,
        contentFormat: widget.note.type == NoteType.text
            ? NoteContentFormat.richText
            : widget.note.contentFormat,
        checklistItems: widget.note.type == NoteType.checklist
            ? _items
            : widget.note.checklistItems,
        category: selectedCategory,
        colorValue: selectedColor.toARGB32(),
        lastEdited: DateTime.now(),
        reminderAt: selectedReminder,
        notificationId: notificationId,
        recurrence: recurrence,
      );

      await notesProvider.updateNote(updatedNote);

      if (!mounted) return;

      navigator.pop(true);
    } catch (e, stackTrace) {
      debugPrint('Edit note error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to update note')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTextNote = widget.note.type == NoteType.text;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NotedSpacing.md),
          child: Container(
            decoration: BoxDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NoteEditorHeader(
                    title: isTextNote ? 'Text Note' : 'Checklist',
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onSave: _saveNote,
                  ),

                  const SizedBox(height: 8),

                  /*
                   * CATEGORY
                   */
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: NotedSpacing.sm,
                      children: [
                        ...NoteCategory.values.map((category) {
                          return CategoryClip(
                            selectedCategory: selectedCategory,
                            label: StringFormatter.capitalize(category.name),
                            category: category,
                            onSelectedCategory: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  /*
                   * TITLE
                   */
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.titleLarge,

                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Theme.of(context).textTheme.titleLarge,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /*
                   * CONTENT / CHECKLIST
                   */
                  if (isTextNote)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(NotedRadius.sm),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    TextField(
                      controller: _descriptionController,
                      textAlignVertical: TextAlignVertical.top,

                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Add Description',
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: NotedSpacing.md),

                    Expanded(
                      child: ChecklistEditor(
                        items: _items,
                        focusedItemId: _focusedItemId,
                        onAdd: () {
                          final id = IdGenerator.generator();
                          setState(() {
                            _items.add(
                              ChecklistItem(
                                id: id,
                                text: '',
                                isCompleted: false,
                              ),
                            );
                            _focusedItemId = id;
                          });
                        },
                        onRemove: (id) {
                          setState(() {
                            _items.removeWhere((item) => item.id == id);
                          });
                        },
                        onToggle: (id) {
                          setState(() {
                            _items = _items.map((item) {
                              if (item.id == id) {
                                return item.copyWith(
                                  isCompleted: !item.isCompleted,
                                );
                              }

                              return item;
                            }).toList();
                          });
                        },
                        onUpdate: (updatedItem) {
                          setState(() {
                            _items = _items.map((item) {
                              if (item.id == updatedItem.id) {
                                return updatedItem;
                              }

                              return item;
                            }).toList();
                          });
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  /*
                   * TOOLBAR
                   */
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(NotedRadius.sm),
                    ),
                    child: NoteEditorToolbar(
                      selectedColor: selectedColor,
                      onSelectedColor: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },

                      reminder: selectedReminder,
                      onSelectedReminder: (reminder) {
                        setState(() {
                          selectedReminder = reminder;

                          if (reminder == null) {
                            selectedRecurrence = ReminderRecurrence.none;
                          }
                        });
                      },

                      recurrence: selectedRecurrence,
                      onSelectedRecurrence: (recurrence) {
                        setState(() {
                          selectedRecurrence = recurrence;
                        });
                      },
                      controller: isTextNote ? _quillController : null,
                      onFormat: (attribute) {
                        _toggleAttribute(attribute);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
````

## File: lib/core/features/notes/presentation/screens/notes_screen.dart
````dart
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/add_note_screen.dart';

import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/create_note_bottom_sheet.dart';

import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/notes_view_options.dart';

import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.activeNotes;

    return Scaffold(
      //App Drawer
      drawer: AppDrawer(selected: DrawerItem.notes),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: _isSearching
            //Searching feature
            ? NoteSearchfield(
                onChanged: context.read<NotesProvider>().updateSearchQuery,
              )
            : Text('NOTED', style: Theme.of(context).textTheme.titleLarge),

        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: const Icon(Icons.search_outlined),
            ),

          if (_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
                context.read<NotesProvider>().updateSearchQuery('');
              },
              icon: const Icon(Icons.close),
            ),
          IconButton(
            onPressed: () {
              final provider = context.read<NotesProvider>();
              provider.updateViewType(
                provider.viewType == NoteViewType.gridView
                    ? NoteViewType.listView
                    : NoteViewType.gridView,
              );
            },
            icon: Icon(
              provider.viewType == NoteViewType.gridView
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
          ),
          //Sorting feature
          PopupMenuButton<SortType>(
            onSelected: (value) {
              context.read<NotesProvider>().updateSortType(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortType.recent,
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text(
                      'Recently Edited',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortType.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text(
                      'Alphabetical',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.sort),
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  //Filter by category
                  child: CategoryFilterbar(
                    selectedCategory: provider.selectedCategory,
                    onChanged: provider.updateSelectedCategory,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: provider.notes.isEmpty
                      ? const Center(child: Text('No notes yet!'))
                      : notes.isEmpty
                      ? const Center(child: Text('No notes found!'))
                      : NotesViewOptions(
                          onLeftSwipeText: 'Delete',
                          notes: notes,
                          onLeftSwipe: (note) async {
                            await provider.moveToTrash(note);
                          },
                          onRghtSwipeText: 'Archive',
                          onRightSwipe: (note) async {
                            await provider.archiveNote(note);
                          },
                        ),
                ),
              ],
            ),
      /* ADD NOTE 
            Text/Checklist
             */
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final type = await showModalBottomSheet<NoteType>(
            context: context,
            builder: (_) => const CreateNoteBottomSheet(),
          );

          if (type == null) return;

          if (!context.mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider<NotesProvider>.value(
                value: context.read<NotesProvider>(),
                child: AddNoteScreen(type: type),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
````
