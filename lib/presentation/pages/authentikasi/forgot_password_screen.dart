import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../responsive_helper.dart';
import '../../../services/api_service.dart';
import '../../widgets/pop_up/custom_dialog.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailController = TextEditingController();
  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email);
  }

  Future<void> submit() async {

    final email = emailController.text.trim();

    if (!isValidEmail(email)) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Email tidak valid",
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      await ApiService.forgotPassword(email);

      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Kode OTP telah dikirim",
        onComplete: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(email: email),
            ),
          );
        },
      );

    } on DioException catch (e) {

      final msg =
          e.response?.data["error"] ??
              "Email tidak terdaftar";

      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: msg,
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Center(
        child: Container(
          width: responsive.size(
            mobile: responsive.width * 0.9,
            tablet: 500,
            desktop: 500,
          ),
          padding: responsive.padding(
            mobile: 20,
            tablet: 24,
            desktop: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 20,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),

              const SizedBox(height: 10),

              Text(
                "Forget password",
                style: TextStyle(
                  fontSize: responsive.fontSize(
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Don't worry sometimes people can forget too, enter your email and we will send you a code for reset password",
                style: TextStyle(
                  fontSize: responsive.fontSize(
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "E-mail",
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: responsive.size(
                  mobile: 45,
                  tablet: 48,
                  desktop: 50,
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.grey,)
                      : Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: responsive.fontSize(
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}