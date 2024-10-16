import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductEditPurchaseBillHistory extends StatefulWidget {
  const ProductEditPurchaseBillHistory({super.key});

  @override
  State<ProductEditPurchaseBillHistory> createState() =>
      _ProductEditPurchaseBillHistoryState();
}

class _ProductEditPurchaseBillHistoryState
    extends State<ProductEditPurchaseBillHistory> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController saleRateController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController marginController = TextEditingController();
  final TextEditingController purchaseRateController = TextEditingController();
  int? quantity;
  double? mrp;
  double? saleRate;
  double? totalAmount;
  double? margin;
  double? purchaseRate;
  Map billItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      billItems = ModalRoute.of(context)!.settings.arguments as Map;

      setState(() {
        quantityController.text = billItems['quantity'].toString();
        mrpController.text = billItems['mrp'].toString();
        saleRateController.text = billItems['saleRate'].toString();
        totalAmountController.text = billItems['totalAmount'].toString();
        marginController.text = billItems['margin'].toString();
        purchaseRateController.text = billItems['purchaseRate'].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${billItems['productName']}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildTextFieldRow(
              controller1: quantityController,
              labelText1: 'Quantity',
              onChanged1: (value) {
                setState(() {
                  quantity = int.tryParse(value);
                  calculateTotalAmount();
                });

                calculateTotalAmount();
              },
              controller2: mrpController,
              labelText2: 'MRP',
              onChanged2: (value) {
                setState(() {
                  mrp = double.tryParse(value);
                  calculateSaleRate();
                });
              },
            ),
            const SizedBox(height: 10),
            buildTextFieldRow(
              controller1: purchaseRateController,
              labelText1: 'Purchase rate',
              onChanged1: (value) {
                setState(() {
                  purchaseRate = double.tryParse(value);
                  calculateTotalAmount();
                });
              },
              controller2: totalAmountController,
              labelText2: 'Total Amount',
              readOnly2: true,
            ),
            const SizedBox(height: 10),
            buildTextFieldRow(
              controller1: marginController,
              labelText1: 'Margin (%)',
              onChanged1: (value) {
                setState(() {
                  margin = double.tryParse(value) ?? 0.0;
                  calculateSaleRate();
                });
              },
              controller2: saleRateController,
              labelText2: 'Sale Rate',
              onChanged2: (value) {
                setState(() {
                  saleRate = double.tryParse(value) ?? 0.0;
                  calculateMargin();
                });
              },
            ),
            const SizedBox(height: 10),
            buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldRow({
    required TextEditingController controller1,
    required String labelText1,
    required Function(String) onChanged1,
    required TextEditingController controller2,
    required String labelText2,
    Function(String)? onChanged2,
    bool readOnly2 = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller1,
            decoration: InputDecoration(
              labelText: labelText1,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: onChanged1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller2,
            decoration: InputDecoration(
              labelText: labelText2,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            keyboardType: TextInputType.number,
            readOnly: readOnly2,
            onChanged: onChanged2,
          ),
        ),
      ],
    );
  }

  Widget buildUpdateButton() {
    return MaterialButton(
      minWidth: double.infinity,
      height: 60,
      onPressed: () {
        updateProductDetails();
      },
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Text(
        "Update",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  void calculateTotalAmount() {
    setState(() {
      totalAmount = (int.parse(quantityController.text)) *
          (double.parse(purchaseRateController.text));
      totalAmountController.text = totalAmount.toString();
    });
  }

  void calculateSaleRate() {
    saleRate = (double.parse(mrpController.text) /
        double.parse(marginController.text));
    saleRateController.text = saleRate?.toStringAsFixed(2) ?? '';
  }

  void calculateMargin() {
    margin = mrp! / saleRate!;
    marginController.text = margin?.toStringAsFixed(2) ?? '';
  }

  void updateProductDetails() async {
    int originalQuantity = billItems['quantity'];
    int newQuantity = int.parse(quantityController.text);

    // Calculate stock difference
    int stockDifference = newQuantity - originalQuantity;

    // Update product stock
    String productName = billItems['productName'];
    await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productName)
        .update({
      'total_quantity': FieldValue.increment(-stockDifference),
    });

    // Update the bill with the new product details
    Map<String, dynamic> updatedProduct = {
      'productName': productName,
      'quantity': newQuantity,
      'purchaseRate': double.parse(purchaseRateController.text),
      'totalAmount': double.parse(totalAmountController.text),
      'margin': double.parse(marginController.text),
      'saleRate': double.parse(saleRateController.text),
      'mrp': double.parse(mrpController.text),
    };

    Navigator.pop(context, updatedProduct);
  }
}
