import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:ecomerance_app/Screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Auth/authPage.dart';
import '../admin/Auth/admin_auth_page.dart';
import '../routes/route_name.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
  Future.delayed(const Duration(seconds: 2),(){
    Get.offAll(()=>AuthDecisionScreen());
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splashicon.png',
          height: 150,
          width: 150,
        ),
      ),
    );
  }
}
class AuthDecisionScreen extends StatefulWidget {
  const AuthDecisionScreen({Key? key});

  @override
  _AuthDecisionScreenState createState() => _AuthDecisionScreenState();
}

class _AuthDecisionScreenState extends State<AuthDecisionScreen> {
  Future<bool?> _getUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          final String? role = snapshot.data()?['role'];
          if (role != null) {
            return role.toLowerCase() == 'admin';
          }
        }
      } catch (e) {
        print('Error determining user role: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: _getUserRole(),
      builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary,));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return AuthPage();
        }
        if (snapshot.data!) {
          return AdminAuthPage();
        } else {
          return AuthPage();
        }
      },
    );
  }
}