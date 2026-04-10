import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../responsive_helper.dart';

class CustomDialog {
  static void show({
    required BuildContext context,
    required bool isSuccess,
    bool isDarkMode = false,
    String? message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final responsive = Responsive(context);
        Future.delayed(duration, () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            if (onComplete != null) {
              onComplete();
            }
          }
        });

        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.size(mobile: 10, tablet: 12, desktop: 14)),
          ),
          contentPadding: EdgeInsets.all(
            responsive.size(mobile: 16, tablet: 20, desktop: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: responsive.size(mobile: 40, tablet: 48, desktop: 56),
              ),
              if (message != null) ...[
                SizedBox(
                  height: responsive.size(mobile: 10, tablet: 12, desktop: 16),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(mobile: 12, tablet: 14, desktop: 16),
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
