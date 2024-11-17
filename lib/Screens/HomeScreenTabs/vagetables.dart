import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/widgets/custom_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../AppColors/appcolors.dart';


class vegetableItem extends StatefulWidget {
  const vegetableItem({super.key});

  @override
  State<vegetableItem> createState() => _vegetableItemState();
}

class _vegetableItemState extends State<vegetableItem> {
  late String userId;
  List<String> favoriteDocIds = [];
  bool startsValue = false;

  @override
  void initState() {
    super.initState();
    getUserId();
    loadFavorites();
     print('####${FirebaseFirestore.instance
            .collection('addproducts')
            .where('productCategory', isEqualTo: 'Vegetables').snapshots()}');
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
       print('favoriteDocIds:${favoriteDocIds.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('addproducts')
            .where('productCategory', isEqualTo: 'Vegetables')
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
          print('products$products');
          return GridView.builder(
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
             childAspectRatio: 0.7,
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return   TrendingProductContainer(isMargin:false,
      image: product['productImage'],
      name: product['productName'],
      description: product['productDescription'],
      price: product['productPrice'],
      originalPrice: product['originalPrice'],
      docId: product['docId'],
      isFavorite: favoriteDocIds.contains(product['docId']),
      onFavoriteToggle: (docId) {
        setState(() {
          _toggleFavorite(favoriteDocIds.contains(docId), docId);
        });
      },
    );
            },
          );
        },
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
