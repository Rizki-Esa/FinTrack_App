import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../responsive_helper.dart';
import '../../../services/pdfservice.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/financial_controller.dart';
import '../../widgets/button/action_button.dart';
import '../../widgets/button/loading_action_button.dart';
import 'package:printing/printing.dart';
import '../../../data/period_summary.dart';

class HistoryScreen extends StatefulWidget {

  final bool isDarkMode;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const HistoryScreen({
    super.key,
    required this.isDarkMode,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedYear = DateTime.now().year;
  bool _isDownloading = false;
  bool _isYearDropdownOpen = false;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final GlobalKey _filterKey = GlobalKey();

  int? userId;

  @override
  void initState() {
    super.initState();
    final authCtrl = Provider.of<AuthController>(context, listen: false);
    userId = authCtrl.user?['id'];
  }

  List<int> getAvailableYears(List activities) {

    final years = activities
        .map<int>((a) => a.date.year)
        .toSet()
        .toList();

    years.sort((a, b) => b.compareTo(a));

    return years;
  }

  List<PeriodSummary> generateMonthlySummary(List activities) {

    Map<String, PeriodSummary> map = {};

    for (var a in activities) {

      final date = a.date;
      if (date.year != selectedYear) continue;

      final key = "${date.year}-${date.month}";

      if (!map.containsKey(key)) {
        map[key] = PeriodSummary(
          date: DateTime(date.year, date.month),
          income: 0,
          expense: 0,
          savings: 0,
        );
      }

      if (a.type == "income") {
        map[key]!.income += a.amount;
      } else if (a.type == "expense") {
        map[key]!.expense += a.amount.abs();
      } else if (a.type == "saving") {
        map[key]!.savings += a.amount;
      }
    }

    final list = map.values.toList();

    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }

  String getDateLabel(DateTime date) {

    if (widget.isMobile) {
      return DateFormat("MMM\nyyyy").format(date);
    }

    return DateFormat("MMMM yyyy").format(date);
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
          child: _buildHistoryCard(responsive),
        ),

      ],
    );
  }

  void _showYearFilter() async {

    setState(() {
      _isYearDropdownOpen = true;
    });

    final RenderBox button =
    _filterKey.currentContext!.findRenderObject() as RenderBox;

    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final ctrl = Provider.of<FinancialController>(context, listen: false);
    final years = getAvailableYears(ctrl.allActivities);
    final size = button.size;

    final screenHeight = MediaQuery.of(context).size.height;

    final selected = await showMenu<int>(
      context: context,
      color: widget.isDarkMode
          ? Colors.grey[850]
          : Colors.white,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 12,
        position.dx + size.width,
        0,
      ),
      constraints: BoxConstraints(
        maxHeight: screenHeight * (widget.isMobile ? 0.20 : 0.30),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: years.map((year) {

        return PopupMenuItem<int>(
          value: year,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 10),
                Text(
                  "$year",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    setState(() {
      _isYearDropdownOpen = false;
    });

    if (selected != null) {
      setState(() {
        selectedYear = selected;
      });
    }
  }

  Widget _buildSummary(Responsive responsive) {

    final ctrl = Provider.of<FinancialController>(context);
    final activities = ctrl.allActivities
        .where((a) => a.userId == userId)
        .toList();
    final data = generateMonthlySummary(activities);

    double income = 0;
    double expense = 0;
    double savings = 0;

    for (var item in data) {
      income += item.income;
      expense += item.expense;
      savings += item.savings;
    }

    final balance = income - expense - savings;

    if (widget.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _summaryCard("Income", income, Colors.green),
              _summaryCard("Expense", expense, Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _summaryCard("Savings", savings, Colors.orange),
              _summaryCard("Balance", balance, Colors.blue),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        _summaryCard("Income", income, Colors.green),
        _summaryCard("Expense", expense, Colors.red),
        _summaryCard("Savings", savings, Colors.orange),
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

  Widget _buildHistoryCard(Responsive responsive) {

    final ctrl = Provider.of<FinancialController>(context);
    final activities = ctrl.allActivities
        .where((a) => a.userId == userId)
        .toList();
    final data = generateMonthlySummary(activities);

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

          /// HEADER (title + filter)
          _buildHeaderRow(responsive),

          const SizedBox(height: 12),

          Expanded(
            child: _buildHistoryList(data, responsive),
          ),

          const Divider(),

          _buildFooter(),

        ],
      ),
    );
  }

  Widget _buildHeaderRow(Responsive responsive) {
    return Row(
      children: [

        Text(
          "History Financial",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: responsive.fontSize(
              mobile: 16,
              tablet: 17,
              desktop: 18,
            ),
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),

        const Spacer(),

        InkWell(
          key: _filterKey,
          onTap: () => _showYearFilter(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 18),
                const SizedBox(width: 6),

                Text(
                  "$selectedYear",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(width: 4),

                Icon(
                  _isYearDropdownOpen
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildHistoryList(List<PeriodSummary> data, Responsive responsive) {

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: data.length,
      itemBuilder: (context, index) {

        final item = data[index];

        return Stack(
          children: [

            Container(
              padding: EdgeInsets.fromLTRB(12, 12, widget.isMobile ? 12 : 80, 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  /// DATA
                  Expanded(
                    child: widget.isMobile
                        ? _buildMobileItem(item)
                        : _buildDesktopItem(item, responsive),
                  ),

                ],
              ),
            ),

            Positioned(
              right: 20,
              top: 10,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    _openDetailPopup(item);
                  },
                  child: const Icon(
                    Icons.open_in_new,
                    color: Colors.blue,
                  ),
                ),
              ),
            )

          ],
        );
      },
    );
  }

  Widget _buildDesktopItem(PeriodSummary item, Responsive responsive) {
    return Row(
      children: [

        SizedBox(width: responsive.isMobile ? 12 : 20),

        SizedBox(
          width: 110,
          child: Text(
            DateFormat("MMMM yyyy").format(item.date),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildDesktopSummary(item),
        ),

      ],
    );
  }

  Widget _buildMobileItem(PeriodSummary item) {

    Widget value(String text, Color color) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// MONTH
        Text(
          DateFormat("MMMM yyyy").format(item.date),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        /// NUMBERS
        Row(
          children: [

            Expanded(
              child: value(
                currencyFormatter.format(item.income),
                Colors.green,
              ),
            ),

            Expanded(
              child: value(
                currencyFormatter.format(item.expense),
                Colors.red,
              ),
            ),

          ],
        ),

        const SizedBox(height: 4),

        Row(
          children: [

            Expanded(
              child: value(
                currencyFormatter.format(item.savings),
                Colors.orange,
              ),
            ),

            Expanded(
              child: value(
                currencyFormatter.format(item.balance),
                Colors.blue,
              ),
            ),

          ],
        ),

      ],
    );
  }

  Widget _buildDesktopSummary(PeriodSummary item) {
    Widget value(double val, Color color) {
      return Align(
        alignment: Alignment.centerRight,
        child: Text(
          currencyFormatter.format(val),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Row(
      children: [

        Expanded(child: value(item.income, Colors.green)),

        Expanded(child: value(item.expense, Colors.red)),

        Expanded(child: value(item.savings, Colors.orange)),

        Expanded(child: value(item.balance, Colors.blue)),

      ],
    );
  }

  void _openDetailPopup(PeriodSummary summary) async {

    final ctrl = Provider.of<FinancialController>(context, listen: false);
    final activities = ctrl.allActivities
        .where((a) => a.userId == userId)
        .where((a) =>
    a.date.year == summary.date.year &&
        a.date.month == summary.date.month)
        .toList();

    final pdfBytes = await PdfService.generateFinancialPdf(
      summary,
      activities,   // ✅ sekarang sesuai bulan
      'Month',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width *
                (widget.isMobile ? 0.95 : 0.8),
            height: MediaQuery.of(context).size.height *
                (widget.isMobile ? 0.65 : 0.85),
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      ActionButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.close,
                        label: "Close",
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),

                const Divider(),

                /// PDF VIEW
                Expanded(
                  child: PdfPreview(
                    build: (format) async => pdfBytes,
                    useActions: false,
                  ),
                ),

                const Divider(),

                /// FOOTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        "PDF Preview",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      LoadingActionButton(
                        isLoading: _isDownloading,
                        icon: Icons.download,
                        label: "Download",
                        loadingLabel: "Downloading...",
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          setState(() => _isDownloading = true);

                          final month = DateFormat('MM').format(summary.date);
                          final year = summary.date.year;

                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: "Financial_History_${year}_$month.pdf",
                          );

                          setState(() => _isDownloading = false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
      ),
    );
  }
}