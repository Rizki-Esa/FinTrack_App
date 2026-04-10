import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double? fontSize;
  final double? iconSize;

  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.iconSize,
    this.padding,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: iconSize ?? 18,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,

        /// CUSTOM PADDING (TOP / BOTTOM)
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),

        backgroundColor:
        backgroundColor ??
            (isDark ? Colors.grey[800] : Colors.grey[200]),

        foregroundColor:
        foregroundColor ??
            (isDark ? Colors.white : Colors.black87),

        /// CUSTOM BORDER RADIUS
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(
          Colors.grey,
        ),
      ),
    );
  }
}