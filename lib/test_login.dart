import 'package:shared_preferences/shared_preferences.dart';

class TestLogin {
  static Future<void> setTestToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', 'test_token_123');
    print('Test token saved');
  }

  static Future<void> removeTestToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    print('Test token removed');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Current token: $token');
    return token;
  }
}
