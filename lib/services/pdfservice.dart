import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../data/period_summary.dart';
import '../data/activity_data.dart';

class PdfService {

  static final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static double _runningBalance = 0;

  static String _buildPeriodTitle(PeriodSummary summary, String range) {

    if (range == "Month") {
      return DateFormat('MMMM yyyy').format(summary.date);
    }

    if (range == "Day") {
      return DateFormat('dd MMMM yyyy').format(summary.date);
    }

    if (range == "Year") {
      return summary.date.year.toString();
    }

    return range;
  }

  /// LOAD FONT
  static Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  /// FORMAT RUPIAH
  static String formatCurrency(double value) {
    return _rupiah.format(value);
  }

  /// STYLE AMOUNT
  static pw.TextStyle _amountStyle(
      double value,
      pw.Font font, {
        String? type,
      }) {

    if (type == "income") {
      return pw.TextStyle(
        font: font,
        fontSize: 8,
        color: PdfColors.green700,
      );
    }

    if (type == "expense") {
      return pw.TextStyle(
        font: font,
        fontSize: 8,
        color: PdfColors.red700,
      );
    }

    if (type == "saving") {
      return pw.TextStyle(
        font: font,
        fontSize: 8,
        color: PdfColors.orange700,
      );
    }

    if (type == "balance") {
      return pw.TextStyle(
        font: font,
        fontSize: 8,
        color: PdfColors.blue700,
      );
    }

    return pw.TextStyle(font: font, fontSize: 8);
  }

  /// NORMAL CELL
  static pw.Widget _cell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8),
      ),
    );
  }

  /// AMOUNT CELL
  static pw.Widget _amountCell(
      double? value,
      pw.Font font, {
        String? type,
      }) {

    if (value == null) {
      return _cell("-", font);
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          formatCurrency(value),
          style: _amountStyle(value, font, type: type),
        ),
      ),
    );
  }

  /// RUNNING BALANCE CELL
  static pw.Widget _runningBalanceCell(
      ActivityData item,
      pw.Font font,
      ) {

    if (item.type == "income") {
      _runningBalance += item.amount;
    } else if (item.type == "expense") {
      _runningBalance -= item.amount;
    } else if (item.type == "saving") {
      _runningBalance -= item.amount;
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          formatCurrency(_runningBalance),
          style: _amountStyle(
            _runningBalance,
            font,
            type: "balance",
          ),
        ),
      )
    );
  }

  /// BUILD PERIOD DATE
  static String _buildPeriodDate(PeriodSummary summary, String range) {

    if (range == "Day") {
      return "${summary.date.day}/${summary.date.month}/${summary.date.year}";
    }

    if (range == "Month") {

      final start = DateTime(summary.date.year, summary.date.month, 1);
      final end = DateTime(summary.date.year, summary.date.month + 1, 0);

      return "${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}";
    }

    if (range == "Year") {
      return "01/01/${summary.date.year} - 31/12/${summary.date.year}";
    }

    return summary.date.toString();
  }

  /// GROUP ACTIVITIES BY DATE
  static Map<String, List<ActivityData>> _groupByDate(
      List<ActivityData> activities,
      ) {

    Map<String, List<ActivityData>> grouped = {};

    for (var item in activities) {

      final key =
          "${item.date.day}/${item.date.month}/${item.date.year}";

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    return grouped;
  }

  /// BUILD TABLE
  static List<pw.Widget> _buildTable(
      List<ActivityData> activities,
      pw.Font font,
      pw.Font fontBold,
      ) {

    final grouped = _groupByDate(activities);

    int counter = 1;

    List<pw.Widget> sections = [];

    grouped.forEach((date, items) {

      /// DATE HEADER
      sections.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            date,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 10,
            ),
          ),
        ),
      );

      sections.add(pw.Divider());

      /// TABLE
      sections.add(
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(20),
            1: const pw.FlexColumnWidth(),
            2: const pw.FlexColumnWidth(),
            3: const pw.FixedColumnWidth(70),
            4: const pw.FixedColumnWidth(70),
            5: const pw.FixedColumnWidth(70),
            6: const pw.FixedColumnWidth(80),
          },
          children: [

            /// HEADER
            pw.TableRow(
              children: [
                _cell("No", fontBold),
                _cell("Category", fontBold),
                _cell("Description", fontBold),
                _cell("Income", fontBold),
                _cell("Expense", fontBold),
                _cell("Saving", fontBold),
                _cell("Balance", fontBold),
              ],
            ),

            ...items.map((item) {

              final row = pw.TableRow(
                children: [

                  /// NO
                  _cell("${counter++}", font),

                  /// CATEGORY
                  _cell(item.category, font),

                  /// DESCRIPTION
                  _cell(item.description, font),

                  /// INCOME
                  _amountCell(
                    item.type == "income" ? item.amount : null,
                    font,
                    type: "income",
                  ),

                  /// EXPENSE
                  _amountCell(
                    item.type == "expense" ? item.amount : null,
                    font,
                    type: "expense",
                  ),

                  /// SAVING
                  _amountCell(
                    item.type == "saving" ? item.amount : null,
                    font,
                    type: "saving",
                  ),

                  /// BALANCE
                  _runningBalanceCell(item, font),
                ],
              );

              return row;

            }).toList(),
          ],
        ),
      );
    });

    return sections;
  }

  /// GENERATE PDF
  static Future<Uint8List> generateFinancialPdf(
      PeriodSummary summary,
      List<ActivityData> activities,
      String range,
      ) async {

    final fontRegular =
    await _loadFont('assets/fonts/Roboto/static/Roboto-Regular.ttf');

    final fontBold =
    await _loadFont('assets/fonts/Roboto/static/Roboto-Bold.ttf');

    final pdf = pw.Document();

    _runningBalance = 0;

    pdf.addPage(

      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) {

          return [

            /// TITLE
            pw.Center(
              child: pw.Text(
                "Financial Report",
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                ),
              ),
            ),

            pw.SizedBox(height: 8),

            /// PERIOD
            pw.Text(
              "Periode: ${_buildPeriodTitle(summary, range)}",
              style: pw.TextStyle(font: fontBold),
            ),

            pw.Text(
              "Tanggal: ${_buildPeriodDate(summary, range)}",
              style: pw.TextStyle(font: fontRegular),
            ),

            pw.Divider(),


            /// SUMMARY
            pw.Text(
              "Total Income: ${formatCurrency(summary.income)}",
              style: pw.TextStyle(font: fontRegular),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              "Total Expense: ${formatCurrency(summary.expense)}",
              style: pw.TextStyle(font: fontRegular),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              "Total Saving: ${formatCurrency(summary.savings)}",
              style: pw.TextStyle(font: fontRegular),
            ),

            pw.SizedBox(height: 4),

            pw.Text(
              "Total Balance: ${formatCurrency(summary.balance)}",
              style: pw.TextStyle(font: fontRegular),
            ),

            pw.Divider(),

            /// DETAIL TITLE
            pw.Text(
              "Detail Transactions",
              style: pw.TextStyle(font: fontBold),
            ),

            pw.SizedBox(height: 8),

            /// TABLE
            ..._buildTable(activities, fontRegular, fontBold),
          ];
        },
      ),
    );

    return pdf.save();
  }
}