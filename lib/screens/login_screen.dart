import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../widgets/error_box.dart';
import '../widgets/loading_button.dart';
import 'home_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _emailPhone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.instance.post('/api/auth/login', {
        'emailOrPhone': _emailPhone.text.trim(),
        'password': _password.text,
      }, auth: false);

      final business = (res['business'] ?? {}) as Map<String, dynamic>;
      final user = (res['user'] ?? {}) as Map<String, dynamic>;
      await SessionService.save(
        token: res['token'].toString(),
        businessPublicId: business['publicId'].toString(),
        businessName: business['businessName']?.toString() ?? 'My Business',
        userName: user['fullName']?.toString() ?? 'User',
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 64),
                    const SizedBox(height: 12),
                    const Text('Login to Smart Khata', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ErrorBox(_error),
                    TextFormField(
                      controller: _emailPhone,
                      decoration: const InputDecoration(labelText: 'Email or Phone'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 18),
                    LoadingButton(loading: _loading, text: 'Login', onPressed: _login),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                      child: const Text('Create new account'),
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
