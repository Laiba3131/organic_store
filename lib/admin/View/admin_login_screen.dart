import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/CustomTextformField.dart';
import '../../CustomWidgets/appText.dart';
import '../../Screens/welcome_screen.dart';
import '../Controller/admin_login_Controller.dart';
import 'admin_signup_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  AdminLoginController controller = Get.put(AdminLoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.to(() => WelcomeScreen());
          },
          icon: Icon(Icons.arrow_back_ios,),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: SingleChildScrollView(
            child: Form(
              key: controller.adminformKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: AppText(
                      text: 'Login your account',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,

                    ),
                  ),
                  const SizedBox(height: 20),
                  const AppText(text: 'Email', fontSize: 16),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    hintText: 'Enter your Email',
                    controller: controller.emailController,
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
                  const SizedBox(height: 10),
                  const AppText(text: 'Password', fontSize: 16,),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    hintText: 'Enter your Password',
                    controller: controller.passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  Obx(() {
                    return Column(
                      children: [
                        CustomButton(
                          labelColor: Colors.white,
                          onTap: controller.isLoading.value
                              ? null
                              : controller.adminLogin,
                          label: controller.isLoading.value
                              ? 'Loading...'
                              : 'Login',
                          bgColor: controller.isLoading.value ? Colors
                              .grey : Colors.teal,
                        ),
                        const SizedBox(height: 10),
                        if (controller.errorMessage
                            .isNotEmpty) // Display error message if not empty
                          Center(
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    );
                  }),
                  // SizedBox(height: 20),
                  // GestureDetector(
                  //     onTap: (){Get.to(()=>AdminSignUpScreen());},
                  //     child: Text('SignUp',style: TextStyle(color: Colors.white),)),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



