import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/income_expense_chart_data.dart';
import '../../../responsive_helper.dart';
import '../../controllers/financial_controller.dart';

class IncomeExpenseChart extends StatefulWidget {
  final bool isDarkMode;
  final int? userId;
  const IncomeExpenseChart({super.key, this.isDarkMode = false, this.userId});

  @override
  State<IncomeExpenseChart> createState() => _IncomeExpenseChartState();
}

class _IncomeExpenseChartState extends State<IncomeExpenseChart> {
  int touchedIndex = -1;
  bool showIncome = true;

  String formatRupiah(double value) {
    return "Rp ${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"; // Rp 1.500.000
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final controller = Provider.of<FinancialController>(context);

    final double chartRadius = responsive.size(mobile: 36, tablet: 44, desktop: 50);
    final double centerRadius = responsive.size(mobile: 22, tablet: 28, desktop: 40);
    final bgColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    // ===== INCOME CATEGORY SUMMARY (ALL TIME) =====
    final List<IncomeExpenseChartData> incomeData = controller.getCategoryOverviewByYear(
      year: DateTime.now().year,
      isIncome: true,
      userId: widget.userId, // filter user
    );

    final List<IncomeExpenseChartData> expenseData = controller.getCategoryOverviewByYear(
      year: DateTime.now().year,
      isIncome: false,
      userId: widget.userId, // filter user
    );

    final dataToShow = showIncome ? incomeData : expenseData;
    final totalValue = dataToShow.fold(0.0, (sum, item) => sum + item.value);

    final selector = ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      isSelected: [showIncome, !showIncome],
      selectedColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.15),
      constraints: BoxConstraints(
        minHeight: responsive.size(mobile: 24, tablet: 32, desktop: 34),
        minWidth: responsive.size(mobile: 48, tablet: 70, desktop: 80),
      ),
      onPressed: (index) {
        setState(() {
          showIncome = index == 0;
          touchedIndex = -1;
        });
      },
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
          child: Text("Income", style: TextStyle(fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14))),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
          child: Text("Expense", style: TextStyle(fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14))),
        ),
      ],
    );

    return Container(
      padding: responsive.padding(mobile: 8, tablet: 10, desktop: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// TITLE + SELECTOR
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  responsive.isMobile
                      ? "Category Overview\n${DateTime.now().year}"
                      : "Category Overview ${DateTime.now().year}",
                  style: TextStyle(
                    fontSize: responsive.fontSize(mobile: 14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: selector,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: responsive.size(mobile: 160, tablet: 200, desktop: 280),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: centerRadius,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(dataToShow.length, (i) {
                        final item = dataToShow[i];
                        final isTouched = i == touchedIndex;
                        final radius = isTouched ? chartRadius + 10 : chartRadius;

                        final percent = totalValue == 0
                            ? 0
                            : (item.value / totalValue * 100);

                        return PieChartSectionData(
                          color: item.color,
                          value: item.value,
                          title: "${percent.toStringAsFixed(1)}%",
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: responsive.fontSize(mobile: 8, tablet: 10, desktop: 12),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dataToShow.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: responsive.size(mobile: 4, tablet: 6, desktop: 8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Indicator(
                              color: item.color,
                              text: item.title,
                              fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14),
                              isDarkMode: widget.isDarkMode,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: responsive.size(mobile: 16, tablet: 20, desktop: 20)),
                              child: Text(
                                formatRupiah(item.value),
                                style: TextStyle(
                                  fontSize: responsive.fontSize(mobile: 8, tablet: 10, desktop: 12),
                                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// PIE CHART ITEM
class _ChartItem {
  final String title;
  final double value;
  final Color color;
  _ChartItem(this.title, this.value, this.color);
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final double fontSize;
  final bool isDarkMode;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.fontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: responsive.size(mobile: 10, tablet: 12, desktop: 14),
          height: responsive.size(mobile: 10, tablet: 12, desktop: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: responsive.size(mobile: 4, tablet: 4, desktop: 6)),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}