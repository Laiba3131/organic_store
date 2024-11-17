import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/Screens/signup_screen.dart';
import 'package:ecomerance_app/Screens/welcome_screen.dart';
import 'package:ecomerance_app/admin/View/admin_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSignupScreen extends StatelessWidget {
  const CommonSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             CustomButton(
                    onTap: () {
                      Get.to(()=>const AdminSignUpScreen());
                    },
                    label: 'Sign up as admin',
                    bgColor: AppColors.primary,
                    labelColor: Colors.white,
                    borderRadius: 50,
                    height: 50,
                  ),
                   const SizedBox(height: 10),
                  CustomButton(
                    onTap: () {
                      Get.to(()=>const SignUpScreen());
                    },
                    label: 'Sign up as user',
                    bgColor: AppColors.primary,
                    labelColor: Colors.white,
                    borderRadius: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                   RichText(
                    text: TextSpan(
                      text: "Already have an account ?  ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(()=>WelcomeScreen());
                            },
                          text: 'Login',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}