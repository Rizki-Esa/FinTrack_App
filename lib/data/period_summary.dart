class PeriodSummary {
  DateTime date;
  double income;
  double expense;
  double savings;

  PeriodSummary({
    required this.date,
    this.income = 0,
    this.expense = 0,
    this.savings = 0,
  });

  double get balance => income - expense - savings;
}