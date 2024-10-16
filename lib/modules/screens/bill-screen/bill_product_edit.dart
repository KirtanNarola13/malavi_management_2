import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/modules/screens/bill-screen/const.dart';

class BillProductEdit extends StatefulWidget {
  const BillProductEdit({super.key});

  @override
  State<BillProductEdit> createState() => _BillProductEditState();
}

class _BillProductEditState extends State<BillProductEdit> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController freeQuantityController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController netAmountController = TextEditingController();
  final TextEditingController saleRateController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController marginController = TextEditingController();
  final TextEditingController purchaseRateController = TextEditingController();

  int? quantity;
  int? freeQuantity;
  double? mrp;
  double? saleRate;
  double? totalAmount;
  double? netAmount;
  double? discount;
  double? margin;
  double? purchaseRate;
  Map billItems = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map?;
      if (arguments != null) {
        setState(() {
          billItems = arguments;
          quantityController.text = billItems['quantity']?.toString() ?? '';
          freeQuantityController.text =
              billItems['freeQuantity']?.toString() ?? '';
          mrpController.text = billItems['mrp']?.toString() ?? '';
          netAmountController.text = billItems['netAmount']?.toString() ?? '';
          saleRateController.text = billItems['saleRate']?.toString() ?? '';
          totalAmountController.text =
              billItems['totalAmount']?.toString() ?? '';
          marginController.text = billItems['margin']?.toString() ?? '';
          purchaseRateController.text =
              billItems['purchaseRate']?.toString() ?? '';
          discountController.text = billItems['discount']?.toString() ?? '';
        });
      } else {
        if (kDebugMode) {
          print("No arguments found for this route.");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${billItems['productName'] ?? 'Edit Product'}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextFieldRow(
                controller1: quantityController,
                labelText1: 'Quantity',
                onChanged1: (value) {
                  setState(
                    () {
                      calculateTotalAmount();
                      calculateNetAmount();
                    },
                  );
                },
                controller2: freeQuantityController,
                labelText2: 'Free Quantity',
                onChanged2: (value) {},
              ),
              const SizedBox(
                height: 10,
              ),
              buildTextFieldRow(
                controller1: mrpController,
                labelText1: 'MRP',
                onChanged1: (value) {
                  setState(
                    () {
                      calculateSaleRate();
                    },
                  );
                },
                controller2: purchaseRateController,
                labelText2: 'Purchase Rate',
                onChanged2: (value) {
                  setState(() {
                    calculateTotalAmount();
                    calculateNetAmount();
                  });
                },
              ),
              const SizedBox(height: 10),
              buildTextFieldRow(
                controller1: saleRateController,
                labelText1: 'Sale Rate',
                onChanged1: (value) {
                  setState(() {
                    calculateMargin();
                  });
                },
                controller2: marginController,
                labelText2: 'Margin (%)',
                onChanged2: (value) {
                  setState(() {
                    calculateSaleRate();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: totalAmountController,
                decoration: const InputDecoration(
                  label: Text("Total Amount"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildTextFieldRow(
                controller1: discountController,
                labelText1: 'Discount (%)',
                onChanged1: (value) {
                  setState(() {
                    calculateNetAmount();
                  });
                },
                controller2: netAmountController,
                labelText2: 'Net Amount',
                readOnly2: true,
              ),
              const SizedBox(height: 10),
              // buildTextFieldRow(
              //
              //   controller1: netAmountController,
              //   labelText1: 'Net Amount',
              //   readOnly1: true,
              //   controller2: mrpController,
              //   labelText2: 'MRP',
              //   onChanged2: (value) {
              //     setState(() {
              //       calculateSaleRate();
              //     });
              //   },
              // ),
              const SizedBox(height: 10),
              buildUpdateButton(),
            ],
          ),
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
    bool readOnly1 = false,
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
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final purchaseRate = double.tryParse(purchaseRateController.text) ?? 0.0;
    setState(() {
      totalAmount = quantity * purchaseRate;
      totalAmountController.text = totalAmount!.toStringAsFixed(2);
    });
  }

  void calculateNetAmount() {
    final discount = double.tryParse(discountController.text) ?? 0.0;
    final totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    setState(() {
      netAmount = totalAmount - (totalAmount * discount / 100);
      netAmountController.text = netAmount?.toStringAsFixed(2) ?? '';
    });
  }

  void calculateSaleRate() {
    final mrp = double.tryParse(mrpController.text) ?? 0.0;
    final margin = double.tryParse(marginController.text) ?? 0.0;
    if (margin > 0) {
      setState(() {
        saleRate = mrp / (1 + (margin / 100));
        saleRateController.text = saleRate?.toStringAsFixed(2) ?? '';
      });
    }
  }

  void calculateMargin() {
    final mrp = double.tryParse(mrpController.text) ?? 0.0;
    final saleRate = double.tryParse(saleRateController.text) ?? 0.0;
    if (saleRate > 0) {
      setState(() {
        margin = ((mrp - saleRate) / mrp) * 100;
        marginController.text = margin?.toStringAsFixed(2) ?? '';
      });
    }
  }

  void updateProductDetails() {
    saleBillProduct = {
      'productName': billItems['productName'],
      'date': billItems['date'],
      'partyName': billItems['partyName'],
      'partyAddress': billItems['partyAddress'],
      'salesMan': billItems['salesMan'],
      'quantity': quantityController.text,
      'freeQuantity': freeQuantityController.text,
      'purchaseRate': purchaseRateController.text,
      'totalAmount': totalAmountController.text,
      'netAmount': netAmountController.text,
      'margin': marginController.text,
      'saleRate': saleRateController.text,
      'mrp': mrpController.text,
      'discount': discountController.text,
    };

    Navigator.pop(context);
  }
}
