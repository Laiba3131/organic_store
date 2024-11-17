import 'package:ecomerance_app/Screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Auth/firestore.dart';


class RegisterController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> register() async {
    if (registerFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirestoreService().addUserToFirestore(
          usernameController.text,
          emailController.text,
          passwordController.text

        );

        Get.to(() => SignInScreen());
        reset(); // Clear form fields and error message
      } catch (e) {
    String errorMessage;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use by another account.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
    } else {
      errorMessage = 'An error occurred. Please try again.';
    }

    Get.snackbar(
      'Error',
      'Failed to register: $errorMessage',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
    }
  }

  void reset() {
    registerFormKey.currentState?.reset();
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }
}
