import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_service.dart';
import '../utils/json_utils.dart';
import '../widgets/error_box.dart';
import '../widgets/loading_button.dart';
import '../widgets/pro_widgets.dart';
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

      final token = JsonUtils.str(res['token']);
      final business = JsonUtils.map(res['business']);
      final user = JsonUtils.map(res['user']);
      await SessionService.save(
        token: token,
        businessPublicId: JsonUtils.str(business['publicId']),
        businessName: JsonUtils.str(business['businessName'], 'My Business'),
        userName: JsonUtils.str(user['fullName'], 'User'),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppBrandMark(size: 64)),
                const SizedBox(height: 14),
                const Text('Start your business khata', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Create owner account and first business.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 22),
                ErrorBox(_error),
                TextFormField(controller: _fullName, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)), validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)), obscureText: true, validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null),
                const SizedBox(height: 18),
                TextFormField(controller: _businessName, decoration: const InputDecoration(labelText: 'Business Name', prefixIcon: Icon(Icons.storefront_outlined)), validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _businessType, decoration: const InputDecoration(labelText: 'Business Type', prefixIcon: Icon(Icons.category_outlined))),
                const SizedBox(height: 12),
                TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined))),
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
