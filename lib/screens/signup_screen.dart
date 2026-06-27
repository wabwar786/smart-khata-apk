import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../widgets/error_box.dart';
import '../widgets/loading_button.dart';
import 'home_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _businessName = TextEditingController();
  final _businessType = TextEditingController();
  final _city = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _businessName.dispose();
    _businessType.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.instance.post('/api/auth/signup', {
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'phoneNumber': _phone.text.trim(),
        'password': _password.text,
        'businessName': _businessName.text.trim(),
        'businessType': _businessType.text.trim(),
        'city': _city.text.trim(),
      }, auth: false);

      final business = (res['business'] ?? {}) as Map<String, dynamic>;
      final user = (res['user'] ?? {}) as Map<String, dynamic>;
      await SessionService.save(
        token: res['token'].toString(),
        businessPublicId: business['publicId'].toString(),
        businessName: business['businessName']?.toString() ?? _businessName.text.trim(),
        userName: user['fullName']?.toString() ?? _fullName.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ErrorBox(_error),
                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 20),
                const Text('Business Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _businessName,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                  validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _businessType,
                  decoration: const InputDecoration(labelText: 'Business Type'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 20),
                LoadingButton(loading: _loading, text: 'Create Account', onPressed: _signup),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
