import 'package:flutter/material.dart';
import '../../../data/activity_data.dart';
import '../../../responsive_helper.dart';
import 'package:intl/intl.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityData> activities;
  final bool isDarkMode;
  final VoidCallback onSeeDetails;

  const RecentActivityCard({
    super.key,
    required this.activities,
    required this.isDarkMode,
    required this.onSeeDetails,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: responsive.padding(
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.size(mobile: 12, tablet: 16, desktop: 20),
        ),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: responsive.fontSize(
                mobile: 16,
                tablet: 17,
                desktop: 18,
              ),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: responsive.size(mobile: 12, tablet: 16, desktop: 20)),

          /// LIST
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => Divider(
              height: responsive.size(mobile: 12, tablet: 14, desktop: 16),
              thickness: 0.6,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            ),
            itemBuilder: (context, index) {

              final item = activities[index];

              Color valueColor =
              item.type == "income"
                  ? Colors.green
                  : item.type == "expense"
                  ? Colors.red
                  : Colors.orange;

              return Row(
                children: [

                  /// ICON
                  CircleAvatar(
                    radius: responsive.size(
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    backgroundColor: valueColor.withOpacity(0.15),
                    child: Icon(
                      item.icon,
                      size: responsive.size(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      color: valueColor,
                    ),
                  ),

                  SizedBox(width: responsive.size(mobile: 10, tablet: 12, desktop: 14)),

                  /// CATEGORY + DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          item.category,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: responsive.fontSize(
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                            ),
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),

                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: responsive.fontSize(
                              mobile: 10,
                              tablet: 11,
                              desktop: 12,
                            ),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// VALUE + TIME
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Text(
                        currencyFormatter.format(item.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.fontSize(
                            mobile: 11,
                            tablet: 12,
                            desktop: 13,
                          ),
                          color: valueColor,
                        ),
                      ),

                      Text(
                        DateFormat("HH:mm").format(item.date),
                        style: TextStyle(
                          fontSize: responsive.fontSize(
                            mobile: 9,
                            tablet: 10,
                            desktop: 11,
                          ),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          SizedBox(height: responsive.size(mobile: 12, tablet: 14, desktop: 16)),

          /// SEE DETAILS
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: onSeeDetails,
              child: Text(
                "See Details",
                style: TextStyle(
                  fontSize: responsive.fontSize(
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}