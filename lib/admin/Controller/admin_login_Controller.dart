
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../View/admin_bottom_navigation.dart';

class AdminLoginController extends GetxController {
  final adminformKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var isLoading = false.obs; // Observable loading state
  var errorMessage = ''.obs; 

  Future<void> adminLogin() async {
    if (adminformKey.currentState!.validate()) {
      isLoading.value = true; 
      errorMessage.value = ''; 
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(userCredential.user!.uid)
            .get();

        if (adminSnapshot.exists) {
          Get.offAll(() => AdminBottomNevigationBar());
          emailController.clear();
          passwordController.clear();
        } else {
          errorMessage.value = 'Not a valid admin user.';
          Get.snackbar(
            'Error',
            errorMessage.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorMessage.value = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage.value = 'Wrong password provided.';
        } else {
          errorMessage.value = 'Login failed: ${e.message}';
        }
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } on FirebaseException catch (e) {
        errorMessage.value = 'Firebase Error: ${e.message}';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } catch (e) {
       
        errorMessage.value = 'Unexpected Error: ${e.toString()}';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false; 
      }
    }
  }

}
