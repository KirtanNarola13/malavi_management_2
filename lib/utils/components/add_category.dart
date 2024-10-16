import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final TextEditingController _categoryController = TextEditingController();

  void _addCategory() async {
    String categoryName = _categoryController.text.trim();

    if (categoryName.isNotEmpty) {
      await FirebaseFirestore.instance.collection('category').add({
        'name': categoryName,
        'created_at': Timestamp.now(),
      });

      Navigator.of((!context.mounted) as BuildContext).pop(); // Close the dialog
      ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
        SnackBar(content: Text('Category "$categoryName" added.')),
      );
      _categoryController.clear(); // Clear the text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty.')),
      );
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              onPressed: _addCategory,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(DocumentSnapshot category) {
    _categoryController.text = category['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              onPressed: () async {
                String newCategoryName = _categoryController.text.trim();
                if (newCategoryName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('category')
                      .doc(category.id)
                      .update({'name': newCategoryName});

                  Navigator.of((!context.mounted) as BuildContext).pop(); // Close the dialog
                  ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Category "${category['name']}" updated to "$newCategoryName".',
                      ),
                    ),
                  );
                  _categoryController.clear(); // Clear the text field
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Category name cannot be empty.',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(DocumentSnapshot category) async {
    await FirebaseFirestore.instance
        .collection('category')
        .doc(category.id)
        .delete();

    ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
      SnackBar(
        content: Text(
          'Category "${category['name']}" deleted.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No categories found',
              ),
            );
          }

          final categories = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height / 1,
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: ListTile(
                          title: Text(category['name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editCategory(category),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteCategory(category),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: AddCategory(),
    ),
  );
}
