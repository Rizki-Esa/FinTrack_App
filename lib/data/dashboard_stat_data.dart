import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../presentation/controllers/financial_controller.dart';

class DashboardStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  DashboardStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Function untuk generate data StatCard dari controller
List<DashboardStatData> getDashboardStats(FinancialController ctrl, {int? userId}) {
  // Filter activities sesuai userId jika ada
  final activities = userId == null
      ? ctrl.allActivities
      : ctrl.allActivities.where((a) => a.userId == userId).toList();

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  final totalIncome = activities
      .where((a) => a.type == "income")
      .fold(0.0, (sum, a) => sum + a.amount);

  final totalExpense = activities
      .where((a) => a.type == "expense")
      .fold(0.0, (sum, a) => sum + a.amount.abs());

  final totalSaving = activities
      .where((a) => a.type == "saving")
      .fold(0.0, (sum, a) => sum + a.amount);

  final totalBalance = totalIncome - totalExpense - totalSaving;

  return [
    DashboardStatData(
      title: "Total Income",
      value: formatCurrency(totalIncome),
      icon: Icons.trending_up,
      color: Colors.blue,
    ),
    DashboardStatData(
      title: "Total Expense",
      value: formatCurrency(totalExpense),
      icon: Icons.trending_down,
      color: Colors.red,
    ),
    DashboardStatData(
      title: "Savings",
      value: formatCurrency(totalSaving),
      icon: Icons.savings,
      color: Colors.orange,
    ),
    DashboardStatData(
      title: "Total Balance",
      value: formatCurrency(totalBalance),
      icon: Icons.account_balance_wallet,
      color: Colors.green,
    ),
  ];
}