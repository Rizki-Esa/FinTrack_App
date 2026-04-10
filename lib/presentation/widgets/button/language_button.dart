import 'package:flutter/material.dart';

class LanguageToggleButton extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onChanged;

  const LanguageToggleButton({
    super.key,
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final Color activeBlue = Colors.blue[600]!;
    final Color inactiveColor =
    isDarkMode ? Colors.grey[100]! : Colors.grey[900]!;

    const double textWidth = 70;

    return TextButton(
      onPressed: () => onChanged(!isEnglish),
      style: TextButton.styleFrom(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: isEnglish ? activeBlue : inactiveColor,
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: textWidth,
            height: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                );

                return ClipRect(
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                key: ValueKey(isEnglish),
                child: Text(
                  isEnglish ? "English" : "Indonesia",
                  style: TextStyle(
                    color:
                    isEnglish ? activeBlue : inactiveColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}