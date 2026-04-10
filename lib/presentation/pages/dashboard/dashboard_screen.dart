import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/activity_data.dart';
import '../../../data/financial_overview_chart_data.dart';
import '../../../responsive_helper.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/card/recent_activity_card.dart';
import '../../widgets/card/stat_card.dart';
import '../../widgets/chart/financial_overview_chart.dart';
import '../../widgets/chart/income_expense_chart.dart';
import '../../../data/dashboard_stat_data.dart';
import '../../controllers/financial_controller.dart';

class DashboardScreen extends StatelessWidget {
  final bool isDarkMode;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onSeeAllActivities;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.onSeeAllActivities,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final authCtrl = Provider.of<AuthController>(context, listen: false);
    final userId = authCtrl.user?['id'];

    return Consumer<FinancialController>(
      builder: (context, ctrl, _) {
        // filter aktivitas untuk user login
        final latestActivities = ctrl.todaysActivities
            .where((a) => a.userId == userId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        // stats hanya untuk user login
        final stats = getDashboardStats(ctrl, userId: userId);

        int crossAxisCount = responsive.value(mobile: 2, tablet: 3, desktop: 4);
        double gridItemHeight = responsive.size(mobile: 130, tablet: 150, desktop: 170);
        double sectionSpacing = responsive.size(mobile: 24, tablet: 28, desktop: 36);

        return SingleChildScrollView(
          padding: EdgeInsets.all(responsive.size(mobile: 12, tablet: 16, desktop: 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// GRID STAT CARD
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: responsive.size(mobile: 12, tablet: 14, desktop: 16),
                  mainAxisSpacing: responsive.size(mobile: 12, tablet: 14, desktop: 16),
                  mainAxisExtent: gridItemHeight,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final item = stats[index];
                  return StatCard(
                    title: item.title,
                    value: item.value,
                    icon: item.icon,
                    color: item.color,
                    isDarkMode: isDarkMode,
                  );
                },
              ),

              SizedBox(height: sectionSpacing),

              /// CHART + RECENT ACTIVITY
              isDesktop
                  ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IncomeExpenseChart(
                            isDarkMode: isDarkMode,
                            userId: userId, // tambahkan userId filter
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.size(desktop: 16, mobile: 8)),
                      Expanded(
                        flex: 1,
                        child: RecentActivityCard(
                          activities: latestActivities.take(5).toList(),
                          isDarkMode: isDarkMode,
                          onSeeDetails: onSeeAllActivities,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
                  FinancialOverviewChart(
                    data: ctrl.calculateMonthlySummary(userId: userId), // filter userId
                    isDarkMode: isDarkMode,
                  ),
                ],
              )
                  : Column(
                children: [
                  RecentActivityCard(
                    activities: latestActivities.take(5).toList(),
                    isDarkMode: isDarkMode,
                    onSeeDetails: onSeeAllActivities,
                  ),
                  SizedBox(height: responsive.size(mobile: 12, tablet: 16, desktop: 20)),
                  Container(
                    height: responsive.size(mobile: 260, tablet: 300, desktop: 320),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IncomeExpenseChart(isDarkMode: isDarkMode, userId: userId),
                  ),
                  SizedBox(height: responsive.size(mobile: 12, tablet: 16, desktop: 20)),
                  FinancialOverviewChart(
                    data: ctrl.calculateMonthlySummary(userId: userId),
                    isDarkMode: isDarkMode,
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