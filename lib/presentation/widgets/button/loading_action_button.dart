import 'package:flutter/material.dart';

class LoadingActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final String? loadingLabel; // Menambahkan custom label saat loading
  final IconData icon;

  // Parameter kustomisasi seperti ActionButton
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const LoadingActionButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.loadingLabel,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.borderRadius = 14, // Default tetap 14 agar konsisten
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menentukan warna default jika tidak diisi (mengikuti logika ActionButton)
    final effectiveBgColor = backgroundColor ??
        (isLoading
            ? Colors.blue.withOpacity(0.6) // Warna saat loading
            : (isDark ? Colors.grey[800] : Colors.blue));

    final effectiveFgColor = foregroundColor ?? Colors.white;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
        height: iconSize ?? 18,
        width: iconSize ?? 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: effectiveFgColor, // Mengikuti warna teks
        ),
      )
          : Icon(
        icon,
        size: iconSize ?? 18,
      ),
      label: Text(
        isLoading ? (loadingLabel ?? "Saving...") : label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
        backgroundColor: effectiveBgColor,
        foregroundColor: effectiveFgColor,
        disabledBackgroundColor: effectiveBgColor?.withOpacity(0.6),
        disabledForegroundColor: effectiveFgColor.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}