import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../nav-bar-screen/nav_bar_screen.dart';

class EditProduct extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late TextEditingController _titleController;
  String? selectedCompany;
  String? selectedCategory;
  String? imgUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String previousTitle;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product['title']);
    selectedCompany = widget.product['company'];
    selectedCategory = widget.product['category'];
    previousTitle = widget.product['title']; // Store the previous title
    imgUrl = widget.product['image_url'];
  }

  Future<void> _updateProduct(String? company, String? category) async {
    if (company == null || category == null) {
      if (kDebugMode) {
        print("Company or category is null");
      }
      return;
    }

    try {
      // Find the document with the previous title
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('title', isEqualTo: previousTitle)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the first matching document
        String docId = querySnapshot.docs.first.id;

        // Check if the title has changed
        if (_titleController.text != previousTitle) {
          // Delete the old document
          await _firestore.collection('products').doc(docId).delete();

          // Create a new document with the updated title and other details
          await _firestore
              .collection('products')
              .doc(_titleController.text)
              .set({
            'title': _titleController.text,
            'company': company,
            'category': category,
            'image_url': imgUrl,
            'units': 'psc',
          });

          log("Product updated with new title and document ID");
        } else {
          // Update the document if the title hasn't changed
          await _firestore.collection('products').doc(docId).update({
            'title': _titleController.text,
            'company': company,
            'category': category,
            'image_url': imgUrl,
            'units': 'psc',
          });

          log("Product updated successfully");
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const NavBarScreen(
              initialIndex: 1,
            ),
          ),
          (route) => false,
        );
      } else {
        if (kDebugMode) {
          print("No matching document found");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating product: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating product: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('category').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) =>
                      setState(() => selectedCategory = value),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc['name'],
                      child: Text(doc['name']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Select category' : null,
                );
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('company').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<String>(
                  value: selectedCompany,
                  onChanged: (value) => setState(() => selectedCompany = value),
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc['name'], // Use company name as the value
                      child:
                          Text(doc['name']), // Display company name in dropdown
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Company',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null ? 'Select company' : null,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              onPressed: () =>
                  _updateProduct(selectedCompany, selectedCategory),
              child: const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}
