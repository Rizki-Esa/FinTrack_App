import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/financial_controller.dart';
import '../navigation.dart';
import 'auth_screen.dart';

class AuthGuard extends StatelessWidget {

  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthController>();
    final authCtrl = context.read<AuthController>();
    final userId = authCtrl.user?['id'];
    if (userId != null) {
      final financialCtrl = context.read<FinancialController>();
      financialCtrl.loadUserActivities(userId);
    }

    if (auth.isAuthenticated) {
      return const Navigation();
    }
    return const AuthScreen();
  }
}