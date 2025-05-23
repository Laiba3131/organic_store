import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../AppColors/appcolors.dart';
import '../Screens/bottom_navigationbar_screen.dart';
import '../Screens/welcome_screen.dart';





class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary,));
          }
          if (snapshot.hasData) {
            return BottomNevigationBar();
          } else {
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
