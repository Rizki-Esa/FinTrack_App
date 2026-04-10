import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../services/api_service.dart';

class ProfileService {
  // Load profile
  static Future<Map<String, dynamic>?> loadProfile(int userId) async {
    try {
      final response = await ApiService.getProfile(userId);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("Load profile failed: $e");
    }
    return null;
  }

  // Update profile (name & bio)
  static Future<bool> saveProfile(int userId, String name, String bio) async {
    try {
      final response = await ApiService.updateProfile(userId, {
        "name": name,
        "bio": bio,
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Save profile failed: $e");
      return false;
    }
  }

  // Update email
  static Future<bool> saveEmail(int userId, String email) async {
    try {
      final response = await ApiService.updateProfile(userId, {"email": email});
      return response.statusCode == 200;

    } on DioException catch (e) {

      final msg = e.response?.data["error"] ?? "Update email failed";
      throw msg;

    }
  }
  // Update phone
  static Future<bool> savePhone(int userId, String phone) async {
    try {
      final response = await ApiService.updateProfile(userId, {"phone": phone});
      return response.statusCode == 200;
    } catch (e) {
      print("Save phone failed: $e");
      return false;
    }
  }


  static Future<bool> validateOldPassword(int userId, String oldPassword) async {
    try {
      final response = await ApiService.ProfileCheckPassword(userId, oldPassword);

      if (response.statusCode == 200) {
        return response.data['valid'] ?? false;
      }

      return false;
    } catch (e) {
      print("Validate old password failed: $e");
      return false;
    }
  }

  static Future<bool> updatePassword(int userId, String oldPassword, String newPassword) async {
    // validasi old password dulu
    final isValid = await validateOldPassword(userId, oldPassword);
    if (!isValid) {
      print("Old password is incorrect");
      return false;
    }

    try {
      final response = await ApiService.updateProfile(userId, {
        "password": oldPassword,
        "new_password": newPassword,
      });

      return response.statusCode == 200;
    } catch (e) {
      print("Change password failed: $e");
      return false;
    }
  }

  // Upload profile image
  static Future<bool> uploadImage(int userId, Uint8List bytes) async {
    try {
      final response = await ApiService.uploadProfileImage(userId, bytes);
      return response.statusCode == 200;
    } catch (e) {
      print("Upload image failed: $e");
      return false;
    }
  }

  static Future<bool> savePreferences(int userId, {required bool isDarkMode, required bool isEnglish}) async {
    try {
      final response = await ApiService.updateProfile(userId, {
        "is_dark_mode": isDarkMode,
        "is_english": isEnglish,
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Save preferences failed: $e");
      return false;
    }
  }
}
