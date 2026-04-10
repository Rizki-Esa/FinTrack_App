import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage.dart';

class AuthController extends ChangeNotifier {

  bool isAuthenticated = false;
  bool isLoading = false;
  bool isGoogleLogin = false;

  Map<String, dynamic>? user;

  Future<bool> register(
      String name,
      String email,
      String password,
      ) async {

    try {

      isLoading = true;
      notifyListeners();

      final data = await AuthService.register(name, email, password);

      user = data["user"];
      isAuthenticated = true;

      return true;

    } on DioException catch (e) {

      final msg =
          e.response?.data["error"] ?? "Registration failed";

      throw msg; // penting agar UI bisa tampilkan dialog

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await AuthService.signInWithGoogle();

      user = data["user"];
      isAuthenticated = true;

      isGoogleLogin = true; // ✅ FIX PENTING

      return true;

    } catch (e) {
      print("Google login error: $e");
      return false;

    } finally {
      isLoading = false;

      // 🔥 delay notify biar tidak bentrok mouse tracker
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> checkLogin() async {

    final token = await TokenStorage.getToken();

    if (token == null) {
      isAuthenticated = false;
    } else {

      bool expired = JwtDecoder.isExpired(token);

      if (expired) {

        await TokenStorage.clear();
        isAuthenticated = false;

      } else {

        Map<String, dynamic> decoded = JwtDecoder.decode(token);

        user = {
          "id": decoded["user_id"],
        };

        isAuthenticated = true;
      }
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {

    try {
      isLoading = true;
      notifyListeners();

      final data = await AuthService.login(email, password);

      user = data["user"];

      isGoogleLogin = false; // ✅ penting

      isAuthenticated = true;

      return true;

    } catch (e) {
      return false;

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {

    if (isGoogleLogin) {
      await AuthService.logoutGoogle(); // 🔥 logout Google
    }

    await AuthService.logout(); // 🔥 logout backend (token)

    isAuthenticated = false;
    isGoogleLogin = false;
    user = null;

    notifyListeners();
  }
}