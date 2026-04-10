import 'package:flutter/material.dart';
import '../../../responsive_helper.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      padding: responsive.padding(mobile: 16, tablet: 20, desktop: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.size(mobile: 12, tablet: 14, desktop: 16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            blurRadius: responsive.size(mobile: 8, tablet: 10, desktop: 12),
            offset: Offset(0, responsive.size(mobile: 2, tablet: 4, desktop: 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: responsive.padding(mobile: 8, tablet: 10, desktop: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.size(mobile: 6, tablet: 8, desktop: 10)),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsive.size(mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          SizedBox(height: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 14, tablet: 16, desktop: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.size(mobile: 4, tablet: 6, desktop: 8)),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 12, tablet: 14, desktop: 16),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}