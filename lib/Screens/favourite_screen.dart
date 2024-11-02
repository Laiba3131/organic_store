import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/appText.dart';
import 'product_detail_screen.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Favorites',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('userFavorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No favorite products found.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final favoriteProducts = snapshot.data!.docs.map((doc) {
            return doc['productId'];
          }).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('addproducts')
                .where(FieldPath.documentId, whereIn: favoriteProducts)
                .snapshots(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No favorite products found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: productSnapshot.data!.docs.length,

                itemBuilder: (context, index) {
                  var product = productSnapshot.data!.docs[index];
                  return Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black38)
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                      leading: Container(
                        width: 80,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black38)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product['productImage'],
                            width: 80,
                            height: 150,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      title: Text(
                        product['productName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Price: ${product['productPrice']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          _removeFavorite(product.id);
                        },
                      ),
                      onTap: () {
                        Get.to(() => ProductDetailScreen(
                          image: product['productImage'],
                          name: product['productName'],
                          description: product['productDescription'],
                          price: product['productPrice'],
                          originalPrice: product['originalPrice'],
                        ));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _removeFavorite(String docId) async {
    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .doc(docId)
        .delete();
  }
}
