import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfitScreen extends StatefulWidget {
  const ProfitScreen({super.key});

  @override
  State<ProfitScreen> createState() => _ProfitScreenState();
}

class _ProfitScreenState extends State<ProfitScreen> {
  List _resultList = [];
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchResultList();
  }

  Future<void> searchResultList() async {
    var data = await FirebaseFirestore.instance
        .collection('sellBills')
        .orderBy('timeStamp', descending: true)
        .get();
    var allResults = data.docs;

    var showResult = [];
    if (searchController.text.isNotEmpty) {
      for (var billSnapshot in allResults) {
        var name = billSnapshot['party_name'].toString().toLowerCase();
        if (name.contains(searchController.text.toLowerCase())) {
          showResult.add(billSnapshot);
        }
      }
    } else {
      showResult = List.from(allResults);
    }

    setState(() {
      _resultList = showResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10),
              margin: const EdgeInsets.only(bottom: 10),
              height: MediaQuery.of(context).size.height / 16,
              width: MediaQuery.of(context).size.width / 1.2,
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
                  SizedBox(width: MediaQuery.of(context).size.width / 35),
                  Expanded(
                    child: TextFormField(
                      controller: searchController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search by party name',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.3,
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sellBills')
                    .orderBy('timeStamp', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  _resultList = snapshot.data!.docs.where((doc) {
                    final partyName =
                        doc['party_name']?.toString().toLowerCase() ?? '';
                    final searchText = searchController.text.toLowerCase();
                    return searchText.isEmpty || partyName.contains(searchText);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _resultList.length,
                    itemBuilder: (context, index) {
                      final bill =
                          _resultList[index].data() as Map<String, dynamic>;
                      final items = bill['items'] as List<dynamic>;

                      double totalProfit = 0.0;
                      double cashDiscount = double.tryParse(
                              bill['cashDiscount']?.toString() ?? '0.0') ??
                          0.0;

                      for (var item in items) {
                        double purchaseRate = double.tryParse(
                                item['purchaseRate']?.toString() ?? '0.0') ??
                            0.0;
                        double saleRate = double.tryParse(
                                item['saleRate']?.toString() ?? '0.0') ??
                            0.0;
                        int quantity =
                            int.tryParse(item['quantity']?.toString() ?? '0') ??
                                0;
                        int freeQuantity = int.tryParse(
                                item['freeQuantity']?.toString() ?? '0') ??
                            0;

                        double itemProfit =
                            (saleRate - purchaseRate) * quantity;

                        // print(
                        //     'Item Profit: $itemProfit for totalQuantity: $totalQuantity, saleRate: $saleRate, purchaseRate: $purchaseRate');

                        totalProfit += itemProfit;
                      }

                      double discountAmount =
                          (totalProfit * cashDiscount) / 100;
                      totalProfit -= discountAmount;

                      print('Total Profit after discount: $totalProfit');

                      return Card(
                        margin: const EdgeInsets.all(15),
                        color: Colors.yellow.shade200.withOpacity(0.8),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(bill['party_name']),
                            subtitle: Text(
                                "Date : ${bill['date']} | Bill No : ${bill['billNumber']}"),
                            children: [
                              Column(
                                children: items.map<Widget>((item) {
                                  double purchaseRate = double.tryParse(
                                          item['purchaseRate']?.toString() ??
                                              '0.0') ??
                                      0.0;
                                  double saleRate = double.tryParse(
                                          item['saleRate']?.toString() ??
                                              '0.0') ??
                                      0.0;
                                  int quantity = int.tryParse(
                                          item['quantity']?.toString() ??
                                              '0') ??
                                      0;
                                  double profit =
                                      (saleRate - purchaseRate) * quantity;

                                  return ListTile(
                                    title:
                                        Text('Product: ${item['productName']}'),
                                    subtitle: Text(
                                      'Quantity: $quantity, Purchase: $purchaseRate, Sale: $saleRate, Profit: ${profit.toStringAsFixed(2)}',
                                    ),
                                  );
                                }).toList(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Total Profit after ${cashDiscount}% Discount: ${totalProfit.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
