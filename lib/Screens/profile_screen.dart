import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomerance_app/Screens/faqs_screen.dart';
import 'package:ecomerance_app/Screens/favourite_screen.dart';
import 'package:ecomerance_app/Screens/help_and_support_screen.dart';
import 'package:ecomerance_app/Screens/language_screen.dart';
import 'package:ecomerance_app/Screens/legal_and_policy_screen.dart';
import 'package:ecomerance_app/Screens/notification_screen.dart';
import 'package:ecomerance_app/Screens/security_screen.dart';
import 'package:ecomerance_app/Screens/update_profile_screen.dart';
import 'package:ecomerance_app/Screens/welcome_screen.dart';
import 'package:ecomerance_app/routes/route_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../AppColors/appcolors.dart';
import '../Auth/firestore.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import '../CustomWidgets/customListTile.dart';
import 'my_order_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  Map<String, dynamic>? userData;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when the screen initializes
  }

  Future<void> fetchUserData() async {
    try {
      userData = await _firestoreService.getUserData();
      if (userData != null) {
        username = userData?['userName'] ?? 'Guest';
        email = userData?['email'] ?? 'No Email';
      }
      setState(() {}); // Update the UI after fetching data
    } catch (e) {
      // Handle error fetching user data
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  shadowColor: AppColors.lightPrimary,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (userData?["imageUrl"] != null &&
                                  userData?["imageUrl"] != '')
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                    child: CircularProgressIndicator(
                                      value: progress.progress,
                                    ),
                                  ),
                                  imageUrl: userData?["imageUrl"],
                                )
                              : Icon(Icons.person,
                                  size: 50, color: Colors.white),
                        ),
                      ),
                      title: AppText(
                        text: username.toUpperCase(),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: AppText(
                        text: email,
                        textColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CustomListTile(
                        onTap: () {
                          Get.to(() => UpdateProfileScreen());
                        },
                        title: 'Personal Details',
                        icon: Icons.person_outline,
                      ),
                      CustomListTile(
                        title: 'My Order',
                        icon: Icons.shopping_bag_outlined,
                        onTap: () {
                          Get.to(() => MyOrderScreen());
                        },
                      ),
                      CustomListTile(
                        onTap: () {
                          Get.to(() => FavouriteScreen());
                        },
                        title: 'My Favourites',
                        icon: Icons.favorite_outline,
                      ),
                      // CustomListTile(
                      //   title: 'Shipping Address',
                      //   icon: Icons.local_shipping_outlined,
                      // ),
                      // CustomListTile(
                      //   title: 'My Card',
                      //   icon: Icons.credit_card_outlined,
                      // ),

                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                  Column(
                    children: [
                      CustomListTile(
                        title: 'FAQs',
                        icon: Icons.help_outline,
                        onTap: () {
                          Get.to(()=>FAQsScreen());

                        },
                      ),
                      CustomListTile(
                        title: 'Help And Support',
                        icon: Icons.support_agent_outlined,
                        onTap: () {

                          Get.to(()=>HelpAndSupportScreen());
                        },
                      ),
                      CustomListTile(
                        title: 'Languages',
                        icon: Icons.language_outlined,
                        onTap: () {
                          Get.to(()=>LanguageScreen());
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      CustomListTile(
                        title: 'Notifications',
                        icon: Icons.notifications_off_outlined,
                        onTap: () {
                          Get.to(()=>NotificationScreen());
                        },
                      ),
                      CustomListTile(
                        title: 'Security',
                        icon: Icons.security_outlined,
                        onTap: () {
                          Get.to(()=>SecurityScreen());
                        },
                      ),
                      CustomListTile(
                        title: 'Legal and Polices',
                        icon: Icons.policy_outlined,
                        onTap: () {
                          Get.to(()=>LegalAndPolicyScreen());
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CustomListTile(
                        title: 'Logout',
                        icon: Icons.logout,
                        onTap: () {
                          _showSuccessDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.close),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                textAlign: TextAlign.center,
                text: 'Are you sure you want to logout?',
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ],
          ),
          actions: [
            CustomButton(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              label: 'Cancel',
              labelColor: Colors.white,
              bgColor: AppColors.primary,
            ),
            CustomButton(
              onTap: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
                Get.to(() => WelcomeScreen());
              },
              label: 'Log Out',
              labelColor: Colors.red,
              bgColor: Colors.transparent,
            ),
          ],
        );
      },
    );
  }
}