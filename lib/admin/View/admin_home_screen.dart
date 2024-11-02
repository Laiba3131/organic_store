import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/appText.dart';
import 'admin_all_orders.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: AppText(
          text: 'Admin Dashboard',
          fontSize: 20,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CustomButton(
                bgColor: Colors.teal,
                labelColor: Colors.white,
                onTap: (){
                  Get.to(()=>AdminAllOrders());
                },
                label: 'All Orders',
              )
            ],
          ),
        ),
      )
    );
  }
}
