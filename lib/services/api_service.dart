import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_fintrack/services/token_storage.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['API_BASE_URL_WEB']!;
    } else {
      return dotenv.env['API_BASE_URL']!;
    }
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static void initInterceptor() {

    dio.interceptors.add(
      InterceptorsWrapper(

        onRequest: (options, handler) async {

          final token = await TokenStorage.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },

        onError: (error, handler) {

          if (error.response?.statusCode == 401) {
            print("Token expired -> logout");
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ================= AUTH =================
  static Future<Response> register(Map<String, dynamic> data) async {
    return await dio.post("/register", data: data);
  }

  static Future<Response> login(Map<String, dynamic> data) async {
    return await dio.post("/login", data: data);
  }

  static Future<Response> forgotPassword(String email) async {
    return await dio.post(
      "/forgot-password",
      data: {"email": email},
    );
  }

  static Future<Response> verifyOTP(
      String email,
      String otp,
      ) async {
    return await dio.post("/verify-otp", data: {
      "email": email,
      "otp": otp,
    });
  }

  static Future<void> resetPassword(
      String token,
      String password,
      ) async {
    await dio.post("/reset-password", data: {
      "token": token,
      "new_password": password,
    });
  }

  // ================= PROFILE =================
  static Future<Response> getProfile(int id) async {
    return await dio.get("/profile/$id");
  }

  static Future<Response> updateProfile(int id, Map<String, dynamic> data) async {
    return await dio.put("/profile/$id", data: data);
  }

  static Future<Response> ProfileCheckPassword(int userId, String oldPassword) async {
    return await dio.post(
      "/profile/$userId/check-password",
      data: {"old_password": oldPassword},
    );
  }

  // ================= PROFILE IMAGE =================
  static Future<Response> uploadProfileImage(int id, Uint8List bytes) async {
    FormData formData = FormData.fromMap({
      "image": MultipartFile.fromBytes(
        bytes,
        filename: "profile_${DateTime.now().millisecondsSinceEpoch}.png",
      )
    });

    return await dio.post("/profile/$id/image", data: formData);
  }

  static Future<Uint8List> fetchImageBytes(String url) async {
    final response = await dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(response.data!);
  }

  // ================= TRANSACTIONS =================
  static Future<Response> getTransactions(int userId) async {
    return await dio.get("/transactions/$userId");
  }

  static Future<Response> createTransaction(Map<String, dynamic> data) async {
    return await dio.post("/transactions", data: data);
  }

  static Future<Response> deleteTransaction(int id) async {
    return await dio.delete("/transactions/$id");
  }
}