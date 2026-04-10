import 'package:flutter/material.dart';
import 'package:frontend_fintrack/services/financial_service.dart';
import 'package:frontend_fintrack/data/activity_data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../data/financial_overview_chart_data.dart';
import '../../data/income_expense_chart_data.dart';
import '../../services/api_service.dart';

class FinancialController with ChangeNotifier {
  // ===== STATE =====
  String selectedType = "income";
  String selectedCategory = "Salary";
  TextEditingController subtitleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  List<ActivityData> allActivities = [];
  List<ActivityData> todaysActivities = [];
  bool isLoading = false;

  // ===== SUMMARY TODAY =====
  double todayIncome = 0;
  double todayExpense = 0;
  double todaySaving = 0;
  double todayBalance = 0;

  // ===== SUMMARY ALL TIME =====
  double totalIncome = 0;
  double totalExpense = 0;
  double totalSaving = 0;
  double totalBalance = 0;


  // ===== CATEGORIES =====
  final Map<String, List<String>> categories = {
    "income": ["Salary", "Investment", "Gift", "Others Income"],
    "expense": ["Food & Drinks", "Shopping", "Bills", "Others Expense"],
    "saving": ["Saving"],
  };

  // ICONS PER CATEGORY
  final Map<String, IconData> categoryIcons = {
    "Salary": Icons.work,
    "Investment": Icons.trending_up,
    "Gift": Icons.card_giftcard,
    "Others Income": Icons.laptop,
    "Food & Drinks": Icons.restaurant,
    "Transport": Icons.local_taxi,
    "Entertainment": Icons.movie,
    "Shopping": Icons.shopping_bag,
    "Bills": Icons.bolt,
    "Others Expense": Icons.fitness_center,
    "Saving": Icons.savings,
  };

  IconData _categoryIcon(String category) {
    return categoryIcons[category] ?? Icons.attach_money;
  }

  // ===== TYPE & CATEGORY CHANGE =====
  void changeType(String type) {
    selectedType = type;
    selectedCategory = categories[type]!.first;
    notifyListeners();
  }

  void changeCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void clearInputs() {
    subtitleController.clear();
    amountController.clear();
  }

  Future<void> loadUserActivities(int userId) async {
    try {
      final response = await ApiService.getTransactions(userId);
      if (response.statusCode == 200) {
        final List data = response.data;
        allActivities = data.map((e) => ActivityData.fromJson(
          e,
          _categoryIcon(e['category']),
        )).toList();

        final now = DateTime.now();
        todaysActivities = allActivities.where((a) =>
        a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day
        ).toList();

        notifyListeners();
      }
    } catch (e) {
      print("Failed load activities: $e");
    }
  }

