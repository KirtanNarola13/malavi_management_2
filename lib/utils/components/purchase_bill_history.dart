import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malavi_management/utils/components/purchase_bill/purchase_bill_edit.dart';
import 'package:malavi_management/utils/components/purchase_bill_edit_product_list.dart';

class PurchaseBillHistory extends StatefulWidget {
  const PurchaseBillHistory({super.key});

  @override
  State<PurchaseBillHistory> createState() => _PurchaseBillHistoryState();
}

class _PurchaseBillHistoryState extends State<PurchaseBillHistory> {
  final TextEditingController searchController = TextEditingController();

  List _allResult = [];
  List _resultList = [];

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
    getAllProducts();
  }

  Future<void> getAllProducts() async {
    var data = await FirebaseFirestore.instance
        .collection('pendingBills')
        .orderBy('createdAt',
            descending: true) // Order by date, most recent first
        .get();
    setState(() {
      _allResult = data.docs;
    });
    searchResultList();
  }

  void _onSearchChanged() {
    searchResultList();
  }

  void searchResultList() {
    var showResult = [];
    if (searchController.text.isNotEmpty) {
      for (var billSnapshot in _allResult) {
        var name = billSnapshot['partyName'].toString().toLowerCase();
        if (name.contains(searchController.text.toLowerCase())) {
          showResult.add(billSnapshot);
        }
      }
    } else {
      showResult = List.from(_allResult);
    }

    setState(() {
      _resultList = showResult;
    });
  }

  Future<void> deleteBill(String billId) async {
    await FirebaseFirestore.instance
        .collection('pendingBills')
        .doc(billId)
        .delete();
    ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
      const SnackBar(content: Text('Bill deleted')),
    );
    getAllProducts(); // Refresh the list after deletion
  }

  void editBill(String billDocId, List billItems, String grandTotal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PurchaseBillEditProductList(),
        settings: RouteSettings(
          arguments: {
            'billDocId': billDocId,
            'billItems': billItems,
            'grandTotal': grandTotal,
          },
        ),
      ),
    );
  }

  void _showPaymentDialog(String billId, double grandTotal) {
    final TextEditingController receivedAmountController =
        TextEditingController();
    double kasar = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Receive Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: receivedAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Received Amount',
                    ),
                    onChanged: (value) {
                      setState(() {
                        double receivedAmount = double.tryParse(value) ?? 0.0;
                        kasar = grandTotal - receivedAmount;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller:
                        TextEditingController(text: kasar.toStringAsFixed(2)),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Kasar',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    double receivedAmount =
                        double.tryParse(receivedAmountController.text) ?? 0.0;
                    await FirebaseFirestore.instance
                        .collection('pendingBills')
                        .doc(billId)
                        .update({
                      'receivedAmount': receivedAmount,
                      'kasar': kasar,
                      'paymentStatus':
                          receivedAmount >= grandTotal ? 'Paid' : 'Pending',
                    });
                    Navigator.of((!context.mounted) as BuildContext).pop();
                    ScaffoldMessenger.of((!context.mounted) as BuildContext)
                        .showSnackBar(
                      const SnackBar(content: Text('Payment recorded')),
                    );
                    getAllProducts(); // Refresh the list to show updated payment status
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills List'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              margin: const EdgeInsets.only(bottom: 10),
              height: height / 16,
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
                  SizedBox(
                    width: width / 35,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: width / 1.5,
                    child: TextFormField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by party name',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _resultList.length,
              itemBuilder: (context, index) {
                final bill = _resultList[index];
                final Timestamp timestamp = bill['createdAt'];
                final DateTime billDate = timestamp.toDate();
                final int daysAgo = DateTime.now().difference(billDate).inDays;
                final double grandTotal =
                    double.tryParse(bill['grandTotal'].toString()) ?? 0.0;
                final String paymentStatus = bill['paymentStatus'] ?? 'Pending';

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  color: Colors.yellow.shade200.withOpacity(0.8),
                  child: Theme(
                    data:
                        ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text('Party: ${bill['partyName']}'),
                      subtitle: Text(
                          'Date : ${billDate.day} - ${billDate.month} - ${billDate.year} | bill no ${bill['billNumber']} '),
                      trailing: Text('$daysAgo days ago'),
                      children: [
                        ListTile(
                          title: const Text('Grand Total'),
                          subtitle: Text(" ₹ ${grandTotal.toStringAsFixed(2)}"),
                        ),
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(
                              '${billDate.day} - ${billDate.month} - ${billDate.year}'),
                        ),
                        ListTile(
                          title: const Text('Time'),
                          subtitle:
                              Text('${billDate.hour} : ${billDate.minute}'),
                        ),
                        ListTile(
                          title: const Text('Payment Status'),
                          subtitle: Text(paymentStatus),
                        ),
                        ...bill['billItems'].map<Widget>((item) {
                          return Column(
                            children: [
                              const Divider(
                                color: Colors.black,
                                indent: 20,
                                endIndent: 20,
                              ),
                              ListTile(
                                title: Text('Product: ${item['productName']}'),
                              ),
                              ListTile(
                                title: const Text('Quantity'),
                                subtitle: Text('${item['quantity']}'),
                              ),
                              ListTile(
                                title: const Text('Purchase Rate'),
                                subtitle: Text(
                                    "₹ ${double.parse(item['purchaseRate'].toString()).toStringAsFixed(2)}"),
                              ),
                              ListTile(
                                title: const Text('Total Amount'),
                                subtitle: Text(
                                    "₹ ${double.parse(item['totalAmount'].toString()).toStringAsFixed(2)}"),
                              ),
                            ],
                          );
                        }).toList(),
                        OverflowBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => deleteBill(bill.id),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                log("${bill.id}");
                                // editBill(bill.id, bill['billItems'],
                                //     bill['grandTotal']);

                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return PurchaseBillEdit(
                                    items: bill['billItems'],
                                    billID: bill.id,
                                    partyName: bill['partyName'],
                                  );
                                }));
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                              child: const Text('Edit'),
                            ),
                            if (paymentStatus ==
                                'Pending') // Only show if payment status is 'Pending'
                              TextButton(
                                onPressed: () =>
                                    _showPaymentDialog(bill.id, grandTotal),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                                child: const Text('Receive Payment'),
                              ),
                          ],
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
  }
}
