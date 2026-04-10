import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../responsive_helper.dart';
import '../../../data/activity_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../controllers/financial_controller.dart';
import '../../controllers/setting_profile_controller.dart';
import '../../widgets/button/action_button.dart';
import 'financial_entry_screen.dart';

class FinancialScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int userId;

  const FinancialScreen({
    super.key,
    required this.isDarkMode,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.userId,
  });

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {

  @override
  void initState() {
    super.initState();

    final ctrl = context.read<FinancialController>();
    ctrl.loadTodaysTransactions(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {

    final responsive = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: responsive.size(mobile: 10, tablet: 12, desktop: 14)),

        _buildSummary(responsive),

        const SizedBox(height: 12),

        Expanded(
          child: _buildActivityCard(responsive),
        ),

      ],
    );
  }

  Widget _buildSummary(Responsive responsive) {
    final ctrl = context.watch<FinancialController>();

    final balance = ctrl.todayBalance;

    if (widget.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _summaryCard("Income", ctrl.todayIncome, Colors.green),
              _summaryCard("Expense", ctrl.todayExpense, Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _summaryCard("Savings", ctrl.todaySaving, Colors.orange),
              _summaryCard("Balance", balance, Colors.blue),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        _summaryCard("Income", ctrl.todayIncome, Colors.green),
        _summaryCard("Expense", ctrl.todayExpense, Colors.red),
        _summaryCard("Savings", ctrl.todaySaving, Colors.orange),
        _summaryCard("Balance", balance, Colors.blue),
      ],
    );
  }

  Widget _summaryCard(String title, double value, Color color) {

    final currencyFormatter =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [

            Text(title, style: const TextStyle(color: Colors.grey)),

            Text(
              currencyFormatter.format(value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(Responsive responsive) {
    final ctrl = context.read<FinancialController>(); // <-- tambahkan ini
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            "Activity Today",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsive.fontSize(
                mobile: 16,
                tablet: 16,
                desktop: 18,
              ),
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionButton(
            onPressed: () async {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return FinancialEntryScreen(
                    isDarkMode: widget.isDarkMode,
                    isMobile: widget.isMobile,
                    isTablet: widget.isTablet,
                    isDesktop: widget.isDesktop,
                    userId: widget.userId,
                  );
                },
              );

              // reload setelah dialog ditutup
              ctrl.loadTodaysTransactions(userId: widget.userId);
            },
            icon: Icons.add,
            label: "Add",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            borderRadius: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Responsive responsive) {
    final ctrl = context.watch<FinancialController>();
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: Text(
        "Total Activity = ${ctrl.todaysActivities.length}",
          style: TextStyle(
            fontSize: responsive.fontSize(
              mobile: 11,
              tablet: 12,
              desktop: 13,
            ),
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Responsive responsive) {

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.size(mobile: 16, tablet: 18, desktop: 20),
        vertical: responsive.size(mobile: 8, tablet: 10, desktop: 10),
      ),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [

          _buildListHeader(responsive),

          const SizedBox(height: 15),

          Expanded(
            child: _buildActivityList(),
          ),

          const Divider(),

          _buildFooter(responsive),

        ],
      ),
    );
  }

  Widget _buildActivityList() {
    final ctrl = context.watch<FinancialController>();
    final responsive = Responsive(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Urutkan activities berdasarkan waktu terbaru
    final sortedActivities = [...ctrl.todaysActivities];
    sortedActivities.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedActivities.length,
      itemBuilder: (context, index) {
        final item = sortedActivities[index];

        Color valueColor = item.type == "income"
            ? Colors.green
            : item.type == "expense"
            ? Colors.red
            : Colors.orange;

        return Slidable(
          key: ValueKey(item.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: widget.isMobile ? 0.20 : 0.10,
            children: [
              SlidableAction(
                onPressed: (context) {
                  ctrl.deleteTransaction(item.id);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: "Delete",
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: valueColor.withOpacity(0.15),
                  child: Icon(item.icon, color: valueColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(item.amount),
                      style: TextStyle(
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.fontSize(mobile: 12, tablet: 14, desktop: 14),
                      ),
                    ),
                    Text(
                      DateFormat("HH:mm").format(item.date),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}