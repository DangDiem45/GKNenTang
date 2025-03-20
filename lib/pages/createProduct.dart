// ignore_for_file: file_names, unused_field, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giuaki/firebase_database/database_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedCategory;
  File? _imageFile;
  final DatabaseMethod _databaseMethod = DatabaseMethod();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> categories = ['Food', 'Drink'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final fileBytes = await imageFile.readAsBytes();

      print('Uploading image: $fileName.jpg');
      await supabase.storage.from('products').uploadBinary(
            'images/$fileName.jpg',
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final url = supabase.storage.from('products').getPublicUrl('images/$fileName.jpg');
      print('Image uploaded successfully: $url');
      return url;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty ||
        selectedCategory == null ||
        priceController.text.isEmpty) {
      _showToast('Please fill in all the required information', isError: true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImageToSupabase(_imageFile!);
        if (imageUrl == null) {
          _showToast('Image upload failed', isError: true);
          setState(() => _isLoading = false);
          return;
        }
      } else {
        imageUrl = '';
      }

      String productId = await _databaseMethod.addProduct(
        name: nameController.text,
        category: selectedCategory!,
        price: double.tryParse(priceController.text) ?? 0,
        imageUrl: imageUrl,
      );

      nameController.clear();
      priceController.clear();
      setState(() {
        _imageFile = null;
        selectedCategory = null;
        _isLoading = false;
      });

      _showToast('The product has been added with ID: $productId');
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast('Error: $e', isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Product Name
              const Text(
                'Product Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              // Product Category
              const Text(
                'Product Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Price
              const Text(
                'Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Product Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 150, 
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text('Select image'))
                      : Image.file(_imageFile!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}