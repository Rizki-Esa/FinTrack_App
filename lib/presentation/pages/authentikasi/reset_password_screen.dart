import 'package:flutter/material.dart';
import '../../../responsive_helper.dart';
import '../../../services/api_service.dart';
import '../../widgets/pop_up/custom_dialog.dart';
import 'auth_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmHidden = true;

  Map<String, bool> getPasswordRulesStatus(String password) {
    return {
      "8 - 20 karakter": password.length >= 8 && password.length <= 20,
      "Huruf besar & kecil": RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password),
      "Minimal 1 simbol": RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  bool isPasswordValid(String password) {
    return getPasswordRulesStatus(password).values.every((e) => e);
  }

  Future<void> submit() async {

    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (!isPasswordValid(password)) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Password belum memenuhi syarat",
      );
      return;
    }

    if (password != confirm) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Password tidak sama",
      );
      return;
    }

    setState(() {});

    try {

      await ApiService.resetPassword(widget.token, password);

      CustomDialog.show(
        context: context,
        isSuccess: true,
        message: "Password berhasil diperbarui",
        onComplete: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
          );
        },
      );

    } catch (e) {

      CustomDialog.show(
        context: context,
        isSuccess: false,
        message: "Gagal mengubah password",
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final responsive = Responsive(context);
    final rules = getPasswordRulesStatus(passwordController.text);

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
              BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5))
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
                "Reset Password",
                style: TextStyle(
                  fontSize: responsive.fontSize(mobile: 20, tablet: 22, desktop: 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Password harus memenuhi kriteria:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Builder(
                    builder: (_) {
                      final password = passwordController.text.trim();
                      final rules = getPasswordRulesStatus(password);
                      final allValid = isPasswordValid(password);

                      /// ✅ JIKA SEMUA VALID
                      if (allValid && password.isNotEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            "Password sudah sesuai kriteria ✅",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      /// ❌ JIKA BELUM VALID → TAMPILKAN CHECKLIST
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rules.entries.map((entry) {
                          return Row(
                            children: [
                              Icon(
                                entry.value
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 16,
                                color: entry.value ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: entry.value ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: isPasswordHidden,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.black),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: confirmController,
                obscureText: isConfirmHidden,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isConfirmHidden = !isConfirmHidden;
                      });
                    },
                  ),
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
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Submit",
                        style: TextStyle(fontSize: responsive.fontSize(mobile: 14, tablet: 15, desktop: 16,),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}