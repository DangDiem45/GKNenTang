// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/firebase_database/database_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductList extends StatelessWidget {
  final String searchQuery;
  final DatabaseMethod _databaseMethod = DatabaseMethod();

  ProductList({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

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
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseMethod.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        var filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final productName = data['name'].toString().toLowerCase();
          return searchQuery.isEmpty || productName.contains(searchQuery.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            return ProductCard(
              docId: doc.id,
              data: data,
              onEdit: () => _showEditDialog(context, doc.id, data),
              onDelete: () => _deleteProduct(context, doc.id),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController nameController = TextEditingController(text: data['name']);
    String? selectedCategory = data['category'];
    final TextEditingController priceController = TextEditingController(text: data['price'].toString());
    File? _imageFile;
    String currentImageUrl = data['imageUrl'] ?? '';
    final ImagePicker _picker = ImagePicker();

    final List<String> categories = ['Food', 'Drink'];

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
        print('Error uploading image to Supabase: ${e.toString()}');
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Product Category'),
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
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.grey[200],
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.contain)
                        : (currentImageUrl.isNotEmpty
                            ? Image.network(
                                currentImageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(child: Text('Cannot load image')),
                              )
                            : const Center(child: Text('Tap to select image'))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedCategory == null || priceController.text.isEmpty) {
                  _showToast('Please fill in all the required information', isError: true);
                  return;
                }

                String imageUrl = currentImageUrl;
                if (_imageFile != null) {
                  imageUrl = await _uploadImageToSupabase(_imageFile!) ?? currentImageUrl;
                  if (imageUrl == currentImageUrl) {
                    _showToast('Image upload failed', isError: true);
                    return;
                  }
                }

                await _updateProduct(
                  dialogContext,
                  docId,
                  nameController.text,
                  selectedCategory!,
                  priceController.text,
                  imageUrl,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _updateProduct(BuildContext context, String docId, String name, String category, String price, String imageUrl) async {
    try {
      await _databaseMethod.updateProduct(
        docId: docId,
        name: name,
        category: category,
        price: double.tryParse(price) ?? 0,
        imageUrl: imageUrl,
      );
      _showToast('Product updated successfully');
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
  }

  Future<void> _deleteProduct(BuildContext context, String docId) async {
    try {
      await _databaseMethod.deleteProduct(docId);
      _showToast('Product deleted successfully');
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
  }
}

class ProductCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.docId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product Name: ${data['name']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Product Category: ${data['category']}"),
            const SizedBox(height: 8),
            Text(
              "Price: ${data['price']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(
                  data['imageUrl'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Cannot load image')),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}