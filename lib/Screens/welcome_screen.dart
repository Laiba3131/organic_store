import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/Screens/common_signup_screen.dart';
import 'package:ecomerance_app/Screens/signin_screen.dart';
import 'package:ecomerance_app/admin/View/admin_login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppColors/appcolors.dart';
import '../CustomWidgets/appText.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/splashicon.png',
                  height: 200,
                  width: 200,
                ),
                const AppText(
                  text: "Let's you in",
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
                // CustomButton(
                //   label: 'Continue with Facebook',
                //   borderColor: Colors.grey.withOpacity(.5),
                //   imagePath: 'assets/icons/facebook.svg',
                // ),
                // CustomButton(
                //   label: 'Continue with Google',
                //   borderColor: Colors.grey.withOpacity(.5),
                //   imagePath: 'assets/icons/google.svg',
                // ),
                // CustomButton(
                //   label: 'Continue with Apple',
                //   borderColor: Colors.grey.withOpacity(.5),
                //   imagePath: 'assets/icons/apple.svg',
                // ),
                // const SizedBox(height: 10),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(child: Divider(color: Colors.grey)),
                //       Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 5),
                //         child: AppText(text: "Or", fontSize: 12),
                //       ),
                //       Expanded(child: Divider(color: Colors.grey)),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 10),
                CustomButton(
                  onTap: () {
                    Get.to(()=>const AdminLoginScreen());
                  },
                  label: 'Login as admin',
                  bgColor: AppColors.primary,
                  labelColor: Colors.white,
                  borderRadius: 50,
                  height: 50,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onTap: () {
                    Get.to(()=>const SignInScreen());
                  },
                  label: 'Login as user',
                  bgColor: AppColors.primary,
                  labelColor: Colors.white,
                  borderRadius: 50,
                  height: 50,
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: "Don’t have an account ?  ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(()=>CommonSignupScreen());
                          },
                        text: 'sign up',
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
        ));
  }
}
