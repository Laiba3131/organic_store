import 'package:ecomerance_app/Screens/signup_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';
import '../controllers/login_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool checkValue = false;
  final LoginController controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppText(
                    text: 'Login to your Account',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomTextFormField(
                    controller: controller.emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    controller: controller.passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                          activeColor: AppColors.primary,
                          value: checkValue,
                          onChanged: (value) {
                          if(mounted){
                              setState(() {
                              checkValue = value!;
                            });
                          }
                          }),
                      const AppText(
                        text: 'Remember me',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() {
                    return CustomButton(
                      onTap: controller.isLoading.value ? null : controller.login,
                      label: controller.isLoading.value ? 'Loading...' : 'Login',
                      bgColor: controller.isLoading.value ? Colors.grey :  AppColors.primary,
                      labelColor: Colors.white,
                      borderRadius: 50,
                      height: 50,
                    );
                  }),
                  const SizedBox(
                    height: 40,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account ?  ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(()=>const SignUpScreen());
                            },
                          text: 'Sign Up',
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
          ),
        ),
      ),
    );
  }
}
