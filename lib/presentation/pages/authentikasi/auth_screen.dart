import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../responsive_helper.dart';
import '../../../services/auth_service.dart';
import '../../../services/google_button.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/pop_up/custom_dialog.dart';
import '../navigation.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  bool isLogin = true;
  bool isHoverForgot = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();


  Map<String, bool> getPasswordRulesStatus(String password) {
    return {
      "Password berisi 8 - 20 karakter":
      password.length >= 8 && password.length <= 20,
      "Minimal 1 huruf kapital & 1 huruf kecil":
      RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password),
      "Minimal 1 simbol (@, #, %, &, dll)":
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    };
  }

  bool isPasswordValid(String password) {
    final rules = getPasswordRulesStatus(password);
    return rules.values.every((v) => v);
  }

  bool isValidName(String name) {
    return name.trim().isNotEmpty && name.length <= 30;
  }

  bool isValidEmailFormat(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(email);
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
  }

  void showError(BuildContext context, String message) {
    CustomDialog.show(
      context: context,
      isSuccess: false,
      message: message,
      isDarkMode: false,
    );
  }

  void showSuccess(BuildContext context, String message, {VoidCallback? onComplete,}) {
    CustomDialog.show(
      context: context,
      isSuccess: true,
      message: message,
      isDarkMode: false,
      onComplete: onComplete,
    );
  }

  @override
  Widget build(BuildContext context) {

    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      resizeToAvoidBottomInset: true,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(

            /// RESPONSIVE WIDTH
            width: responsive.value(
              mobile: responsive.width * 0.9,
              tablet: 480,
              desktop: 480,
            ),

            padding: responsive.padding(
              mobile: 24,
              tablet: 26,
              desktop: 26,
            ),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// TITLE
                Text(
                  isLogin ? "Welcome Back" : "Create Account",
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

                /// DESCRIPTION
                Text(
                  isLogin
                      ? "Login to continue"
                      : "Register to get started",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: responsive.fontSize(
                      mobile: 13,
                      tablet: 14,
                      desktop: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// NAME (SIGNUP)
                if (!isLogin)
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 15),

                /// EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: Colors.black),
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                /// PASSWORD
                /// PASSWORD SECTION
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔥 PASSWORD RULES — hanya saat register
                    if (!isLogin)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Password harus memenuhi kriteria:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black
                            ),
                          ),

                          const SizedBox(height: 6),

                          Builder(
                            builder: (_) {
                              final password = passwordController.text.trim();
                              final rules = getPasswordRulesStatus(password);
                              final allValid = isPasswordValid(password);

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
                                            color:
                                            entry.value ? Colors.green : Colors.grey,
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

                    /// PASSWORD INPUT
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.black),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    /// 🔐 CONFIRM PASSWORD — hanya register
                    if (!isLogin) ...[
                      const SizedBox(height: 12),

                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: const TextStyle(color: Colors.black),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ],

                    /// FORGOT PASSWORD (LOGIN ONLY)
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ),
                  ],
                ),

                const SizedBox(height: 15),

                /// MAIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: responsive.size(
                    mobile: 46,
                    tablet: 48,
                    desktop: 50,
                  ),

                  child: ElevatedButton(
                    onPressed: () async {

                      final auth = context.read<AuthController>();
                      final name = nameController.text.trim();
                      final email = emailController.text.trim().toLowerCase();
                      final password = passwordController.text.trim();
                      final confirmPassword = confirmPasswordController.text.trim();

                      if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
                        showError(context, "Please fill all fields");
                        return;
                      }

                      if (isLogin) {

                        bool success = await auth.login(email, password);

                        if (success) {

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Navigation(),
                            ),
                          );

                        } else {
                          showError(context, "Invalid email or password");
                        }

                      } else {
                        if (!isValidName(name)) {
                          showError(context, "Name cannot be empty (max 30 characters)");
                          return;
                        }
                        if (email.isEmpty) {
                          showError(context, "Email cannot be empty");
                          return;
                        }
                        if (!isValidEmailFormat(email)) {
                          showError(context, "Please enter a valid email address");
                          return;
                        }
                        if (password.isEmpty) {
                          showError(context, "Password cannot be empty");
                          return;
                        }

                        if (!isPasswordValid(password)) {
                          showError(context, "Password tidak memenuhi ketentuan");
                          return;
                        }

                        if (confirmPassword.isEmpty) {
                          showError(context, "Please confirm your password");
                          return;
                        }

                        if (password != confirmPassword) {
                          showError(context, "Password and confirm password do not match");
                          return;
                        }

                        try {

                          bool success = await auth.register(name, email, password);

                          if (success) {
                            showSuccess(
                              context,
                              "Account created successfully",
                              onComplete: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Navigation(),
                                  ),
                                );
                              },
                            );
                          }

                        } catch (e) {
                          /// ERROR DARI BACKEND
                          showError(context, e.toString());
                        }
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      isLogin ? "Sign In" : "Sign Up",
                      style: TextStyle(
                        fontSize: responsive.fontSize(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                GoogleButton(
                  onSuccess: (accessToken) async {
                    final auth = context.read<AuthController>();

                    try {
                      final data =
                      await AuthService.loginWithGoogleToken(accessToken);

                      auth.user = data["user"];
                      auth.isAuthenticated = true;
                      auth.isGoogleLogin = true;

                      if (!mounted) return;

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const Navigation(),
                        ),
                      );

                    } catch (e) {
                      debugPrint("ERROR GOOGLE LOGIN: $e");
                    }
                  },
                ),

                const SizedBox(height: 20),

                /// SWITCH LOGIN SIGNUP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      isLogin
                          ? "Belum memiliki akun?"
                          : "Sudah memiliki akun?",
                      style: const TextStyle(color: Colors.black),
                    ),

                    const SizedBox(width: 5),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          clearFields();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isLogin ? "Sign Up" : "Sign In",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}