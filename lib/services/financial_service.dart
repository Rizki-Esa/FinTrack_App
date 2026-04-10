import 'package:frontend_fintrack/services/api_service.dart';
import 'package:dio/dio.dart';

class FinancialService {
  // ===== TRANSACTIONS =====

  static Future<Response> getTransactions(int userId) async {
    try {
      return await ApiService.getTransactions(userId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> createTransaction(Map<String, dynamic> data) async {
    try {
      return await ApiService.createTransaction(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> deleteTransaction(int id) async {
    try {
      return await ApiService.deleteTransaction(id);
    } catch (e) {
      rethrow;
    }
  }
}