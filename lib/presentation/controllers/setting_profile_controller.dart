import 'dart:typed_data';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/profile_service.dart';

class SettingProfileController with ChangeNotifier {
  // ===== STATE =====
  bool isEditingProfile = false;
  bool isEditingEmail = false;
  bool isEditingPhone = false;
  bool isEditingPassword = false;

  bool isSavingProfile = false;
  bool isSavingEmail = false;
  bool isSavingPhone = false;
  bool isSavingPassword = false;

  bool isDarkMode = false;
  bool isEnglish = false;

  bool oldPasswordObscure = true;
  bool newPasswordObscure = true;
  bool confirmPasswordObscure = true;

  Uint8List? imageBytes;

  String name = "";
  String bio = "";
  String email = "";
  String phone = "";

  String tempName = "";
  String tempBio = "";
  String tempEmail = "";
  String tempPhone = "";

  String oldPassword = "";
  String newPassword = "";
  String confirmPassword = "";

  String? errorMessage;

  TextEditingController phoneController = TextEditingController();

  // Tambahkan di SettingProfileController
  Country selectedCountry = Country(
    phoneCode: "62",
    countryCode: "ID",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Indonesia",
    example: "8123456789",
    displayName: "Indonesia",
    displayNameNoCountryCode: "Indonesia",
    e164Key: "",
  );

  bool showCountryDropdown = false;

  // Fungsi toggle dropdown
  void toggleCountryDropdown() {
    showCountryDropdown = !showCountryDropdown;
    notifyListeners();
  }

  // Fungsi ganti country
  void setSelectedCountry(Country c) {
    selectedCountry = c;
    notifyListeners();
  }

  void resetDraft() {
    tempName = name;
    tempBio = bio;
    tempEmail = email;
    tempPhone = phone;

    oldPassword = "";
    newPassword = "";
    confirmPassword = "";

    isEditingProfile = false;
    isEditingEmail = false;
    isEditingPhone = false;
    isEditingPassword = false;

    notifyListeners();
  }

  Map<String, bool> getPasswordRulesStatus(String password) {
    return {
      "Password berisi 8 - 20 karakter": password.length >= 8 && password.length <= 20,
      "Minimal 1 huruf kapital & 1 huruf kecil":
      RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password),
      "Minimal 1 simbol (@, #, %, &, dll)":
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  bool isPasswordValid(String password) {
    final rules = getPasswordRulesStatus(password);
    return rules.values.every((v) => v);
  }

  // ===== LOAD PROFILE =====
  Future<void> loadProfile(int userId) async {
    final data = await ProfileService.loadProfile(userId);
    if (data != null) {
      name = data['name'] ?? "";
      bio = data['bio'] ?? "";
      email = data['email'] ?? "";
      phone = data['phone'] ?? "";
      tempName = name;
      tempBio = bio;
      tempEmail = email;
      tempPhone = phone;

      isDarkMode = data['is_dark_mode'] ?? false;
      isEnglish = data['is_english'] ?? false;
      final imageUrl = data['image'] as String?;

      phoneController.text = tempPhone;

      // ===== FIX IMAGE LOAD (WEB + MOBILE) =====
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // ambil base URL TANPA /api
          final baseUrl = ApiService.baseUrl.replaceAll('/api', '');

          final fullUrl = "$baseUrl$imageUrl";

          final bytes = await ApiService.fetchImageBytes(fullUrl);

          imageBytes = bytes;
        } catch (e) {
          print("❌ Failed to load profile image: $e");
          imageBytes = null;
        }
      }
      notifyListeners();
    }
  }

  Future<bool> saveProfile(int userId) async {
    isSavingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await ProfileService.saveProfile(
        userId,
        tempName,
        tempBio,
      );

      if (success) {
        name = tempName;
        bio = tempBio;
      } else {
        errorMessage = "Failed to save profile";
      }

      isSavingProfile = false;
      notifyListeners();
      return success;
    } catch (e) {
      errorMessage = "Save profile failed: $e";
      isSavingProfile = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveEmail(int userId) async {
    isSavingEmail = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await ProfileService.saveEmail(userId, tempEmail);

      if (success) {
        email = tempEmail;
      }

      isSavingEmail = false;
      notifyListeners();
      return success;

    } catch (e) {

      errorMessage = e.toString(); // 🔥 simpan error backend
      isSavingEmail = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> savePhone(int userId) async {
    isSavingPhone = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fullPhone = '+${selectedCountry.phoneCode}${tempPhone.trim()}';

      final success = await ProfileService.savePhone(userId, fullPhone);

      if (success) {
        phone = fullPhone;
        tempPhone = tempPhone;
        phoneController.text = tempPhone;
      } else {
        errorMessage = "Failed to save phone number";
      }

      isSavingPhone = false;
      notifyListeners();
      return success;
    } catch (e) {
      errorMessage = "Save phone failed: $e";
      isSavingPhone = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> savePassword(int userId) async {
    isSavingPassword = true;
    notifyListeners();

    try {
      // 1. Validasi old password
      final isOldValid = await ProfileService.validateOldPassword(userId, oldPassword);
      if (!isOldValid) {
        errorMessage = "Old password is incorrect";
      }

      // 2. Validasi new vs confirm password
      else if (newPassword != confirmPassword) {
        errorMessage = "New password and confirm password do not match";
      }

      // 3. Jika ada error → tampilkan, jangan ubah isEditingPassword
      if (errorMessage != null) {
        isSavingPassword = false;
        notifyListeners();
        return false;
      }

      // 4. Kalau valid, update password
      final success = await ProfileService.updatePassword(userId, oldPassword, newPassword);

      isSavingPassword = false;
      notifyListeners();
      return success;
    } catch (e) {
      print("Save password failed: $e");
      isSavingPassword = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadImage(int userId) async {
    if (imageBytes == null) {
      errorMessage = "No image selected";
      return false;
    }

    isSavingProfile = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await ProfileService.uploadImage(userId, imageBytes!);

      if (!success) {
        errorMessage = "Failed to upload image";
      }

      isSavingProfile = false;
      notifyListeners();
      return success;
    } catch (e) {
      errorMessage = "Upload image failed: $e";
      isSavingProfile = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setDarkMode(bool value, int userId) async {
    isDarkMode = value;
    notifyListeners();

    await savePreferences(userId);
  }

  Future<void> setLanguage(bool value, int userId) async {
    isEnglish = value;
    notifyListeners();

    await savePreferences(userId);
  }

  Future<bool> savePreferences(int userId) async {
    final success = await ProfileService.savePreferences(
      userId,
      isDarkMode: isDarkMode,
      isEnglish: isEnglish,
    );
    return success;
  }
}
