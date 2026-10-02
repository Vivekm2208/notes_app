import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Screen')),
      body: Center(
        child: TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotesScreen()),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
