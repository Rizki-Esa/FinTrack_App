import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/activity_data.dart';
import '../../../utils/currency_input_formatter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/financial_controller.dart';
import '../../widgets/button/action_button.dart';

class FinancialEntryScreen extends StatelessWidget {
  final bool isDarkMode;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int userId; // ID user yang sedang authentikasi

  const FinancialEntryScreen({
    super.key,
    required this.isDarkMode,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final authCtrl = context.read<AuthController>();
    final userId = authCtrl.user?['id'] ?? 0;

    double popupWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.5;
    double popupHeight = isMobile ? screenHeight * 0.6 : screenHeight * 0.7;

    return  Consumer<FinancialController>(
      builder: (context, ctrl, _) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Center(
            child: Container(
              width: popupWidth,
              height: popupHeight,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  /// ===== TYPE SELECTOR =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _typeButton(context, "income", "Income", Colors.green),
                      const SizedBox(width: 8),
                      _typeButton(context, "expense", "Expense", Colors.red),
                      const SizedBox(width: 8),
                      _typeButton(context, "saving", "Saving", Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 36),

                  /// ===== CATEGORY DROPDOWN =====
                  DropdownButtonFormField<String>(
                    value: ctrl.selectedCategory,
                    items: ctrl.categories[ctrl.selectedType]!
                        .map(
                          (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                        .toList(),
                    onChanged: (value) => ctrl.changeCategory(value!),
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ===== SUBTITLE =====
                  TextField(
                    controller: ctrl.subtitleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: "Subtitle",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===== VALUE =====
                  TextField(
                    controller: ctrl.amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      CurrencyInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const Spacer(),

                  /// ===== BUTTONS =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ActionButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.close,
                        label: "Cancel",
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),

                      ctrl.isLoading
                          ? const CircularProgressIndicator()
                          : ActionButton(
                        onPressed: () async {

                          final success = await ctrl.submitTransaction(userId: userId);
                          if (success) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to submit transaction"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icons.check,
                        label: "Entry",
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ===== TYPE BUTTON WIDGET =====
  Widget _typeButton(BuildContext context, String type, String label, Color color) {
    final ctrl = Provider.of<FinancialController>(context);
    final bool active = ctrl.selectedType == type;

    return GestureDetector(
      onTap: () => ctrl.changeType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}