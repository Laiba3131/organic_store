import 'package:ecomerance_app/Screens/googleprovider.dart';
import 'package:ecomerance_app/Screens/notification_page.dart';
import 'package:ecomerance_app/Screens/stripescreen.dart';
import 'package:ecomerance_app/firebase_options.dart';
import 'package:ecomerance_app/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'Screens/splash_screen.dart';
import 'controllers/chat_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 await FirebaseApi().initNotifications();
  Stripe.publishableKey =
      'pk_test_51PlB8iBwFdLEhpT1ik70Ywl3IZaxIXg6HzKd9HkQOXkNq6vQa5d932hxTDnlTfhtXH1huY6AbAbhYJbFnemyrVM700rgeTe10k';
  await Stripe.instance.applySettings();
  Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => PaymentController()),
    ChangeNotifierProvider(create: (context) => AddressProvider())
  ], child: MyApp()));
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrganicStore.COM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
       navigatorKey: navigatorKey, 
      home: const SplashScreen(),
      routes: {
        '/notification_screen':(context)=>const NotificationPage(),
      },
    );
  }
}




