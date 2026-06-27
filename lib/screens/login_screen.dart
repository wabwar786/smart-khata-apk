import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../utils/json_utils.dart';
import '../widgets/error_box.dart';
import '../widgets/loading_button.dart';
import '../widgets/pro_widgets.dart';
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

  Future<Map<String, dynamic>> _resolveBusiness(String token, Map<String, dynamic> loginResponse) async {
    final directBusiness = JsonUtils.map(loginResponse['business']);
    if (JsonUtils.str(directBusiness['publicId']).isNotEmpty) return directBusiness;

    final listResponse = await ApiClient.instance.getWithToken('/api/auth/businesses', token);
    final businesses = JsonUtils.list(listResponse['data']);
    if (businesses.isEmpty) {
      throw ApiException('Login successful, but no business is assigned to this user.');
    }
    return JsonUtils.map(businesses.first);
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

      final token = JsonUtils.str(res['token']);
      if (token.isEmpty) throw ApiException('Login response missing token.');
      final user = JsonUtils.map(res['user']);
      final business = await _resolveBusiness(token, res);

      final businessPublicId = JsonUtils.str(business['publicId']);
      if (businessPublicId.isEmpty) throw ApiException('Business public id is missing.');

      await SessionService.save(
        token: token,
        businessPublicId: businessPublicId,
        businessName: JsonUtils.str(business['businessName'], 'My Business'),
        userName: JsonUtils.str(user['fullName'], 'User'),
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
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppBrandMark(size: 72)),
                    const SizedBox(height: 18),
                    const Text('Welcome back', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    const Text('Login to manage sales, customers, stock and payments.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                    const SizedBox(height: 26),
                    ErrorBox(_error),
                    TextFormField(
                      controller: _emailPhone,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), labelText: 'Email or Phone'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded), labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    LoadingButton(loading: _loading, text: 'Login', onPressed: _login),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
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
