import 'package:flutter/material.dart';
import 'package:frontend_fintrack/presentation/controllers/auth_controller.dart';
import 'package:frontend_fintrack/presentation/controllers/financial_controller.dart';
import 'package:frontend_fintrack/presentation/controllers/setting_profile_controller.dart';
import 'package:frontend_fintrack/presentation/pages/authentikasi/auth_guard.dart';
import 'package:frontend_fintrack/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.initInterceptor();

  await Firebase.initializeApp(
    options: kIsWeb
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController()..checkLogin(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingProfileController(),
        ),
        ChangeNotifierProvider(
          create: (_) => FinancialController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dashboard Financial Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: AuthGuard(),
    );
  }
}