  // ===== SUBMIT TRANSACTION =====
  Future<bool> submitTransaction({required int userId}) async {
    final rawAmount = amountController.text.replaceAll(".", "");
    final value = double.tryParse(rawAmount) ?? 0;

    if (value <= 0) return false;

    final transactionData = {
      "user_id": userId,
      "category": selectedCategory,
      "description": subtitleController.text,
      "amount": value,
      "type": selectedType,
      "date": DateTime.now().toUtc().toIso8601String(),
    };

    isLoading = true;
    notifyListeners();

    try {

      debugPrint("Transaction Data: $transactionData");

      final response = await FinancialService.createTransaction(transactionData);

      debugPrint("API Response: ${response.data}");

      // Ambil ID dari response jika backend mengembalikan data transaksi baru
      final int newId = response.data['id'];

      // Tambahkan ke local list
      final newActivity = ActivityData(
        id: newId,
        userId: userId,
        category: selectedCategory,
        description: subtitleController.text,
        amount: value,
        type: selectedType,
        date: DateTime.now(),
        icon: _categoryIcon(selectedCategory),
      );

      allActivities.insert(0, newActivity);
      todaysActivities.insert(0, newActivity);

      _calculateSummaryToday();
      _calculateSummaryAllTime();
      clearInputs();
      return true;

    } catch (e) {
      if (e is DioException) {
        debugPrint("API ERROR:");
        debugPrint("Status Code: ${e.response?.statusCode}");
        debugPrint("Response: ${e.response?.data}");
      } else {
        debugPrint("Unknown Error: $e");
      }
      return false;

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===== FETCH TRANSACTIONS HARI INI =====
  Future<void> loadTodaysTransactions({required int userId}) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await FinancialService.getTransactions(userId);
      if (response.statusCode == 200) {
        final List data = response.data;

        allActivities = data
            .map((tx) => ActivityData.fromJson(
          tx,
          _categoryIcon(tx['category']),
        ))
            .toList();

        final today = DateTime.now();
        todaysActivities = data
            .where((tx) {
          final txDate = DateTime.parse(tx['date']).toLocal();
          return txDate.year == today.year &&
              txDate.month == today.month &&
              txDate.day == today.day;
        })
            .map((tx) => ActivityData.fromJson(
          tx,
          _categoryIcon(tx['category']),
        ))
            .toList();
        _calculateSummaryToday();
        _calculateSummaryAllTime();
      }
    } catch (e) {
      // bisa log error atau tampilkan snackbar
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===== DELETE TRANSACTION =====
  Future<bool> deleteTransaction(int id) async {
    try {
      await FinancialService.deleteTransaction(id);
      todaysActivities.removeWhere((a) => a.id == id);
      allActivities.removeWhere((a) => a.id == id);
      _calculateSummaryToday();
      _calculateSummaryAllTime();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== SUMMARY CALCULATION =====
  void _calculateSummaryToday() {
    todayIncome = todaysActivities
        .where((a) => a.type == "income")
        .fold(0, (sum, a) => sum + a.amount);

    todayExpense = todaysActivities
        .where((a) => a.type == "expense")
        .fold(0, (sum, a) => sum + a.amount.abs());

    todaySaving = todaysActivities
        .where((a) => a.type == "saving")
        .fold(0, (sum, a) => sum + a.amount);

    todayBalance = todayIncome - todayExpense - todaySaving;
  }

  void _calculateSummaryAllTime() {
    totalIncome = allActivities
        .where((a) => a.type == "income")
        .fold(0, (sum, a) => sum + a.amount);

    totalExpense = allActivities
        .where((a) => a.type == "expense")
        .fold(0, (sum, a) => sum + a.amount.abs());

    totalSaving = allActivities
        .where((a) => a.type == "saving")
        .fold(0, (sum, a) => sum + a.amount);

    totalBalance = totalIncome - totalExpense - totalSaving;
  }

  List<FinancialOverviewChartData> calculateMonthlySummary({int? userId}) {
    final now = DateTime.now();
    final year = now.year;

    // Filter activities per userId jika ada
    final activities = userId == null
        ? allActivities
        : allActivities.where((a) => a.userId == userId).toList();

    List<FinancialOverviewChartData> monthlyData = [];

    for (int month = 1; month <= 12; month++) {
      final monthActivities = activities
          .where((a) => a.date.year == year && a.date.month == month)
          .toList();

      final income = monthActivities
          .where((a) => a.type == "income")
          .fold(0.0, (sum, a) => sum + (a.amount < 0 ? 0 : a.amount));

      final expense = monthActivities
          .where((a) => a.type == "expense")
          .fold(0.0, (sum, a) => sum + (a.amount < 0 ? 0 : a.amount));

      final saving = monthActivities
          .where((a) => a.type == "saving")
          .fold(0.0, (sum, a) => sum + (a.amount < 0 ? 0 : a.amount));

      monthlyData.add(FinancialOverviewChartData(
        DateFormat('MMM').format(DateTime(year, month)),
        income,
        expense,
        saving,
      ));
    }

    return monthlyData;
  }

  /// Hitung category overview per tahun
  List<IncomeExpenseChartData> getCategoryOverviewByYear({int? year, bool isIncome = true, int? userId,}) {
    final targetYear = year ?? DateTime.now().year;

    // Filter activities per userId jika ada
    final activities = userId == null
        ? allActivities
        : allActivities.where((a) => a.userId == userId).toList();

    // Pilih tipe: income / expense
    final filtered = activities
        .where((a) => a.type == (isIncome ? "income" : "expense") && a.date.year == targetYear)
        .toList();

    final Map<String, double> map = {};
    for (var a in filtered) {
      map[a.category] = (map[a.category] ?? 0) +
          (a.type == "expense" ? a.amount.abs() : a.amount);
    }

    return map.entries
        .map((e) => IncomeExpenseChartData(e.key, e.value, _categoryColor(e.key)))
        .toList();
  }

// Contoh helper warna kategori
  Color _categoryColor(String category) {
    final Map<String, Color> colors = {
      "Salary": Colors.green,
      "Investment": Colors.green.shade900,
      "Gift": Colors.lightGreen,
      "Others Income": Colors.teal,
      "Food & Drinks": Colors.orange,
      "Shopping": Colors.yellow,
      "Bills": Colors.deepOrange,
      "Others Expense": Colors.pink,
      "Saving": Colors.blue,
    };
    return colors[category] ?? Colors.grey;
  }
}