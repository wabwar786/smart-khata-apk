import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  final String token;
  final String businessPublicId;
  final String businessName;
  final String userName;

  const SessionData({
    required this.token,
    required this.businessPublicId,
    required this.businessName,
    required this.userName,
  });
}

class SessionService {
  static const _tokenKey = 'token';
  static const _businessIdKey = 'businessPublicId';
  static const _businessNameKey = 'businessName';
  static const _userNameKey = 'userName';

  static Future<void> save({
    required String token,
    required String businessPublicId,
    required String businessName,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_businessIdKey, businessPublicId);
    await prefs.setString(_businessNameKey, businessName);
    await prefs.setString(_userNameKey, userName);
  }

  static Future<SessionData?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final businessId = prefs.getString(_businessIdKey);
    if (token == null || token.isEmpty || businessId == null || businessId.isEmpty) {
      return null;
    }
    return SessionData(
      token: token,
      businessPublicId: businessId,
      businessName: prefs.getString(_businessNameKey) ?? 'My Business',
      userName: prefs.getString(_userNameKey) ?? 'User',
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_businessIdKey);
    await prefs.remove(_businessNameKey);
    await prefs.remove(_userNameKey);
  }
}
