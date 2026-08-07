import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../app/router/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 25,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 20),

              Image.asset(
                'assets/icons/logo.png',
                width: 120,
              ),

              const SizedBox(height: 25),

              Text(
                "Create Account",
                style: AppTextStyles.display,
              ),

              const SizedBox(height: 10),

              Text(
                "Join CareFlow and find the\nright healthcare faster.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),

              const SizedBox(height: 35),

              TextField(
                decoration: InputDecoration(
                  hintText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                decoration: InputDecoration(
                  hintText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",

                  prefixIcon: const Icon(Icons.lock_outline),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  hintText: "Confirm Password",

                  prefixIcon: const Icon(Icons.lock_outline),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Checkbox(
                    value: agree,
                    activeColor: AppColors.primary,

                    onChanged: (value) {
                      setState(() {
                        agree = value!;
                      });
                    },
                  ),

                  const Expanded(
                    child: Text(
                      "I agree to the Terms and Conditions",
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.otp,
                    );
                  },

                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text(
                    "Already have an account?",
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      );
                    },
                    child: const Text("Login"),
                  ),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}