import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../nav-bar-screen/nav_bar_screen.dart';

class SaleBillEdit extends StatefulWidget {
  final List? items;
  final String? billDocId;
  const SaleBillEdit({Key? key, required this.billDocId, required this.items})
      : super(key: key);

  @override
  State<SaleBillEdit> createState() => _SaleBillEditState();
}

class _SaleBillEditState extends State<SaleBillEdit> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? selectedParty;
  String? selectedProduct;
  String partyAddress = "";
  String? selectedPartyProduct;
  int? selectedQuantity;
  String? salesMan;

  double? mrp;
  double? marginPercentage;
  double? saleRate;
  double? purchaseRate;
  int? quantity;
  int? freeQuantity;
  double? amount;
  double? discount;
  double? netAmount;
  List billItems = [];
  String? billId;
  String? billNumber;

  int? editingIndex;

  final amountController = TextEditingController();
  final freeQuantityController = TextEditingController();
  final discountController = TextEditingController();
  final netAmountController = TextEditingController();
  final marginController = TextEditingController();
  final mrpController = TextEditingController();
  final saleRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    billItems = widget.items ?? [];
    billId = widget.billDocId;
    if (billId != null) {
      _loadExistingBillData();
    }
  }

  Future<void> _loadExistingBillData() async {
    setState(() => _isLoading = true);
    try {
      final billDoc = await FirebaseFirestore.instance
          .collection('sellBills')
          .doc(billId)
          .get();
      if (billDoc.exists) {
        final data = billDoc.data() as Map<String, dynamic>;
        setState(() {
          selectedParty = data['party_name'];
          salesMan = data['salesMan'];
          partyAddress = data['partyAddress'];
          billNumber = data['billNumber'];
          billItems = List.from(data['items']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bill data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(billId == null ? 'Create Sell Bill' : 'Edit Sell Bill'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSalesManDropdown(),
                      const SizedBox(height: 10),
                      _buildPartyAccountDropdown(),
                      const SizedBox(height: 10),
                      _buildProductDropdown(),
                      const SizedBox(height: 10),
                      if (selectedProduct != null) _buildPartyProductDropdown(),
                      const SizedBox(height: 10),
                      _buildQuantityInput(),
                      _buildFreeQuantityInput(),
                      _buildMrpAndMarginInputs(),
                      const SizedBox(height: 10),
                      _buildSaleRateAndAmountInputs(),
                      const SizedBox(height: 10),
                      _buildDiscountAndNetAmountInputs(),
                      const SizedBox(height: 20),
                      _buildAddProductButton(),
                      const SizedBox(height: 20),
                      _buildProductList(),
                      const SizedBox(height: 20),
                      Text(
                          'Total Amount: ${_calculateTotalAmount().toStringAsFixed(2)}'),
                      const SizedBox(height: 20),
                      _buildSaveBillButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSalesManDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('salesMan').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No sales man');
        }
        return DropdownButtonFormField<String>(
          value: salesMan,
          items: snapshot.data!.docs.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['name'],
              child: Text(doc['name']),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Sales Man',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) => setState(() => salesMan = value),
          validator: (value) =>
              value == null ? 'Please select a sales man' : null,
        );
      },
    );
  }

  Widget _buildPartyAccountDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sale party account')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No party accounts found');
        }
        return DropdownButtonFormField<String>(
          value: selectedParty,
          items: snapshot.data!.docs.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['account_name'],
              child: Text("${doc['account_name']} | ${doc['address']}"),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Sell party account',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            setState(() {
              selectedParty = value!;
              fetchPartyDetail(selectedParty!);
            });
          },
          validator: (value) =>
              value == null ? 'Please select a party account' : null,
        );
      },
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productStock').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No products found');
        }

        List<Map<String, dynamic>> items = snapshot.data!.docs.map((doc) {
          return {
            'id': doc.id,
            'label': "${doc['productName']} | Stock ${doc['totalStock']}",
          };
        }).toList();

        return DropdownSearch<String>(
          items: (filter, loadProps) {
            return items.map((item) => item['label'] as String).toList();
          },
          selectedItem: selectedProduct != null
              ? items
                  .firstWhere((item) => item['id'] == selectedProduct)['label']
              : null,
          onChanged: (String? newValue) {
            setState(() {
              selectedProduct =
                  items.firstWhere((item) => item['label'] == newValue)['id'];
              selectedPartyProduct = null;
            });
          },
        decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'Select Product',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          popupProps: const PopupProps.menu(showSearchBox: true),
          validator: (value) =>
              value == null ? 'Please select a product' : null,
        );
      },
    );
  }

  Widget _buildPartyProductDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productStock')
          .doc(selectedProduct)
          .collection('purchaseHistory')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No party products found');
        }
        return DropdownButtonFormField<String>(
          hint: const Text('Select Party\'s Product'),
          value: selectedPartyProduct,
          items: snapshot.data!.docs.map((doc) {
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(
                  "MRP: ${doc['mrp']} | Stock: ${doc['quantity']} | ${doc['purchaseRate']}"),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Party products',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            setState(() {
              selectedPartyProduct = value!;
              fetchProductDetails(selectedProduct!, value);
            });
          },
          validator: (value) =>
              value == null ? 'Please select a party product' : null,
        );
      },
    );
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantity = int.tryParse(value);
          calculateAmount();
        });
      },
      validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
    );
  }

  Widget _buildFreeQuantityInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Free Quantity',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      controller: freeQuantityController,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildMrpAndMarginInputs() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'MRP',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            readOnly: true,
            controller: mrpController,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Margin (%)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            controller: marginController,
            onChanged: (value) {
              if (mrp != null && value.isNotEmpty) {
                marginPercentage = double.tryParse(value);
                calculateSaleRate();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaleRateAndAmountInputs() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Sale Rate',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            controller: saleRateController,
            onChanged: (value) {
              saleRate = double.tryParse(value);
              calculateAmount();
              calculateMargin();
            },
            validator: (value) =>
                value!.isEmpty ? 'Please enter sale rate' : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Amount',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            controller: amountController,
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountAndNetAmountInputs() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Discount',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            controller: discountController,
            onChanged: (value) {
              discount = double.tryParse(value);
              calculateNetAmount();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Net Amount',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            keyboardType: TextInputType.number,
            controller: netAmountController,
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAddProductButton() {
    return Center(
      child: ElevatedButton(
        onPressed:
            editingIndex == null ? addProductToBill : updateProductInBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        ),
        child: Text(editingIndex == null ? 'Add Product' : 'Update Product'),
      ),
    );
  }

  Widget _buildProductList() {
    return Visibility(
      visible: billItems.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Added Products:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: billItems.length,
              itemBuilder: (context, index) {
                final item = billItems[index];
                return ListTile(
                  title: Text(item['productName']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editProduct(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            setState(() => billItems.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBillButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveOrUpdateBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        ),
        child: Text(billId == null ? 'Save Sell Bill' : 'Update Sell Bill'),
      ),
    );
  }

  Future<void> fetchProductDetails(
      String productName, String partyProductId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productName)
        .get();

    if (productDoc.exists) {
      final partyProductDoc = await FirebaseFirestore.instance
          .collection('productStock')
          .doc(productName)
          .collection('purchaseHistory')
          .doc(partyProductId)
          .get();

      if (partyProductDoc.exists) {
        setState(() {
          mrpController.text = partyProductDoc['mrp'].toString();
          marginController.text = partyProductDoc['margin'].toString();
          saleRateController.text = partyProductDoc['saleRate'].toString();
          purchaseRate = partyProductDoc['purchaseRate'];
          selectedQuantity = partyProductDoc['quantity'];
        });

        mrp = double.parse(mrpController.text);
        marginPercentage = double.parse(marginController.text);
        saleRate = double.parse(saleRateController.text);
        calculateAmount();
      } else {
        print('Party product document does not exist');
      }
    } else {
      print('Product document does not exist');
    }
  }

  Future<void> fetchPartyDetail(String partyName) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('sale party account')
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc['account_name'] == partyName) {
          setState(() {
            partyAddress = doc['address'] ?? 'No address available';
          });
          return;
        }
      }

      setState(() {
        partyAddress = 'No party found';
      });
    } catch (e) {
      print('Error fetching party details: $e');
      setState(() {
        partyAddress = 'Error fetching details';
      });
    }
  }

  void calculateSaleRate() {
    if (mrp != null && marginPercentage != null) {
      saleRate = (mrp! / marginPercentage!);
      saleRateController.text = saleRate?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateMargin() {
    if (mrp != null && saleRate != null) {
      marginPercentage = mrp! / saleRate!;
      marginController.text = marginPercentage?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateAmount() {
    amount = saleRate! * quantity!;
    amountController.text = amount!.toStringAsFixed(2);
    calculateNetAmount();
  }

  void calculateNetAmount() {
    double discountPercentage = double.tryParse(discountController.text) ?? 0.0;
    double calculatedDiscount = amount! * (discountPercentage / 100);
    netAmount = amount! - calculatedDiscount;
    netAmountController.text = netAmount!.toStringAsFixed(2);
  }

  void clearFields() {
    selectedProduct = null;
    quantity = null;
    amount = null;
    discount = null;
    netAmount = null;
    amountController.clear();
    discountController.clear();
    netAmountController.clear();
    freeQuantityController.clear();
  }

  void addProductToBill() {
    if (_formKey.currentState!.validate() &&
        selectedProduct != null &&
        quantity != null &&
        netAmount != null &&
        saleRate! >= purchaseRate! &&
        (selectedQuantity ?? 0) > 0) {
      setState(() {
        billItems.add({
          'partyName': selectedParty,
          'partyAddress': partyAddress,
          'salesMan': salesMan,
          'productName': selectedProduct,
          'partyProduct': selectedPartyProduct,
          'quantity': quantity,
          'freeQuantity': freeQuantityController.text,
          'mrp': mrpController.text,
          'margin': marginController.text,
          'saleRate': saleRate,
          'purchaseRate': purchaseRate,
          'amount': amount,
          'discount': discountController.text,
          'netAmount': netAmount,
          'date':
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        });
        clearFields();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the product details')),
      );
    }
  }

  void editProduct(int index) {
    final item = billItems[index];
    setState(() {
      salesMan = item['salesMan'] as String?;
      selectedParty = item['partyName'] as String?;
      selectedProduct = item['productName'] as String?;
      selectedPartyProduct = item['partyProduct'] as String?;
      freeQuantity = item['freeQuantity'] != null
          ? int.tryParse(item['freeQuantity'].toString())
          : null;
      mrp =
          item['mrp'] != null ? double.tryParse(item['mrp'].toString()) : null;
      marginPercentage = item['margin'] != null
          ? double.tryParse(item['margin'].toString())
          : null;
      saleRate = item['saleRate'] != null
          ? double.tryParse(item['saleRate'].toString())
          : null;
      amount = item['amount'] != null
          ? double.tryParse(item['amount'].toString())
          : null;
      discount = item['discount'] != null
          ? double.tryParse(item['discount'].toString())
          : null;
      netAmount = item['netAmount'] != null
          ? double.tryParse(item['netAmount'].toString())
          : null;
      quantity = item['quantity'] != null
          ? int.parse(item['quantity'].toString())
          : null;

      amountController.text = amount?.toString() ?? '';
      freeQuantityController.text = freeQuantity?.toString() ?? '';
      marginController.text = marginPercentage?.toString() ?? '';
      discountController.text = discount?.toString() ?? '';
      netAmountController.text = netAmount?.toString() ?? '';
      saleRateController.text = saleRate?.toString() ?? '';
      mrpController.text = mrp?.toString() ?? '';

      editingIndex = index;
    });
  }

  void updateProductInBill() {
    if (_formKey.currentState!.validate()) {
      final product = {
        'partyName': selectedParty,
        'partyAddress': partyAddress,
        'salesMan': salesMan,
        'productName': selectedProduct,
        'partyProduct': selectedPartyProduct,
        'quantity': quantity,
        'freeQuantity': freeQuantityController.text,
        'mrp': mrpController.text,
        'margin': marginController.text,
        'saleRate': saleRate,
        'purchaseRate': purchaseRate,
        'amount': amount,
        'discount': discount,
        'netAmount': netAmount,
      };
      setState(() {
        billItems[editingIndex!] = product;
        clearFields();
        editingIndex = null;
      });
    }
  }

  double _calculateTotalAmount() {
    return billItems.fold(0.0, (sum, item) => sum + (item['netAmount'] ?? 0.0));
  }

  Future<void> _saveOrUpdateBill() async {
    // if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(billId == null ? 'Save Bill' : 'Update Bill'),
        content: Text(
            'Are you sure you want to ${billId == null ? 'save' : 'update'} this bill?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _updateStockQuantities();
      await _saveBillToFirestore();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Bill ${billId == null ? 'saved' : 'updated'} successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const NavBarScreen(initialIndex: 1)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error ${billId == null ? 'saving' : 'updating'} bill: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStockQuantities() async {
    final batch = FirebaseFirestore.instance.batch();
    for (var item in billItems) {
      final productRef = FirebaseFirestore.instance
          .collection('productStock')
          .doc(item['productName']);
      final partyProductRef =
          productRef.collection('purchaseHistory').doc(item['partyProduct']);

      batch.update(
          productRef, {'totalStock': FieldValue.increment(-item['quantity'])});
      batch.update(partyProductRef,
          {'quantity': FieldValue.increment(-item['quantity'])});
    }
    await batch.commit();
  }

  Future<void> _saveBillToFirestore() async {
    final billData = {
      'billNumber': billNumber ?? await _generateNewBillNumber(),
      'grandTotal': _calculateTotalAmount(),
      'salesMan': salesMan,
      'date':
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      'timeStamp': DateTime.now(),
      'party_name': selectedParty,
      'kasar': 0,
      'cashDiscount': 0.0,
      'paymentStatus': 'pending',
      'partyAddress': partyAddress,
      'items': billItems,
    };

    if (billId == null) {
      await FirebaseFirestore.instance.collection('sellBills').add(billData);
    } else {
      await FirebaseFirestore.instance
          .collection('sellBills')
          .doc(billId)
          .update(billData);
    }
  }

  Future<String> _generateNewBillNumber() async {
    final billsCollection = FirebaseFirestore.instance.collection('sellBills');
    final lastBillDoc = await billsCollection
        .orderBy('billNumber', descending: true)
        .limit(1)
        .get();

    if (lastBillDoc.docs.isNotEmpty) {
      final lastBillNumber = lastBillDoc.docs.first['billNumber'];
      final currentNumber = int.parse(lastBillNumber.substring(1));
      final newNumber = currentNumber + 1;
      return 'A${newNumber.toString().padLeft(2, '0')}';
    } else {
      return 'A00';
    }
  }
}
