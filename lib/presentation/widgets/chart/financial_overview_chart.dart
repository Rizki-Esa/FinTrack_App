import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/financial_overview_chart_data.dart';
import '../../../responsive_helper.dart';
import 'package:flutter/services.dart';

class FinancialOverviewChart extends StatelessWidget {
  final List<FinancialOverviewChartData> data;
  final bool isDarkMode;

  const FinancialOverviewChart({
    super.key,
    required this.data,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final double titleFontSize =
    responsive.fontSize(mobile: 14, tablet: 16, desktop: 18);

    final double legendFontSize =
    responsive.fontSize(mobile: 10, tablet: 12, desktop: 12);

    final double axisLabelFontSize =
    responsive.fontSize(mobile: 10, tablet: 12, desktop: 12);

    final double dotSize =
    responsive.size(mobile: 3, tablet: 4, desktop: 5);

    return Container(
      padding: responsive.padding(mobile: 12, tablet: 16, desktop: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Overview ${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.size(mobile: 6, tablet: 8, desktop: 8)),
                    Row(
                      children: [
                        _buildLegend(Colors.blue, 'Income', legendFontSize),
                        SizedBox(width: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
                        _buildLegend(Colors.red[500]!, 'Expense', legendFontSize),
                        SizedBox(width: responsive.size(mobile: 8, tablet: 10, desktop: 12)),
                        _buildLegend(Colors.orange, 'Saving', legendFontSize),
                      ],
                    ),
                  ],
                ),
              ),

              /// ICON HANYA MOBILE
              if (responsive.isMobile)
                IconButton(
                  icon: Icon(
                    Icons.open_in_new,
                    size: responsive.size(mobile: 18, tablet: 20, desktop: 22),
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                  onPressed: () {
                    _openFullChart(context);
                  },
                ),
            ],
          ),

          SizedBox(height: responsive.size(mobile: 12, tablet: 16, desktop: 20)),

          /// CHART
          AspectRatio(
            aspectRatio: 2.5,
            child: Padding(
              padding: EdgeInsets.only(
                  right: responsive.size(
                      mobile: 6, tablet: 8, desktop: 12)),
              child: LineChart(
                  _buildChartData(responsive, dotSize, axisLabelFontSize)),
            ),
          ),
        ],
      ),
    );
  }

  /// POPUP FULLSCREEN CHART
  void _openFullChart(BuildContext context) async {

    /// rotate ke landscape
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final responsive = Responsive(context);

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          child: SafeArea(
            child: Column(
              children: [

                /// HEADER
                Padding(
                  padding: responsive.padding(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Financial Overview ${DateTime.now().year}',
                          style: TextStyle(
                            fontSize: responsive.fontSize(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {

                          Navigator.pop(context);

                          /// balik ke portrait
                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                        },
                      )
                    ],
                  ),
                ),

                /// CHART FULLSCREEN
                Expanded(
                  child: Padding(
                    padding: responsive.padding(
                      mobile: 12,
                      tablet: 16,
                      desktop: 20,
                    ),
                    child: LineChart(
                      _buildChartData(
                        responsive,
                        responsive.size(mobile: 4, tablet: 5, desktop: 6),
                        responsive.fontSize(mobile: 12, tablet: 12, desktop: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// LEGEND
  Widget _buildLegend(Color color, String label, double fontSize) {
    return Row(
      children: [
        Container(
          width: fontSize,
          height: fontSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[800],
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  /// CHART DATA
  LineChartData _buildChartData(Responsive responsive, double dotSize, double axisFont) {
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final savingSpots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), data[i].income.toDouble()));
      expenseSpots.add(FlSpot(i.toDouble(), data[i].expense.toDouble()));
      savingSpots.add(FlSpot(i.toDouble(), data[i].saving.toDouble()));
    }

    double maxValue = [
      ...data.map((d) => d.income),
      ...data.map((d) => d.expense),
      ...data.map((d) => d.saving),
    ].reduce((a, b) => a > b ? a : b);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return LineChartData(
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: 0,
      maxY: maxValue.ceilToDouble(),

      gridData: FlGridData(show: true),

      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= data.length) return const SizedBox();
              return Text(
                data[index].label,
                style: TextStyle(fontSize: axisFont, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (maxValue / 5).ceilToDouble() == 0 ? 1 : (maxValue / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              return Text(
                "${(value / 1000000).toStringAsFixed(0)} jt",
                style: TextStyle(fontSize: axisFont),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),

      lineBarsData: [
        LineChartBarData(
          spots: incomeSpots,
          isCurved: false,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) =>
                FlDotCirclePainter(radius: dotSize, color: Colors.blue),
          ),
          belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
        ),
        LineChartBarData(
          spots: expenseSpots,
          isCurved: false,
          color: Colors.red[400]!,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) =>
                FlDotCirclePainter(radius: dotSize, color: Colors.red[400]!),
          ),
          belowBarData: BarAreaData(show: true, color: Colors.red[400]!.withOpacity(0.3)),
        ),
        LineChartBarData(
          spots: savingSpots,
          isCurved: false,
          color: Colors.orange,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) =>
                FlDotCirclePainter(radius: dotSize, color: Colors.orange),
          ),
          belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.25)),
        ),
      ],

      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              String text = currencyFormatter.format(spot.y);
              Color color = spot.barIndex == 0
                  ? Colors.blue
                  : spot.barIndex == 1
                  ? Colors.red[400]!
                  : Colors.orange;

              return LineTooltipItem(
                text,
                TextStyle(color: color, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}