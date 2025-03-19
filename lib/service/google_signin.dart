import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: '531262194558-8a4rabvgliort2tkvp7dupaoien6snd6.apps.googleusercontent.com', // Thay bằng CLIENT_ID thực tế của bạn
  );

  static GoogleSignIn get instance => _googleSignIn;
}