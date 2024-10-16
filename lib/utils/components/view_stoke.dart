import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStock extends StatefulWidget {
  const ViewStock({super.key});

  @override
  State<ViewStock> createState() => _ViewStockState();
}

class _ViewStockState extends State<ViewStock> {
  List<DocumentSnapshot> _allResults = [];
  List<DocumentSnapshot> _resultList = [];
  final TextEditingController searchController = TextEditingController();
  String _sortOption = 'Low to High Stock'; // Default sort option
  String? selectedCompany;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    fetchProductStock();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchResultList();
  }

  Future<void> fetchProductStock() async {
    var data =
        await FirebaseFirestore.instance.collection('productStock').get();
    setState(() {
      _allResults = data.docs;
      _resultList = List.from(_allResults);
      _sortResultList(); // Sort results based on the selected option
    });
  }

  void searchResultList() {
    var query = searchController.text.toLowerCase();
    var showResults = _allResults;

    if (query.isNotEmpty) {
      showResults = _allResults.where((doc) {
        var name = doc['productName'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    if (selectedCompany != null && selectedCompany!.isNotEmpty) {
      showResults = showResults.where((doc) {
        var company = doc['companyName']?.toString().toLowerCase() ?? '';
        return company == selectedCompany!.toLowerCase();
      }).toList();
    }

    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      showResults = showResults.where((doc) {
        var category = doc['categoryName']?.toString().toLowerCase() ?? '';
        return category == selectedCategory!.toLowerCase();
      }).toList();
    }

    setState(() {
      _resultList = showResults;
      _sortResultList(); // Apply sorting after filtering
    });
  }

  Future<int> _calculateTotalStock(String productId) async {
    var historySnapshot = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productId)
        .collection('purchaseHistory')
        .get();

    int totalQuantity = 0;
    for (var doc in historySnapshot.docs) {
      var quantity = doc['quantity'] as int? ?? 0;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  Future<void> _sortResultList() async {
    // Calculate quantities for each product
    var quantities = <String, int>{};
    for (var doc in _resultList) {
      var productId = doc.id;
      quantities[productId] = await _calculateTotalStock(productId);
    }

    // Sort the resultList based on the quantities
    _resultList.sort((a, b) {
      int aQuantity = quantities[a.id] ?? 0;
      int bQuantity = quantities[b.id] ?? 0;

      if (_sortOption == 'Low to High Stock') {
        return aQuantity.compareTo(bQuantity);
      } else if (_sortOption == 'High to Low Stock') {
        return bQuantity.compareTo(aQuantity);
      } else {
        return 0; // No sorting
      }
    });

    setState(() {}); // Notify Flutter to update the UI
  }

  Future<void> _showLoadingDialog() async {
    // Show the dialog and return its future
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sorting...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSortOption(String value) async {
    // Show the loading dialog
    final dialogFuture = _showLoadingDialog();

    // Perform sorting operation
    setState(() {
      _sortOption = value;
    });
    await _sortResultList();

    // Close the dialog after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close the dialog
      }
    });

    // Await the dialog to be dismissed
    await dialogFuture;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              // Handle the sort option
              await _handleSortOption(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Sort by',
                child: Text('Sort by'),
              ),
              const PopupMenuItem(
                value: 'Low to High Stock',
                child: Text('Low to High Stock'),
              ),
              const PopupMenuItem(
                value: 'High to Low Stock',
                child: Text('High to Low Stock'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  height: height / 14,
                  width: width / 1.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.grey.shade700,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_outlined,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: width / 35),
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search product',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Company',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedCompany,
                      onChanged: (value) {
                        setState(() {
                          selectedCompany = value;
                          searchResultList();
                        });
                      },
                      items: _allResults
                          .map((doc) => doc['companyName'])
                          .toSet()
                          .toList()
                          .map<DropdownMenuItem<String>>((company) {
                        return DropdownMenuItem<String>(
                          value: company,
                          child: Text(company),
                        );
                      }).toList(),
                      hint: const Text('Select Company'),
                    ),
                  ),
                  SizedBox(width: width / 35),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          searchResultList();
                        });
                      },
                      items: _allResults
                          .map((doc) => doc['categoryName'])
                          .toSet()
                          .toList()
                          .map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      hint: const Text('Select Category'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height / 1.25,
              child: ListView.builder(
                itemCount: _resultList.length,
                itemBuilder: (context, index) {
                  var productDoc = _resultList[index];
                  var productName = productDoc['productName'];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.yellow.shade200.withOpacity(0.5),
                    child: Theme(
                      data: ThemeData()
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(productName),
                        subtitle: FutureBuilder<int>(
                          future: _calculateTotalStock(productDoc.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            } else if (snapshot.hasError) {
                              return const Text('Error');
                            } else if (!snapshot.hasData) {
                              return const Text('No Data');
                            }
                            int totalQuantity = snapshot.data!;
                            return Text('Total Quantity: $totalQuantity');
                          },
                        ),
                        children: [
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('productStock')
                                .doc(productDoc.id)
                                .collection('purchaseHistory')
                                .get(),
                            builder: (context, historySnapshot) {
                              if (historySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (historySnapshot.hasError) {
                                return const Text('Error');
                              } else if (!historySnapshot.hasData) {
                                return const Text('No Data');
                              }

                              var historyDocs = historySnapshot.data!.docs;

                              return Column(
                                children: historyDocs.map((doc) {
                                  var historyData =
                                      doc.data() as Map<String, dynamic>;
                                  var partyName = historyData['partyName'];
                                  var mrp = historyData['mrp'];
                                  var purchaseRate =
                                      historyData['purchaseRate'];
                                  var quantity =
                                      historyData['quantity'] as int? ?? 0;
                                  var totalAmount = historyData['totalAmount'];
                                  var date = historyData['date'] as Timestamp;
                                  var formattedDate =
                                      date.toDate().toLocal().toString();

                                  return ListTile(
                                    title: Text('Party: $partyName'),
                                    subtitle: Text(
                                      'Quantity: $quantity\nMRP: $mrp\nPurchase Rate: $purchaseRate\nTotal Amount: $totalAmount\nDate: $formattedDate',
                                    ),
                                  );
                                }).toList(),
                              );
                            },
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
      ),
    );
  }
}
