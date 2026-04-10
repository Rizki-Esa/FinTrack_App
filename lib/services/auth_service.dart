import 'package:dio/dio.dart';
import 'api_service.dart';
import 'token_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as mobile;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {

  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      ) async {

    final res = await ApiService.register({
      "name": name,
      "email": email,
      "password": password,
    });

    String token = res.data["token"];
    await TokenStorage.saveToken(token);

    return res.data;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {

    final res = await ApiService.login({
      "email": email,
      "password": password,
    });

    String token = res.data["token"];

    await TokenStorage.saveToken(token);

    return res.data;
  }

  static Future<void> logout() async {
    await TokenStorage.clear();
  }

  static Future<void> forgotPassword(String email) async {

    await ApiService.forgotPassword(email);

  }

  static Future<void> resetPassword(
      String token,
      String newPassword,
      ) async {

    await ApiService.resetPassword(token, newPassword);

  }

  // ================= GOOGLE MOBILE =================

  static Future<String?> _getGoogleAccessTokenMobile() async {
    final googleSignIn = mobile.GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
    );

    final account = await googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;

    return auth.accessToken; // ✅ INI YANG DIPAKAI
  }

  // ================= GOOGLE BACKEND LOGIN =================

  static Future<Map<String, dynamic>> loginWithGoogleToken(
      String accessToken,
      ) async {

    print("🔥 SENDING ACCESS TOKEN: $accessToken");

    try {
      final res = await ApiService.dio.post(
        "/google-login",
        data: {
          "access_token": accessToken,
        },
      );

      print("✅ BACKEND RESPONSE: ${res.data}");

      final token = res.data["token"];
      await TokenStorage.saveToken(token);

      return res.data;

    } catch (e) {
      print("❌ BACKEND ERROR: $e");
      rethrow;
    }
  }

  // ================= UNIVERSAL GOOGLE LOGIN =================

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    String? accessToken;

    if (kIsWeb) {
      throw Exception("Web version belum diubah ke access_token flow");
    } else {
      accessToken = await _getGoogleAccessTokenMobile();
    }

    if (accessToken == null) {
      throw Exception("Google Sign-In cancelled");
    }

    return await loginWithGoogleToken(accessToken);
  }

  // ================= LOGOUT GOOGLE =================

  static Future<void> logoutGoogle() async {
    if (!kIsWeb) {
      final mobile.GoogleSignIn googleSignIn = mobile.GoogleSignIn();
      await googleSignIn.signOut();
    }
  }
}