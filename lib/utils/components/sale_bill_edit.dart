import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final void Function(Map<String, dynamic>) onUpdate;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController quantityController;
  late TextEditingController freeQuantityController;
  late TextEditingController amountController;
  late TextEditingController discountController;
  late TextEditingController netAmountController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.product['quantity'].toString());
    freeQuantityController = TextEditingController(text: widget.product['freeQuantity']);
    amountController = TextEditingController(text: widget.product['amount'].toString());
    discountController = TextEditingController(text: widget.product['discount']?.toString() ?? '');
    netAmountController = TextEditingController(text: widget.product['netAmount'].toString());
  }

  @override
  void dispose() {
    quantityController.dispose();
    freeQuantityController.dispose();
    amountController.dispose();
    discountController.dispose();
    netAmountController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    final updatedProduct = {
      ...widget.product,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'freeQuantity': freeQuantityController.text,
      'amount': double.tryParse(amountController.text) ?? 0,
      'discount': double.tryParse(discountController.text) ?? 0,
      'netAmount': double.tryParse(netAmountController.text) ?? 0,
    };
    widget.onUpdate(updatedProduct);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: freeQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Free Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Discount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: netAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Net Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
