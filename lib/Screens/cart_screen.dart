// cart_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import '../AppColors/appcolors.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userId;
  double subtotal = 0.0;
  double shippingFee = 80.0;
  double total = 0.0;
  bool isLoading = true;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    getUserData();
    _handleOrderComplete();
  }

  Future<void> getUserData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        setState(() {
          userId = user.uid;
        });
        await _calculateSubtotal(); // Ensure this completes before proceeding
      } else {
        print('User is not logged in');
      }
    } catch (error) {
      print('Error getting user data: $error');
    }
  }

  Future<void> _calculateSubtotal() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('addtocart')
          .where('userId', isEqualTo: userId)
          .get();

      double tempSubtotal = 0.0;
      List<CartItem> tempCartItems = [];

      for (var doc in querySnapshot.docs) {
        double price = double.tryParse(
            doc['productDescription'].replaceAll(RegExp(r'[^\d.]'), '')) ??
            0.0;
        int quantity = doc['quantity'];
        tempSubtotal += price * quantity;

        tempCartItems.add(CartItem(
          productName: doc['productName'],
          productImage: doc['productImage'],
          productPrice: price,
          productDescription: doc['productDescription'],
          quantity: quantity,
          docId: doc.id,
        ));
      }

      setState(() {
        subtotal = tempSubtotal;
        total = subtotal + shippingFee;
        cartItems = tempCartItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error calculating subtotal: $error");
    }
  }
  void _handleOrderComplete() {
    setState(() {
      cartItems.clear();
      subtotal = 0.0;
      total = subtotal + shippingFee;
      isLoading = true;
    });
    getUserData(); // Refresh the data
  }


  @override
  Widget build(BuildContext context) {
       var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Cart Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary,))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: cartItems.isNotEmpty ? ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var product = cartItems[index];
                  return _buildCartItem(product,displayHeight*0.013,displayHeight*0.18,displayWidth*0.33,displayHeight*0.022);
                },
              ):Image.asset('assets/images/nodata.webp',color: AppColors.primary,height: 150,width: 150,),
            ),
            const SizedBox(height: 20),
            _buildTotalSection(),
            const SizedBox(height: 30),
            CustomButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      cartItems: cartItems,
                      subtotal: subtotal,
                      shippingFee: shippingFee,
                      total: total,
                      userId: userId,
                      onOrderComplete: _handleOrderComplete
                    ),
                  ),
                );
              },
              label: 'Go to checkout',
              bgColor: AppColors.primary,
              labelColor: Colors.white,
              fontSize: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem product,displayHeightOfFontsize,displayHeight,displayWidth,fontSizeOfHeading) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height:displayHeight ,
            width: displayWidth,
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: Image.network(product.productImage,
                    fit: BoxFit.fill)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: product.productName,
                    fontSize: fontSizeOfHeading,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primary,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      onPressed: () => _removeCartItem(product.docId),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              AppText(
                overflow: TextOverflow.ellipsis,
                text: product.productDescription,
                fontSize: displayHeightOfFontsize,
                textColor: Colors.grey,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: '\$${product.productPrice.toStringAsFixed(2)}',
                    fontSize: fontSizeOfHeading,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(product, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                      ),
                      AppText(
                        text: '${product.quantity}',
                        fontSize: fontSizeOfHeading,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primary,
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(product, 1),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Order Summary',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              text: 'Sub-total',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: Colors.grey,
            ),
            AppText(
              text: '\$${subtotal.toStringAsFixed(2)}',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Vat(%)',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: Colors.grey,
            ),
            AppText(
              text: '\$ 0.00',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Shipping fee',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: Colors.grey,
            ),
            AppText(
              text: '\$ ${shippingFee.toStringAsFixed(2)}',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
          child: Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              text: 'Total',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: Colors.grey,
            ),
            AppText(
              text: '\$ ${total.toStringAsFixed(2)}',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateQuantity(CartItem product, int change) async {
    try {
      int newQuantity = product.quantity + change;
      if (newQuantity <= 0) {
        await _removeCartItem(product.docId);
      } else {
        await FirebaseFirestore.instance
            .collection('addtocart')
            .doc(product.docId)
            .update({'quantity': newQuantity});
        setState(() {
          product.quantity = newQuantity;
          subtotal += product.productPrice * change;
          total = subtotal + shippingFee;
        });
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  Future<void> _removeCartItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('addtocart')
          .doc(docId)
          .delete();
      setState(() {
        cartItems.removeWhere((item) => item.docId == docId);
        subtotal = subtotal - cartItems
            .firstWhere((item) => item.docId == docId)
            .productPrice;
        total = subtotal + shippingFee;
      });
    } catch (error) {
      print('Error removing cart item: $error');
    }
  }
}

class CartItem {
  final String productName;
  final String productImage;
  final double productPrice;
  final String productDescription;
  int quantity;
  final String docId;

  CartItem({
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
    required this.quantity,
    required this.docId,
  });
}
