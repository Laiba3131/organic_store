import 'package:flutter/material.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart'; // Assuming this widget is correctly imported

import '../AppColors/appcolors.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({Key? key}) : super(key: key);

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'FAQs',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildQuestionAnswer(
              '1. What is this app?',
              'This app is an e-commerce platform that allows you to browse, purchase, and manage orders for a variety of products directly from your mobile device.',
            ),
            buildQuestionAnswer(
              '2. How do I create an account?',
              'To create an account, tap on the "Sign Up" button on the home screen, provide your details, and follow the prompts to complete your registration.',
            ),
            buildQuestionAnswer(
              '3. How can I reset my password?',
              'If you\'ve forgotten your password, tap on "Forgot Password" on the login screen, enter your email, and follow the instructions sent to your email to reset your password.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '4. How do I place an order?',
              'To place an order, browse through the categories, select the product you want, add it to your cart, and proceed to checkout. Follow the prompts to complete your purchase.',
            ),
            buildQuestionAnswer(
              '5. Can I modify my order after placing it?',
              'Orders can only be modified before they are processed for shipping. Please contact our customer support immediately if you need to make changes to an order.',
            ),
            buildQuestionAnswer(
              '6. How can I track my order?',
              'Once your order is shipped, you can track it via the "Orders" section in your account. You\'ll find a tracking number and a link to track your package.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '7. What payment methods are accepted?',
              'We accept various payment methods including credit/debit cards, PayPal, and other local payment options. You can choose your preferred payment method during checkout.',
            ),
            buildQuestionAnswer(
              '8. Is my payment information secure?',
              'Yes, we use industry-standard encryption to protect your payment information. Your data is securely handled in compliance with international security standards.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '9. What are the shipping options?',
              'We offer standard and express shipping options. The availability and cost of these options may vary depending on your location and the size of your order.',
            ),
            buildQuestionAnswer(
              '10. How long will delivery take?',
              'Delivery times vary depending on your location and the shipping option chosen. Estimated delivery times will be provided at checkout.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '11. How can I return a product?',
              'To return a product, go to the "Orders" section in your account, select the order, and follow the prompts to initiate a return. Make sure the product is in its original condition and packaging.',
            ),
            buildQuestionAnswer(
              '12. When will I receive my refund?',
              'Refunds are typically processed within 7-10 business days after we receive the returned product. The amount will be credited to your original payment method.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '13. How do I update my personal information?',
              'You can update your personal information by navigating to the "Account Settings" section in the app. From there, you can edit your profile details, address, and payment information.',
            ),
            buildQuestionAnswer(
              '14. How can I delete my account?',
              'If you wish to delete your account, please contact our customer support. They will assist you in permanently removing your account and all associated data.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            buildQuestionAnswer(
              '15. How can I contact customer support?',
              'You can reach our customer support team through the "Help" or "Contact Us" section in the app. We offer support via email, phone, or live chat.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'These FAQs are designed to address the most common questions users might have when using an e-commerce application. You can customize them based on the specific features and policies of your app.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionAnswer(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
