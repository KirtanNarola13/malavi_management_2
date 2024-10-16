import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/utils/const.dart';
import '../../modules/screens/nav-bar-screen/nav_bar_screen.dart';

class PurchaseBillEditProductList extends StatefulWidget {
  const PurchaseBillEditProductList({super.key});

  @override
  State<PurchaseBillEditProductList> createState() =>
      _PurchaseBillEditProductListState();
}

class _PurchaseBillEditProductListState
    extends State<PurchaseBillEditProductList> {
  Map bill = {};
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
        if (arguments != null) {
          bill = arguments;
          bill['billItems'] = bill['billItems'] ?? [];
          if (updatedProduct.isNotEmpty) {
            for (var product in bill['billItems']) {
              if (updatedProduct['productName'] == product['productName']) {
                bill['billItems'].remove(product);
                bill['billItems'].add(updatedProduct);
                break;
              }
            }
            updateGrandTotal();
            updateBill();
          }
        } else {
          if (kDebugMode) {
            print("No arguments found for this route.");
          }
        }
      });
    });
  }

  void updateGrandTotal() {
    grandTotal = 0.0;
    for (var item in bill['billItems']) {
      if (item['totalAmount'] != null) {
        grandTotal +=
            double.tryParse(item['totalAmount']?.toString() ?? '0.0') ?? 0.0;
      }
    }
    bill['grandTotal'] = grandTotal.toString();
  }

  Future<void> updateBill() async {
    try {
      final billId = bill['billDocId'];
      if (billId == null) {
        if (kDebugMode) {
          print("billId is null, cannot update document.");
        }
        return;
      }

      // Unfocus any focused text fields
      FocusScope.of(context).unfocus();

      DocumentReference billRef =
          FirebaseFirestore.instance.collection('pendingBills').doc(billId);

      DocumentSnapshot docSnapshot = await billRef.get();
      if (docSnapshot.exists) {
        log("$billRef bill item : ${bill['billItems']} grandTotal : ${bill['grandTotal']}");
        await billRef.update({
          'billItems': bill['billItems'],
          'grandTotal': bill['grandTotal'],
        });
        ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
          const SnackBar(content: Text("Bill updated successfully.")),
        );
        Navigator.pushAndRemoveUntil(
          (!context.mounted) as BuildContext,
          MaterialPageRoute(
            builder: (context) => const NavBarScreen(
              initialIndex: 0,
            ),
          ),
          (route) => false,
        );
      } else {
        if (kDebugMode) {
          print("Document with ID $billId does not exist.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating document: $e");
      }
    }
  }

  void removeProduct(int index) {
    setState(() {
      bill['billItems'].removeAt(index);
      updateGrandTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
        actions: [
          IconButton(
            onPressed: () {
              updateGrandTotal();
              updateBill();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: bill['billItems'] == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bill['billItems'].length,
              itemBuilder: (context, index) {
                Map billItem = bill['billItems'][index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.yellow.shade200.withOpacity(0.5),
                    child: ListTile(
                      title: Text(billItem['productName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () async {
                              final updatedProduct = await Navigator.of(context)
                                  .pushNamed(
                                      'productEditScreenPurchaseBillHistory',
                                      arguments: {
                                    ...billItem,
                                    'billId': bill['billDocId'],
                                    'grandTotal': bill['grandTotal'],
                                  });

                              if (updatedProduct != null &&
                                  updatedProduct is Map) {
                                setState(() {
                                  for (var product in bill['billItems']) {
                                    if (updatedProduct['productName'] ==
                                        product['productName']) {
                                      bill['billItems'].remove(product);
                                      bill['billItems'].add(updatedProduct);
                                      break;
                                    }
                                  }
                                  updateGrandTotal();
                                  updateBill();
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Confirm the removal
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Removal'),
                                  content: const Text(
                                      'Are you sure you want to remove this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        removeProduct(index);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
