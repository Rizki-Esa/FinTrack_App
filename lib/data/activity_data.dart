import 'package:flutter/material.dart';

class ActivityData {
  final int id;
  final int userId;
  final String category;
  final String description;
  final double amount;
  final String type;
  final DateTime date;
  final DateTime? createdAt;
  final IconData icon;

  ActivityData({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.createdAt,
    required this.icon,
  });

  /// ===== FROM JSON (API → APP) =====
  factory ActivityData.fromJson(Map<String, dynamic> json, IconData icon) {
    return ActivityData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      category: json['category'] ?? "",
      description: json['description'] ?? "",
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? "",
      date: DateTime.parse(json['date']).toLocal(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      icon: icon,
    );
  }

  /// ===== TO JSON (APP → API) =====
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "category": category,
      "description": description,
      "amount": amount,
      "type": type,
      "date": date.toIso8601String(),
    };
  }
}