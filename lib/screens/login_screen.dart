import 'package:flutter/material.dart';

import '../config.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../utils/json_utils.dart';
import '../widgets/error_box.dart';
import '../widgets/sk_widgets.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String _error = '';
  String _normalizedPhone = '';
  String _devOtp = '';

  @override
  void dispose() { _phone.dispose(); _otp.dispose(); super.dispose(); }

  String _normalize(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (!digits.startsWith('92')) digits = '92$digits';
    return digits;
  }

  Future<Map<String, dynamic>> _resolveBusiness(String token, Map<String, dynamic> res) async {
    final directBusiness = JsonUtils.map(res['business']);
    if (JsonUtils.str(directBusiness['publicId']).isNotEmpty) return directBusiness;
    final listResponse = await ApiClient.instance.getWithToken('/api/auth/businesses', token);
    final businesses = JsonUtils.list(listResponse['data']);
    if (businesses.isEmpty) throw ApiException('Login successful, but no business found.');
    return JsonUtils.map(businesses.first);
  }

  Future<void> _requestOtp() async {
    final phone = _normalize(_phone.text);
    if (phone.length < 12) { setState(() => _error = 'Please enter valid WhatsApp number.'); return; }
    setState(() { _loading = true; _error = ''; _devOtp = ''; });
    try {
      final res = await ApiClient.instance.post('/api/auth/request-otp', {'phoneNumber': phone, 'countryCode': AppConfig.defaultCountryCode}, auth: false);
      setState(() {
        _normalizedPhone = phone;
        _otpSent = true;
        _devOtp = JsonUtils.str(res['devOtp']);
        if (_devOtp.isNotEmpty) _otp.text = _devOtp;
      });
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _verifyOtp() async {
    if (_otp.text.trim().length < 4) { setState(() => _error = 'Please enter OTP.'); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.post('/api/auth/verify-otp', {'phoneNumber': _normalizedPhone, 'otp': _otp.text.trim()}, auth: false);
      final token = JsonUtils.str(res['token']);
      if (token.isEmpty) throw ApiException('Login response missing token.');
      final user = JsonUtils.map(res['user']);
      final business = await _resolveBusiness(token, res);
      await SessionService.save(
        token: token,
        businessPublicId: JsonUtils.str(business['publicId']),
        businessName: JsonUtils.str(business['businessName'], 'My Business'),
        userName: JsonUtils.str(user['fullName'], 'User'),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 18),
              const Row(children: [SkLogo(size: 54), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Smart Khata', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)), Text('Business khata, POS & inventory', style: AppText.small)]))]),
              const SizedBox(height: 44),
              Text(_otpSent ? 'Enter OTP' : 'Enter WhatsApp Number', style: AppText.h1),
              const SizedBox(height: 8),
              Text(_otpSent ? 'OTP sent on WhatsApp to +$_normalizedPhone' : 'Secure and easy login facility', style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 26),
              ErrorBox(_error),
              if (!_otpSent) ...[
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_android_rounded), prefixText: '+92 ', labelText: 'WhatsApp mobile number', hintText: '3001234567'),
                ),
                const SizedBox(height: 18),
                PillButton(text: _loading ? 'Sending...' : 'SEND OTP', icon: Icons.send_rounded, onTap: _loading ? null : _requestOtp),
              ] else ...[
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(counterText: '', prefixIcon: Icon(Icons.lock_clock_rounded), labelText: 'OTP Code'),
                ),
                if (_devOtp.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Demo OTP: $_devOtp', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800))),
                const SizedBox(height: 18),
                PillButton(text: _loading ? 'Verifying...' : 'VERIFY & LOGIN', icon: Icons.verified_rounded, onTap: _loading ? null : _verifyOtp),
                const SizedBox(height: 10),
                TextButton(onPressed: _loading ? null : _requestOtp, child: const Text('Resend OTP')),
                TextButton(onPressed: _loading ? null : () => setState(() { _otpSent = false; _otp.clear(); _error = ''; }), child: const Text('Change number')),
              ],
              const Spacer(),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(18)), child: const Text('Your WhatsApp API key is not stored in APK. App calls Smart Khata backend, and backend sends OTP through WhatsApp engine securely.', style: AppText.small)),
            ]),
          ),
        ),
      ),
    );
  }
}
