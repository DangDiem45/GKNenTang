// ignore_for_file: file_names, unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:giuaki/authentication_screen/signIn.dart';
import 'package:giuaki/pages/createProduct.dart';
import 'package:giuaki/pages/productList.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 75),
          child: Text(
            "Home",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.blue[700],
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              // Replace Get.off with Navigator.pushReplacement
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => SignIn())
              );
            },
            child: Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      
      body: Column(
        children: [
          SizedBox(height: 10,),
          Center(
            child: Text(
              "Welcome! Let’s get started",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black26, width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: ProductList(searchQuery: _searchQuery),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateProduct(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue[700],
      ),
    );
  }


  
  void _navigateToCreateProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProduct()),
    );
    
    // Optional: Refresh data if needed based on result
    if (result == true) {
      setState(() {
        // Refresh state if needed
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}