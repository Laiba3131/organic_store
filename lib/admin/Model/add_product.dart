class Product {
  String productName;
  String productDescription;
  String productPrice;
  String? productImage;
  String? originalPrice;
  String productCategory;
  String productType; // New field for product type

  Product({
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productImage,
    this.originalPrice,
    required this.productCategory,
    required this.productType, // Initialize the new field
  });

  @override
  String toString() {
    return 'Product{name: $productName, description: $productDescription, price: $productPrice, image: $productImage, originalPrice: $originalPrice, category: $productCategory, type: $productType}';
  }
}
