import 'package:flutter/material.dart';
import '../domain/visits.dart';
import '../features/auth/domain/usecases/sign_in_user.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key, required this.signIn, required this.onSignedIn});
  final SignInUser signIn;
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
    final role = widget.signIn(username.text, password.text);
    if (role == null) {
      setState(() => error = 'Check your username and password.');
      return;
    }
    widget.onSignedIn(username.text.trim().toLowerCase(), role);
  }

  void quickSignIn(String name, String passcode) {
    username.text = name;
    password.text = passcode;
    submit();
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      child: Image(
                        image: AssetImage('assets/images/ipc_logo.jpeg'),
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                      ),
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
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Quick demo access',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.medical_services_outlined),
                        label: const Text('Representative'),
                        onPressed: () => quickSignIn('rep', 'Rep1234'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.supervisor_account_outlined),
                        label: const Text('Manager'),
                        onPressed: () => quickSignIn('manager', 'Manager1234'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.dashboard_outlined),
                        label: const Text('CEO'),
                        onPressed: () => quickSignIn('ceo', 'Ceo1234'),
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
