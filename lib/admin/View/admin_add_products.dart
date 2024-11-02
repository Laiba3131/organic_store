import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/CustomTextformField.dart';
import '../../CustomWidgets/appText.dart';
import '../Model/add_product.dart';

class AdminAddProducts extends StatefulWidget {
  const AdminAddProducts({super.key});

  @override
  State<AdminAddProducts> createState() => _AdminAddProductsState();
}

class _AdminAddProductsState extends State<AdminAddProducts> {
  final GlobalKey<FormState> _adminAddProductFormKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isImageSelected = true;
  bool isSaving = false;

  // New variables for dropdown and radio button selection
  String? _selectedCategory;
  String? _selectedProductType;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isImageSelected = true;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.all(9),
          height: 140,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text("Camera", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.white),
                title: Text("Gallery", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProduct() async {
    setState(() {
      isSaving = true;
    });
    if (_adminAddProductFormKey.currentState!.validate() && _isImageSelected) {
      try {
        // Upload image to Firebase Storage
        String imageUrl = '';
        if (_selectedImage != null) {
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('products')
              .child(DateTime.now().toIso8601String());
          firebase_storage.UploadTask uploadTask = ref.putFile(_selectedImage!);
          await uploadTask.whenComplete(() => null);
          imageUrl = await ref.getDownloadURL();
        }

        // Create product object
        Product newProduct = Product(
          productName: _productNameController.text,
          productDescription: _productDescriptionController.text,
          productPrice: _productPriceController.text,
          productImage: imageUrl,
          originalPrice: _originalPriceController.text,
          productCategory: _selectedCategory ?? 'Uncategorized',
          productType: _selectedProductType ?? 'Popular', // Use radio button selection
        );

        // Save product details to Firestore
        await FirebaseFirestore.instance.collection('addproducts').add({
          'productName': newProduct.productName,
          'productDescription': newProduct.productDescription,
          'productPrice': newProduct.productPrice,
          'productImage': newProduct.productImage,
          'originalPrice': newProduct.originalPrice,
          'productCategory': newProduct.productCategory,
          'productType': newProduct.productType,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product uploaded successfully')),
        );
        Get.back();

        // Clear the form after successful upload
        _adminAddProductFormKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
          _isImageSelected = false;
          _productNameController.clear();
          _productDescriptionController.clear();
          _productPriceController.clear();
          _originalPriceController.clear();
          _selectedCategory = null;
          _selectedProductType = null; // Reset radio button selection
        });
        setState(() {
          isSaving = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload product: $e')),
        );
        setState(() {
          isSaving = false;
        });
      }
    } else {
      if (!_isImageSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AppText(
          text: 'Add Product Screen',
          fontSize: 20,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _adminAddProductFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: 'Product Image', fontSize: 16,),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade500, width: 2),
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                            : Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Product Name', fontSize: 16, ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _productNameController,
                      obscureText: false,
                      hintText: 'Product Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Product Description', fontSize: 16, ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: _productDescriptionController,
                      obscureText: false,
                      hintText: 'Product Description',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Product Price', fontSize: 16, ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      controller: _productPriceController,
                      obscureText: false,
                      hintText: 'Product Price',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the product price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Original Price', fontSize: 16,),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      controller: _originalPriceController,
                      obscureText: false,
                      hintText: 'Original Price',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the original price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Category Type', fontSize: 16, ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: Text('Select Category', style: TextStyle(color: Colors.white)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade500,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade800, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey.shade900,
                      items: ['Bag', 'Electronics', 'Clothes', 'Shoes', 'Sports']
                          .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    AppText(text: 'Product Type', fontSize: 16, ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: Text('Trending Product',),
                          value: 'Trending',
                          groupValue: _selectedProductType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProductType = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Popular Product',),
                          value: 'Popular',
                          groupValue: _selectedProductType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProductType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      bgColor: Colors.teal,
                      labelColor: Colors.white,
                      label: isSaving ? 'Saving...' : 'Save',
                      onTap: isSaving ? null : _uploadProduct,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
