import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart' as cs;
import 'package:ecomerance_app/Screens/HomeScreenTabs/fruits.dart';
import 'package:ecomerance_app/Screens/popular_categories_see_all.dart';
import 'package:ecomerance_app/Screens/product_detail_screen.dart';
import 'package:ecomerance_app/push_notifications.dart';
import 'package:ecomerance_app/utils/const.dart';
import 'package:ecomerance_app/widgets/custom_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import '../AppColors/appcolors.dart';
import '../Auth/firestore.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import '../CustomWidgets/searchbar.dart';
import '../controllers/home_screen_controller.dart';
import '../routes/route_name.dart';
import 'HomeScreenTabs/AllItem.dart';
// import 'HomeScreenTabs/fruits.dart';
import 'HomeScreenTabs/vagetables.dart';
import 'HomeScreenTabs/grains_and_pulses.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  Map<String, dynamic>? userData;
  String username = '';
  List<Map<String, dynamic>> _allPopularCategories = [];
  List<Map<String, dynamic>> _allTrendingProducts = [];
  List<Map<String, dynamic>> _allDealsOfTheDay = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final translator = GoogleTranslator();
  List<Map<String, dynamic>> _filteredPopularCategories = [];
  List<Map<String, dynamic>> _filteredTrendingProducts = [];
  List<Map<String, dynamic>> _filteredDealsoftheDay = [];

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollsController = ScrollController();
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final cs.CarouselSliderController _controller = cs.CarouselSliderController();
  final HomeScreenController controller = Get.put(HomeScreenController());
  bool _isListening = false;
  bool startValue = false;
  bool startsValue = false;
  List<int> favoriteIndices = [];
  List<int> favoritesIndices = [];
  late String userId;
  List<String> favoriteDocIds = [];

  List<String> productsType = ["All", "Fruits", "Vegetable", "Grains & Pulses"];

  List<Map<String, dynamic>> _products = [];
  Future<void> fetchUserData() async {
    try {
      userData = await _firestoreService.getUserData();
      if (userData != null) {
        username = userData?['userName'] ?? 'Guest';
      }
      if(mounted)
      {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data:$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _filterData() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _products = [];
      });
      return;
    }

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('addproducts')
        .where('productName', isGreaterThanOrEqualTo: _searchQuery)
        .where('productName', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
        .get();

    final List<Map<String, dynamic>> products = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      _products = products;
    });
  }

  List<Map<String, dynamic>> _filterByQuery(
      List<Map<String, dynamic>> items, String fieldName) {
    List<String> queryWords =
        _searchQuery.trim().toLowerCase().split(RegExp(r'\s+'));

    return items.where((item) {
      String fieldValue = (item[fieldName] as String).toLowerCase();

      print('Field Value: $fieldValue');
      print('Query Words: $queryWords');

      bool match = queryWords.any((queryWord) {
        return fieldValue.contains(queryWord);
      });

      print('Match: $match');
      return match;
    }).toList();
  }

  void _listen() async {
    if (!_isListening) {
      _isListening = false;
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _animationController.repeat(reverse: true);
        });
        _speech.listen(
          onResult: (val) async {
            String urduText = val.recognizedWords;
            var translation =
                await translator.translate(urduText, from: 'ur', to: 'en');
            setState(() {
              _searchController.text = translation.text;
              _searchQuery = translation.text.trim().toLowerCase();
              _isListening = false;
              _animationController.stop();
            });
          },
          localeId: 'ur_PK',
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _animationController.stop();
      });
      _speech.stop();
    }
  }

  late AnimationController _animationController;
  Future<void> fetchData() async {
    QuerySnapshot popularCategoriesSnapshot = await FirebaseFirestore.instance
        .collection('addproducts')
        .where('productType', isEqualTo: 'Popular')
        .get();
    QuerySnapshot trendingProductsSnapshot = await FirebaseFirestore.instance
        .collection('addproducts')
        .where('productType', isEqualTo: 'Trending')
        .get();
    QuerySnapshot dealsOfTheDaySnapshot =
        await FirebaseFirestore.instance.collection('deals_of_the_day').get();

    setState(() {
      _allPopularCategories = popularCategoriesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _allTrendingProducts = trendingProductsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _allDealsOfTheDay = dealsOfTheDaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      _filteredPopularCategories = List.from(_allPopularCategories);
      _filteredTrendingProducts = List.from(_allTrendingProducts);
      _filteredDealsoftheDay = List.from(_allDealsOfTheDay);
    });
  }

  @override
  void initState() {
    super.initState();
    getUserId();
    loadFavorites();
    fetchUserData();
    fetchData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   var displayHeight = MediaQuery.of(context).size.height;
    var displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: (userData?["imageUrl"] != null &&
                          userData?["imageUrl"] != '')
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                          imageUrl: userData?["imageUrl"],
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Hello',
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    fontSize: 20,
                  ),
                  AppText(
                    text: username.toUpperCase(),
                    fontSize: 16,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.notificationScreen);
                },
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? SafeArea(
              child: DefaultTabController(
                length: 4,
                child: SingleChildScrollView(
                  // physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const SizedBox(
                         height:  SizeboxHeight,
                        ),
                        ProductSearchBar(
                          searchController: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                              _filterData();
                            });
                          },
                          onMicTap: _listen,
                        ),
                        const SizedBox(height: 20),
                        CarouselSlider(
                          carouselController: _controller,
                          options: CarouselOptions(
                            height: 150,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: [
                            'assets/images/banner1.png',
                            'assets/images/banner2.png',
                            'assets/images/banner3.png',
                          ].map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      item,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: SizeboxHeight),
                        SectionHeader(
                          title: 'Popular Categories',
                          onTapSeeAll: () {
                            Get.to(() => const PopularCategoriesSeeAll());
                          },
                        ),
                        const SizedBox(height: SizeboxHeight),
                        _buildPopularCategories(),
                        const SizedBox(height: SizeboxHeight),
                        SectionHeader(
                          title: 'Deals of the Day',
                          onTapSeeAll: () {
                            Get.toNamed(RouteName.productScreen);
                          },
                        ),
                        const SizedBox(height: SizeboxHeight),
                        _buildDealsoftheDay(displayWidth*0.042,displayWidth*0.035),
                        const SizedBox(height: SizeboxHeight),
                        SectionHeader(
                          title: 'Trending Products',
                          onTapSeeAll: () {
                            Get.to(() => const PopularCategoriesSeeAll());
                          },
                        ),
                        const SizedBox(height: SizeboxHeight),
                        _buildTrendingProducts(),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          boxShadow: boxShadowCustom
                        ),
                          child: Column(children: [
                              Obx(() => SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: TabBar(
                                  tabAlignment: TabAlignment.start,
                                  isScrollable: true,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.transparent,
                                  ),
                                  onTap: (index) {
                                    controller.changeTabIndex(index);
                                  },
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  tabs: productsType.map<Widget>((type) {
                                    return Tab(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            controller.changeTabIndex(
                                                productsType.indexOf(type));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: controller.selectedIndex ==
                                                      productsType.indexOf(type)
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: controller.selectedIndex ==
                                                        productsType.indexOf(type)
                                                    ? Colors.transparent
                                                    : AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                type,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .merge(
                                                      TextStyle(
                                                        color: controller
                                                                    .selectedIndex ==
                                                                productsType
                                                                    .indexOf(type)
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: displayHeight*0.015,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: displayHeight*0.45,
                              child: Obx(() {
                                switch (controller.selectedIndex) {
                                  case 0:
                                    return const AllItem();
                                  case 1:
                                    return const FruitsFilter();
                                  case 2:
                                    return const vegetableItem();
                                  case 3:
                                    return const GrainsPulsesItem();
                                  default:
                                    return const SizedBox.shrink();
                                }
                              }),
                            ),
                          ),
                                               
                          ],),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ProductSearchBar(
                    searchController: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                        _filterData();
                      });
                    },
                    onMicTap: _listen,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _products.isEmpty
                        ? const Center(child: Text('No products found.'))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Number of columns
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                              childAspectRatio:
                                  0.75, // Adjust to fit your design
                            ),
                            padding: const EdgeInsets.all(10),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return _buildProductsContainer(
                                product['productImage'] ?? '',
                                product['productName'] ?? '',
                                product['productDescription'] ?? '',
                                product['productPrice'] ?? '',
                                product['originalPrice'] ?? '',
                                index,
                              );
                            },
                          ),
                  ),
                  if (_isListening)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // AnimatedOpacity to fade in the "Searching..." text
                          AnimatedOpacity(
                            opacity: _isListening ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 +
                                      _animationController.value *
                                          0.1, // Scaling effect
                                  child: child,
                                );
                              },
                              child: const Text(
                                'Searching...',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 200),
                        ],
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
        onPressed: () {
          print("Navigating to ChatScreen");
          Get.to(() => ChatScreen());
        },
        label: const Text(
          'Chat!',
          style: TextStyle(color: Colors.white),
        ),
        tooltip: 'Connect To Assistant',
      ),
    );
  }

  Widget _buildPopularCategories({bool filtered = false}) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            height: containerSize,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('addproducts')
                  .where('productType', isEqualTo: 'Popular')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ));
                }
          
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
          
                // Extract product list once to avoid rebuilding excessively
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
          
                return ListView.builder(
  key: UniqueKey(),
  controller: _scrollsController,
  scrollDirection: Axis.horizontal,
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return TrendingProductContainer(
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
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              _scrollsController.animateTo(
                _scrollsController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingProducts() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            height: containerSize,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('addproducts')
                  .where('productType', isEqualTo: 'Trending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // Extract product list once to avoid rebuilding excessively
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

                return ListView.builder(
                  key: UniqueKey(), // Ensure the ListView has a unique key
                  controller: _scrollsController,
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                 return   TrendingProductContainer(
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
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              _scrollsController.animateTo(
                _scrollsController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDealsoftheDay(fontSize,smallFontSize,{bool filtered = false}) {
    return SizedBox(
      height: containerSize,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('createPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ground.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Data Found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          if (filtered && _searchQuery.isNotEmpty) {
            documents = documents.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var postName = data['postName'] ?? '';
              return postName.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              var postName = data['postName'] ?? 'Unknown';
              var postDescription = data['postDescription'] ?? 'No description';
              var postImage = data['postImage'] ?? '';

              return Card(
                elevation: 1,
                child: Container(
                  width: 315,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (postImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                          child: Image.network(
                            postImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Placeholder(
                          fallbackHeight: 150,
                          color: Colors.grey,
                        ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: postName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSize,
                                ),
                                AppText(
                                  text: postDescription.length > 20
                                      ? postDescription.substring(0, 20) + '...'
                                      : postDescription,
                                  fontSize: smallFontSize,
                                ),
                              ],
                            ),
                            // CustomButton(
                            //   onTap: () {
                            //     // Handle the view more button tap
                            //   },
                            //   label: 'view more',
                            //   width: 60,
                            //   height: 25,
                            //   fontSize: 10,
                            //   fontWeight: FontWeight.w600,
                            //   bgColor: AppColors.primary,
                            //   labelColor: Colors.white,
                            //   borderRadius: 5,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Future<void> _toggleFavorite(bool isFavorite, String docId) async {
    if (isFavorite) {
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

  Widget _buildProductsContainer(
    String image,
    String name,
    String description,
    String price,
    String originalPrice,
    int index,
  ) {
    bool isFavorite = favoritesIndices.contains(index);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(
              image: image,
              name: name,
              description: description,
              price: price,
              originalPrice: originalPrice,
              isNetworkImage: true, // Assuming network image; change as needed
            ));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            width: 161,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 95,
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
                  overflow: TextOverflow.ellipsis, // Handle overflow
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isFavorite) {
                    favoritesIndices.remove(index);
                  } else {
                    favoritesIndices.add(index);
                  }
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
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onTapSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AppText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
