import 'package:flutter/material.dart';

class NumberInput extends StatelessWidget {
  final bool isEditing;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? hintText;

  const NumberInput({
    super.key,
    required this.isEditing,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      enabled: isEditing,
      keyboardType: TextInputType.number,
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: isEditing ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.grey[300]! : Colors.grey[600]!)),
      decoration: InputDecoration(
        hintText: hintText ?? "",
        hintStyle: TextStyle(color: isEditing ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.grey[300]! : Colors.grey[600]!)),
        filled: true,
        fillColor: isDark ? Colors.grey[850]! : Colors.grey[100]!,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}