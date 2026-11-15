import 'palette.dart';
import 'package:flutter/material.dart';
import '../domain/auth.dart';
import '../domain/visits.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key, required this.auth, required this.onSignedIn});
  final AuthRepository auth;
  final void Function(String, Role) onSignedIn;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;
  String? error;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void submit() {
    final role = widget.auth.signIn(username.text, password.text);
    if (role == null) {
      setState(() => error = 'Check your username and password.');
      return;
    }
    widget.onSignedIn(username.text.trim().toLowerCase(), role);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: medicalTeal,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.medical_services_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Aesthetic Daily',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Sign in to your workspace'),
                  const SizedBox(height: 28),
                  TextField(
                    controller: username,
                    autofillHints: const [AutofillHints.username],
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    autofillHints: const [AutofillHints.password],
                    obscureText: hidden,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: error,
                      suffixIcon: IconButton(
                        tooltip: hidden ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => hidden = !hidden),
                        icon: Icon(
                          hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(onPressed: submit, child: const Text('Sign in')),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
