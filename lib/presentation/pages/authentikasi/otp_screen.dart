import 'package:flutter/material.dart';
import '../../../responsive_helper.dart';
import '../../../services/api_service.dart';
import '../../widgets/pop_up/custom_dialog.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final otpController = TextEditingController();

  Future<void> verifyOTP() async {

    setState(() {});

    try {

      final response = await ApiService.verifyOTP(
        widget.email,
        otpController.text.trim(),
      );

      final token = response.data["reset_token"];

      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "OTP berhasil diverifikasi",
        onComplete: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: token),
            ),
          );
        },
      );

    } catch (e) {

      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "OTP salah atau expired",
      );
    }

    setState(() {});
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
                "Verify OTP",
                style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 20, tablet: 22, desktop: 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Masukkan kode OTP yang dikirim ke email",
                style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14),
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Kode OTP",
                  prefixIcon: const Icon(Icons.verified_outlined, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: responsive.size(mobile: 45, tablet: 48, desktop: 50),
                child: ElevatedButton(
                  onPressed: verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Submit",style: TextStyle(
                      fontSize: responsive.fontSize(mobile: 14, tablet: 15, desktop: 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white)
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