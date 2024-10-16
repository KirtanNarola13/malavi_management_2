import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final TextEditingController _companyController = TextEditingController();

  void _addCompany() async {
    String companyName = _companyController.text.trim();

    if (companyName.isNotEmpty) {
      await FirebaseFirestore.instance.collection('company').add(
        {
          'name': companyName,
          'created_at': Timestamp.now(),
        },
      );

      Navigator.of((!context.mounted) as BuildContext).pop(); // Close the dialog
      ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
        SnackBar(
          content: Text(
            'Company "$companyName" added.',
          ),
        ),
      );
      _companyController.clear(); // Clear the text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Company name cannot be empty.',
          ),
        ),
      );
    }
  }

  void _showAddCompanyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Company'),
          content: TextField(
            controller: _companyController,
            decoration: const InputDecoration(
              hintText: 'Company Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              onPressed: _addCompany,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editCompany(DocumentSnapshot company) {
    _companyController.text = company['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Company'),
          content: TextField(
            controller: _companyController,
            decoration: const InputDecoration(
              hintText: 'Company Name',
            ),
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
                String newCompanyName = _companyController.text.trim();
                if (newCompanyName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('company')
                      .doc(company.id)
                      .update({'name': newCompanyName});

                  Navigator.of((!context.mounted) as BuildContext).pop(); // Close the dialog
                  ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Company "${company['name']}" updated to "$newCompanyName".',
                      ),
                    ),
                  );
                  _companyController.clear(); // Clear the text field
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Company name cannot be empty.'),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCompany(DocumentSnapshot company) async {
    await FirebaseFirestore.instance
        .collection('company')
        .doc(company.id)
        .delete();

    ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
      SnackBar(
        content: Text('Company "${company['name']}" deleted.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Companies'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('company').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No companies found'));
          }

          final companies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(company['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCompany(company),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCompany(company),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCompanyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: AddCompany(),
    ),
  );
}
