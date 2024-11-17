import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:ecomerance_app/Screens/product_detail_screen.dart';
import 'package:ecomerance_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrendingProductContainer extends StatelessWidget {
  final String image;
  final String name;
  final String description;
  final String price;
  final String originalPrice;
  final String docId;
  final bool isFavorite;
  final bool isMargin;
  final Function(String docId) onFavoriteToggle;

  const TrendingProductContainer({
    Key? key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.docId,
    required this.isFavorite,
    this.isMargin=true,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   var displayHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        print(' image: $image name: $name description: $description price: $price originalPrice: $originalPrice,');
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
          Container( height: containerSize,
            margin:  EdgeInsets.only(right: isMargin?5:0),
            width: 165,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
              boxShadow:isMargin? boxShadowCustom:null,
              border: Border.all(color: Colors.grey.shade300,width: 2), 
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: name,
                        textColor: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: displayHeight*0.020,
                      ),
                      AppText(
                        text: description,
                        textColor: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        fontSize: displayHeight*0.015,
                      ),
                      Row(
                        children: [
                          AppText(
                            text: price,
                            textColor: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: displayHeight*0.017,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            decoration: TextDecoration.lineThrough,
                            text: originalPrice,
                            textColor: Colors.grey,
                            fontSize: displayHeight*0.015,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              // Handle rating toggle
                            },
                            child: SizedBox(
                              height: 30,
                              child: Row(
                                children: [
                                  Image.asset(
                                    isFavorite
                                        ? 'assets/icons/filled_star.png'
                                        : 'assets/icons/star.png',
                                    width: 15,
                                    height: 15,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 5),
                                   AppText(
                                    text: '4.5',
                                    textColor: Colors.black,
                                    fontSize: displayHeight*0.015,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 15,
            child: GestureDetector(
              onTap: () => onFavoriteToggle(docId),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
