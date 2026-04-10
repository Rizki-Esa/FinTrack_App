import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleButton extends StatelessWidget {
  final Function(String accessToken) onSuccess;

  const GoogleButton({
    super.key,
    required this.onSuccess,
  });

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
      );

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        debugPrint("ACCESS TOKEN NULL");
        return;
      }

      // 🔥 kirim ke parent (AuthScreen)
      onSuccess(accessToken);

    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Image.asset(
          'assets/images/google.png',
          height: 20,
        ),
        label: const Text(
          'Continue with Google',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}