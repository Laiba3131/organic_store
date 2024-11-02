import 'package:ecomerance_app/Screens/stripescreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../CustomWidgets/appText.dart';
import '../card_screen.dart';
// Import the PaymentController

class CardPayment extends StatefulWidget {
  CardPayment({super.key, required this.amount});
  String amount;

  @override
  State<CardPayment> createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  Map<String, dynamic>? selectedCard; // Variable to store selected card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                // Navigate to PaymentMethod screen and wait for result
                Map<String, dynamic>? result = await Get.to(() => CardScreen());

                if (result != null) {
                  setState(() {
                    selectedCard = result; // Update selected card data
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: 'Visa',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                    SizedBox(width: 10),
                    AppText(
                      text: selectedCard != null
                          ? '**** **** **** ${selectedCard!['cardNumber'].substring(selectedCard!['cardNumber'].length - 4)}'
                          : '**** **** **** 2512', // Default value
                      fontWeight: FontWeight.w500,
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        // Check if a card is selected before making payment
                        if (selectedCard == null) {
                          // Show error if no card is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a card before proceeding.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Proceed with payment if card is selected
                          Provider.of<PaymentController>(context, listen: false)
                              .makePayment(
                              amount: widget.amount.toString(),
                              currency: 'usd',
                              addSubFunction: () {},
                              onSuccess: () {
                                // Navigate to order confirmation screen or perform other actions
                                  Navigator.pushNamed(context, '/orderConfirmation');
                              },
                              onFailure: () {
                                // Show error if payment fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment failed. Please try again.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });

                        }
                      },
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
