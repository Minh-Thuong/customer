import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static final String _tokenKey = 'auth_token';

  // luu token vào shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    try {
      final decodedToken = JwtDecoder.decode(token);
      final int expiryTimestamp = decodedToken['exp'];
      final expiryTime =
          DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
      await prefs.setString('token_expiry', expiryTime.toIso8601String());

      if (decodedToken.containsKey('sub')) {
        await prefs.setString("user_email", decodedToken['sub']);
      }
      if (decodedToken.containsKey('scope')) {
        await prefs.setString('user_scope', decodedToken['scope']);
      }
    } catch (e) {
      print("Error decoding token or saving expiry: $e");
    }
  }
  // doc token da luu

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // xóa token
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('token_expiry');
    await prefs.remove('user_email');
    await prefs.remove('user_scope');
  }
}
