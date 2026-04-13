import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../responsive_helper.dart';

class CustomDialogButton {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    bool isWarning = false,
    bool isDarkMode = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Inisialisasi Responsive helper
        final responsive = Responsive(context);

        // Warna adaptif berdasarkan mode
        final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
        final titleColor = isDarkMode ? Colors.white : Colors.black;
        final messageColor = isDarkMode ? Colors.white70 : Colors.black87;
        final cancelTextColor = isDarkMode ? Colors.white60 : Colors.black54;

        return AlertDialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.size(mobile: 12, tablet: 16, desktop: 20),
            ),
          ),
          contentPadding: EdgeInsets.all(
            responsive.size(mobile: 16, tablet: 24, desktop: 32),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWarning ? Icons.warning_amber_rounded : Icons.info,
                color: isWarning ? Colors.red : Colors.blue,
                size: responsive.size(mobile: 40, tablet: 48, desktop: 56),
              ),
              SizedBox(height: responsive.size(mobile: 12, tablet: 16, desktop: 20)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: responsive.fontSize(mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: responsive.fontSize(mobile: 13, tablet: 14, desktop: 15),
                  color: messageColor,
                ),
              ),
              SizedBox(height: responsive.size(mobile: 20, tablet: 28, desktop: 32)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (cancelText != null)
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel ?? () => Navigator.of(context).pop(),
                        child: Text(
                          cancelText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: responsive.fontSize(mobile: 14, tablet: 15, desktop: 16),
                            fontWeight: FontWeight.w500,
                            color: cancelTextColor,
                          ),
                        ),
                      ),
                    ),
                  if (cancelText != null)
                    SizedBox(width: responsive.size(mobile: 8, tablet: 12, desktop: 16)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onConfirm();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isWarning ? Colors.red : Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.size(mobile: 8, tablet: 10, desktop: 12),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.size(mobile: 10, tablet: 12, desktop: 14),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: responsive.fontSize(mobile: 14, tablet: 15, desktop: 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}