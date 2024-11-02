import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppColors/appcolors.dart';
import '../../CustomWidgets/appText.dart';
import '../product_detail_screen.dart';

class BagItem extends StatefulWidget {
  const BagItem({super.key});

  @override
  State<BagItem> createState() => _BagItemState();
}

class _BagItemState extends State<BagItem> {
  List<String> favoriteDocIds = [];
  late String userId;
  bool startsValue = false;

  @override
  void initState() {
    super.initState();
    getUserId();
    loadFavorites();
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

  Future<void> loadFavorites() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(userId)
        .collection('userFavorites')
        .get();

    setState(() {
      favoriteDocIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('addproducts')
            .where('productCategory', isEqualTo: 'Bag')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary,));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final products = snapshot.data!.docs.map((doc) {
            return {
              'productName': doc['productName'],
              'productDescription': doc['productDescription'],
              'productPrice': doc['productPrice'],
              'productImage': doc['productImage'],
              'originalPrice': doc['originalPrice'],
              'docId': doc.id,
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.6,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductContainer(
                  product['productImage'],
                  product['productName'],
                  product['productDescription'],
                  product['productPrice'],
                  product['originalPrice'],
                  product['docId'],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductContainer(
      String image,
      String name,
      String description,
      String price,
      String originalPrice,
      String docId) {
    bool isFavorite = favoriteDocIds.contains(docId);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(
          image: image,
          name: name,
          description: description,
          price: price,
          originalPrice: originalPrice,
        ));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AppText(
                  text: name,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                AppText(
                  text: description,
                  textColor: Colors.grey,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: true,
                ),
                const Spacer(),
                Row(
                  children: [
                    AppText(
                      text: price,
                      textColor: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(width: 5),
                    AppText(
                      decoration: TextDecoration.lineThrough,
                      text: originalPrice,
                      textColor: Colors.grey,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          startsValue = !startsValue;
                        });
                      },
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            startsValue
                                ? Image.asset(
                              'assets/icons/star.png',
                              width: 15,
                              height: 15,
                              color: AppColors.secondary,
                            )
                                : Image.asset(
                              'assets/icons/filled_star.png',
                              width: 15,
                              height: 15,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 5),
                            const AppText(
                              text: '4.5',
                              textColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 15,
            child :GestureDetector(
              onTap: () {
                setState(() {
                  _toggleFavorite(isFavorite, docId);
                });
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: isFavorite
                    ? const Icon(Icons.favorite, color: Colors.red)
                    : const Icon(
                  Icons.favorite_outline,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(bool isFavorite, String docId) async {
    if (isFavorite) {
      // Remove from favorites
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(docId)
          .delete();
      setState(() {
        favoriteDocIds.remove(docId);
      });
    } else {
      // Add to favorites
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('userFavorites')
          .doc(docId)
          .set({
        'productId': docId,
        'addedAt': Timestamp.now(),
      });
      setState(() {
        favoriteDocIds.add(docId);
      });
    }
  }
}
