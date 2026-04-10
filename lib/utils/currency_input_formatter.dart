import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat("#,###", "id_ID");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: "");
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), "");

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: "");
    }

    final number = int.parse(digitsOnly);
    final newText = formatter.format(number).replaceAll(",", ".");

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}