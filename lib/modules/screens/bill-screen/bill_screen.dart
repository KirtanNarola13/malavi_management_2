// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:malavi_management/modules/screens/bill-screen/bill_edit_screen.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share/share.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
// import '../nav-bar-screen/nav_bar_screen.dart';
//
// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});
//
//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }
//
// class _BillScreenState extends State<BillScreen> {
//   final CollectionReference sellBillsCollection =
//       FirebaseFirestore.instance.collection('sellBills');
//
//   Future<void> _deleteBill(String billId) async {
//     await FirebaseFirestore.instance
//         .collection('sellBills')
//         .doc(billId)
//         .delete();
//   }
//
//   List _resultList = [];
//   final TextEditingController searchController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   getAllData() async {
//     var data = await FirebaseFirestore.instance
//         .collection('sellBills')
//         .orderBy('timeStamp', descending: true)
//         .get();
//     setState(() {
//       _resultList = data.docs;
//     });
//   }
//
//   @override
//   void initState() {
//     getAllData();
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     // Trigger search function when text changes
//     searchResultList();
//   }
//
//   Future<void> searchResultList() async {
//     var data = await FirebaseFirestore.instance
//         .collection('sellBills')
//         .orderBy('timeStamp', descending: true)
//         .get();
//     var allResults = data.docs;
//
//     var showResult = [];
//     if (searchController.text.isNotEmpty) {
//       for (var billSnapshot in allResults) {
//         var name = billSnapshot['party_name'].toString().toLowerCase();
//         if (name.contains(searchController.text.toLowerCase())) {
//           showResult.add(billSnapshot);
//         }
//       }
//     } else {
//       showResult = List.from(allResults);
//     }
//     setState(() {
//       _resultList = showResult;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bill'),
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.only(left: 10),
//             margin: const EdgeInsets.only(bottom: 10),
//             height: MediaQuery.of(context).size.height / 16,
//             width: MediaQuery.of(context).size.width / 1.2,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(40),
//               border: Border.all(
//                 color: Colors.grey.shade700,
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.search_outlined,
//                   color: Colors.grey.shade700,
//                 ),
//                 SizedBox(width: MediaQuery.of(context).size.width / 35),
//                 Expanded(
//                   child: TextFormField(
//                     controller: searchController,
//                     focusNode: _focusNode,
//                     decoration: const InputDecoration(
//                       hintText: 'Search by party name',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 8,
//             child: StreamBuilder<QuerySnapshot>(
//               stream: sellBillsCollection
//                   .orderBy('timeStamp',
//                       descending:
//                           true) // Order bills by bill number in descending order
//                   .snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final bills = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: _resultList.length,
//                   itemBuilder: (context, index) {
//                     final billDoc = _resultList[index].id;
//                     final bill =
//                         _resultList[index].data() as Map<String, dynamic>;
//                     final items = bill['items'] as List<dynamic>;
//                                         // Handling potential null or incorrect types for grandTotal
//                     final grandTotal = double.tryParse(
//                             bill['grandTotal']?.toString() ?? '0.0') ??
//                         0.0;
//                     return Card(
//                       margin: const EdgeInsets.all(15),
//                       color: bill['paymentStatus'] == "Full Payment"
//                           ? Colors.green.shade200.withOpacity(0.5)
//                           : Colors.yellow.shade200.withOpacity(0.8),
//                       child: Theme(
//                         data: ThemeData()
//                             .copyWith(dividerColor: Colors.transparent),
//                         child: ExpansionTile(
//                           title: Text(
//                             "${bill['party_name']} - Amount : ${grandTotal.toStringAsFixed(2)}",
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           subtitle: Text(
//                               "Date : ${bill['date']} | Bill No : ${bill['billNumber']}"),
//                           children: [
//                             Column(
//                               children: items.map<Widget>((item) {
//                                 final quantity = double.tryParse(
//                                         item['quantity']?.toString() ??
//                                             '0.0') ??
//                                     0.0;
//                                 final netAmount = double.tryParse(
//                                         item['netAmount']?.toString() ??
//                                             '0.0') ??
//                                     0.0;
//
//                                 return ListTile(
//                                   title:
//                                       Text('Product: ${item['productName']}'),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                           'Quantity: ${quantity.toStringAsFixed(2)},\nNet Amount: ${netAmount.toStringAsFixed(2)}'),
//                                       Text(
//                                           'Cash Discount : ${bill['cashDiscount']}\nPayment : ${bill['paymentStatus']}\nKasar : ${bill['kasar']}'),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                             OverflowBar(
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.share),
//                                   onPressed: () async {
//                                     final pdf = await generatePdf(bill);
//                                     final tempDir =
//                                         await getTemporaryDirectory();
//                                     final file =
//                                         File('${tempDir.path}/bill.pdf');
//                                     await file.writeAsBytes(await pdf.save());
//                                     Share.shareFiles([file.path],
//                                         text: 'Your Bill');
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.edit),
//                                   onPressed: () {
//                                     editBill(billDoc, bill['items'],
//                                         grandTotal.toStringAsFixed(2));
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete),
//                                   onPressed: () async {
//                                     final shouldDelete = await showDialog<bool>(
//                                       context: context,
//                                       builder: (context) => AlertDialog(
//                                         title: const Text('Delete Bill'),
//                                         content: const Text(
//                                             'Are you sure you want to delete this bill?'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context)
//                                                     .pop(false),
//                                             child: const Text('Cancel'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () =>
//                                                 Navigator.of(context).pop(true),
//                                             child: const Text('Delete'),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//
//                                     if (shouldDelete == true) {
//                                       await _deleteBill(bills[index].id);
//                                     }
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.discount_outlined),
//                                   onPressed: () {
//                                     makePayment(context, grandTotal, billDoc);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void editBill(String billDocId, List billItems, String grandTotal) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const BillEditScreen(),
//         settings: RouteSettings(
//           arguments: {
//             'billDocId': billDocId,
//             'billItems': billItems,
//             'grandTotal': grandTotal,
//           },
//         ),
//       ),
//     );
//   }
//
//   double lastUpdateTotal = 0.0;
//
//   finalUpdateTotal(double grandTotal, double cashDiscountPercent) {
//     if (cashDiscountPercent > 0) {
//       double discountAmount = (grandTotal * cashDiscountPercent) / 100;
//       double lastTotal = grandTotal - discountAmount;
//       log('Last Total: $lastTotal | Discount Amount: $discountAmount | Grand Total: $grandTotal | Cash Discount: $cashDiscountPercent');
//     } else {
//       lastUpdateTotal = grandTotal;
//     }
//     return lastUpdateTotal.toStringAsFixed(2);
//   }
//
//   Future<void> _updatePaymentStatus(String paymentType, double receivedPayment,
//       String billDocId, double cashDiscount, double kasar) async {
//     final CollectionReference sellBillsCollection =
//         FirebaseFirestore.instance.collection('sellBills');
//     final DocumentSnapshot billSnapshot =
//         await sellBillsCollection.doc(billDocId).get();
//
//     if (billSnapshot.exists) {
//       final billData = billSnapshot.data() as Map<String, dynamic>;
//       final items = billData['items'] as List<dynamic>;
//
//       for (var item in items) {
//         if (paymentType == 'Full Payment') {
//           item['paymentStatus'] = 'done';
//         } else if (paymentType == 'Baki') {
//           item['paymentStatus'] = 'baki';
//         } else if (paymentType == 'Kasar') {
//           item['paymentStatus'] = 'kasar';
//           item['remainingAmount'] = receivedPayment;
//         }
//       }
//
//       double grandTotal =
//           double.tryParse(billData['grandTotal']?.toString() ?? '0.0') ?? 0.0;
//       // double discountedTotal = grandTotal - cashDiscount;
//       finalUpdateTotal(grandTotal, cashDiscount);
//       await sellBillsCollection.doc(billDocId).update({
//         'items': items,
//         'paymentStatus': paymentType,
//         'kasar': (paymentType == 'Kasar') ? kasar : 0,
//         'grandTotal': (paymentType == 'Kasar')
//             ? 0
//             : (paymentType == 'Full Payment')
//                 ? 0
//                 : grandTotal - receivedPayment,
//         'cashDiscount': cashDiscount,
//       });
//     }
//   }
//
//   void makePayment(BuildContext context, double grandTotal, String billDocId) {
//     TextEditingController receivedPaymentController = TextEditingController();
//     TextEditingController discountedTotalAmountController =
//         TextEditingController();
//     TextEditingController discountPercentageController =
//         TextEditingController();
//     String paymentType = 'Full Payment'; // Default payment type
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             double discountAmount = 0.0;
//             double discountedTotal = grandTotal;
//             double remainingAmount = grandTotal;
//             double kasar = 0.0;
//
//             return AlertDialog(
//               title: const Text('Payment Details'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('Grand Total: \$${grandTotal.toStringAsFixed(2)}'),
//                   const SizedBox(height: 10),
//                   DropdownButton<String>(
//                     value: paymentType,
//                     items: const [
//                       DropdownMenuItem(
//                           value: 'Full Payment', child: Text('Full Payment')),
//                       DropdownMenuItem(value: 'Baki', child: Text('Baki')),
//                       DropdownMenuItem(value: 'Kasar', child: Text('Kasar')),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         paymentType = value!;
//                         if (paymentType == 'Kasar') {
//                           kasar = discountedTotal -
//                               double.parse(receivedPaymentController.text);
//                         } else if (paymentType == 'Baki') {
//                           // For "Baki" type, show half payment pending
//                           // remainingAmount = grandTotal / 2;
//                         } else {
//                           remainingAmount = grandTotal;
//                         }
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: discountPercentageController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Cash Discount (%)',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         double discountPercentage =
//                             double.tryParse(value) ?? 0.0;
//                         discountAmount =
//                             (discountPercentage / 100) * grandTotal;
//                         discountedTotal = grandTotal - discountAmount;
//                         discountedTotalAmountController.text =
//                             discountedTotal.toDouble().toStringAsFixed(2);
//                         receivedPaymentController.text =
//                             discountedTotal.toDouble().toStringAsFixed(2);
//                         if (paymentType == 'Kasar') {
//                           kasar = discountedTotal -
//                               double.parse(receivedPaymentController.text);
//                         } else {
//                           remainingAmount = discountedTotal;
//                         }
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: discountedTotalAmountController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Discounted Payment',
//                       border: OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: receivedPaymentController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Received Payment',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         if (paymentType == 'Kasar') {
//                           kasar = discountedTotal -
//                               double.parse(receivedPaymentController.text);
//                         }
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   if (paymentType == 'Kasar') ...[
//                     Text(
//                         'Remaining Amount (Kasar): \$${kasar.toStringAsFixed(2)}'),
//                   ],
//                   if (paymentType == 'Baki') ...[
//                     Text(
//                         'Remaining Amount (Baki): \$${remainingAmount.toStringAsFixed(2)}'),
//                   ],
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     final receivedPayment =
//                         double.tryParse(receivedPaymentController.text) ?? 0.0;
//
//                     if (receivedPayment > 0 || paymentType == 'Baki') {
//                       double discountPercentage =
//                           double.tryParse(discountPercentageController.text) ??
//                               0.0;
//                       double discountAmount =
//                           grandTotal * (discountPercentage / 100);
//                       double discountedTotal = grandTotal - discountAmount;
//                       (paymentType == 'Kasar')
//                           ? discountedTotal - receivedPayment
//                           : (paymentType == 'Baki')
//                               ? discountedTotal - receivedPayment
//                               : discountedTotal - receivedPayment;
//
//                       _updatePaymentStatus(
//                           paymentType,
//                           receivedPayment,
//                           billDocId,
//                           double.parse(discountPercentageController.text),
//                           kasar);
//
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const NavBarScreen(
//                             initialIndex: 0,
//                           ),
//                         ),
//                         (route) => false,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Payment submitted successfully!'),
//                         ),
//                       );
//                     } else {
//                       // Handle invalid or empty input
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Invalid received payment amount.'),
//                         ),
//                       );
//                     }
//                   },
//                   child: const Text('Submit'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('Cancel'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<pw.Document> generatePdf(Map<String, dynamic> bill) async {
//     final pdf = pw.Document();
//
//     pw.Widget buildCell(String text,
//         {bool isHeader = false, bool isGrandTotal = false}) {
//       return pw.Padding(
//         padding: const pw.EdgeInsets.all(6.0),
//         child: pw.Text(
//           text,
//           textAlign: pw.TextAlign.center,
//           style: pw.TextStyle(
//             fontSize: isHeader
//                 ? 11
//                 : isGrandTotal
//                     ? 17
//                     : 10,
//             fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       );
//     }
//
//     double calculateDiscount(Map<String, dynamic> bill) {
//       double discount = 0;
//       for (var item in bill['items']) {
//         discount +=
//             double.tryParse(item['discount']?.toString() ?? '0.0') ?? 0.0;
//       }
//       return discount;
//     }
//
//     double total = 0;
//     calculateGrandTotal(Map<String, dynamic> bill, double cashDiscountPercent) {
//       for (var item in bill['items']) {
//         total += double.tryParse(item['netAmount']?.toString() ?? '0.0') ?? 0.0;
//       }
//       log(total.toString());
//       return total.toStringAsFixed(2);
//     }
//
//     Object finalTotal(double grandTotal, double cashDiscountPercent) {
//       if (cashDiscountPercent > 0) {
//         double discountAmount = (grandTotal * cashDiscountPercent) / 100;
//         double lastTotal = grandTotal - discountAmount;
//         log('Last Total: $lastTotal | Discount Amount: $discountAmount | Grand Total: $grandTotal | Cash Discount: $cashDiscountPercent');
//         return lastTotal.toStringAsFixed(2);
//       } else {
//         return grandTotal.toStringAsFixed(2);
//       }
//     }
//
//     double calculateTotalQuantity(Map<String, dynamic> bill) {
//       double totalQuantity = 0;
//       for (var item in bill['items']) {
//         totalQuantity +=
//             double.tryParse(item['quantity']?.toString() ?? '0.0') ?? 0.0;
//       }
//       return totalQuantity;
//     }
//
//     int calculateProdutsCount(Map<String, dynamic> bill) {
//       return bill['items'].length;
//     }
//
//     pdf.addPage(
//       pw.Page(
//         orientation: pw.PageOrientation.portrait,
//         margin: const pw.EdgeInsets.all(46.0),
//         pageFormat: PdfPageFormat.a3,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     mainAxisAlignment: pw.MainAxisAlignment.start,
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'DELIVERY CHALLAN',
//                         style: const pw.TextStyle(fontSize: 24),
//                       ),
//                       pw.SizedBox(height: 20),
//                       pw.Text(
//                         '${bill['party_name']}\n${bill['partyAddress']}',
//                         style: const pw.TextStyle(fontSize: 18),
//                       ),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text(
//                         '${bill['salesMan']}',
//                         style: const pw.TextStyle(fontSize: 24),
//                       ),
//                       pw.SizedBox(height: 20),
//                       pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text('Invoice number: ${bill['billNumber']}',
//                               style: const pw.TextStyle(fontSize: 16)),
//                           pw.Text('Date of issue: ${bill['date']}',
//                               style: const pw.TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               pw.SizedBox(
//                 height: 20,
//               ),
//               pw.Table(
//                 border: pw.TableBorder.all(),
//                 columnWidths: {
//                   0: const pw.FixedColumnWidth(25), // Item Number column
//                   1: const pw.FixedColumnWidth(200), // Name column
//                   2: const pw.FixedColumnWidth(50), // MRP column
//                   3: const pw.FixedColumnWidth(50), // Quantity column
//                   4: const pw.FixedColumnWidth(35), // Free column
//                   5: const pw.FixedColumnWidth(55), // Price column
//                   6: const pw.FixedColumnWidth(42), // Discount column
//                   7: const pw.FixedColumnWidth(70), // Amount column
//                 },
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       buildCell('No.', isHeader: true), // Item Number header
//                       buildCell('Name', isHeader: true),
//                       buildCell('MRP', isHeader: true),
//                       buildCell('Quantity', isHeader: true),
//                       buildCell('Free', isHeader: true),
//                       buildCell('Price', isHeader: true),
//                       buildCell('Discount', isHeader: true),
//                       buildCell('Amount', isHeader: true),
//                     ],
//                   ),
//                   ...((bill['items'] as List<dynamic>)
//                       .asMap()
//                       .entries
//                       .map((entry) {
//                     int index = entry.key + 1;
//                     var item = entry.value;
//                     String formattedAmount = (double.tryParse(
//                                 item['netAmount']?.toString() ?? '0.0') ??
//                             0.0)
//                         .toStringAsFixed(2);
//                     String formattedPrice = (double.tryParse(
//                                 item['saleRate']?.toString() ?? '0.0') ??
//                             0.0)
//                         .toStringAsFixed(2);
//
//                     return pw.TableRow(
//                       children: [
//                         buildCell(index.toString()), // Item Number
//                         buildCell(item['productName']),
//                         buildCell((double.tryParse(
//                                     item['mrp']?.toString() ?? '0.0') ??
//                                 0.0)
//                             .toStringAsFixed(2)),
//                         buildCell((double.tryParse(
//                                     item['quantity']?.toString() ?? '0.0') ??
//                                 0.0)
//                             .toStringAsFixed(2)),
//                         buildCell((double.tryParse(
//                                     item['freeQuantity']?.toString() ??
//                                         '0.0') ??
//                                 0.0)
//                             .toStringAsFixed(2)),
//                         buildCell(formattedPrice),
//                         buildCell((double.tryParse(
//                                     item['discount']?.toString() ?? '0.0') ??
//                                 0.0)
//                             .toStringAsFixed(2)),
//                         buildCell(formattedAmount),
//                       ],
//                     );
//                   }).toList()),
//                   pw.TableRow(
//                     children: [
//                       buildCell('${calculateProdutsCount(bill)}'),
//                       buildCell('Total'),
//                       buildCell(''),
//                       buildCell(calculateTotalQuantity(bill)
//                           .toStringAsFixed(2)), // Total Quantity
//                       buildCell(''),
//                       buildCell(''),
//                       buildCell(calculateDiscount(bill)
//                           .toStringAsFixed(2)), // Total Discount
//                       buildCell(
//                         (calculateGrandTotal(bill, bill['cashDiscount'])),
//                       ), // Grand Total
//                     ],
//                   ),
//                   pw.TableRow(
//                     children: [
//                       buildCell(''),
//                       buildCell(''),
//                       buildCell(''),
//                       buildCell(''), // Total Quantity
//                       buildCell(''),
//                       buildCell('CASH DISCOUNT', isHeader: true),
//                       buildCell('${bill['cashDiscount']}',
//                           isHeader: true), // Total Discount
//                       buildCell(' ${finalTotal(total, bill['cashDiscount'])}',
//                           isGrandTotal: true), // Grand Total
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     return pdf;
//   }
// }
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malavi_management/modules/screens/bill-screen/bill_edit_screen.dart';
import 'package:malavi_management/modules/screens/bill-screen/sale_bill_edit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../nav-bar-screen/nav_bar_screen.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final CollectionReference sellBillsCollection =
  FirebaseFirestore.instance.collection('sellBills');

  Future<void> _deleteBill(String billId) async {
    await FirebaseFirestore.instance
        .collection('sellBills')
        .doc(billId)
        .delete();
  }

  List _resultList = [];
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    getAllData();
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

  Future<void> getAllData() async {
    var data = await FirebaseFirestore.instance
        .collection('sellBills')
        .orderBy('timeStamp', descending: true)
        .get();
    setState(() {
      _resultList = data.docs;
    });
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
        title: const Text('Bill'),
      ),
      body: Column(
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
          Expanded(
            flex: 8,
            child: StreamBuilder<QuerySnapshot>(
              stream: sellBillsCollection
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bills = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: _resultList.length,
                  itemBuilder: (context, index) {
                    final billDoc = _resultList[index].id;
                    final bill =
                    _resultList[index].data() as Map<String, dynamic>;
                    final items = bill['items'] as List<dynamic>;
                    final grandTotal = double.tryParse(
                        bill['grandTotal']?.toString() ?? '0.0') ??
                        0.0;
                    return Card(
                      margin: const EdgeInsets.all(15),
                      color: bill['paymentStatus'] == "Full Payment"
                          ? Colors.green.shade200.withOpacity(0.5)
                          : Colors.yellow.shade200.withOpacity(0.8),
                      child: Theme(
                        data: ThemeData()
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            "${bill['party_name']} - Amount : ${grandTotal.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                              "Date : ${bill['date']} | Bill No : ${bill['billNumber']}"),
                          children: [
                            Column(
                              children: items.map<Widget>((item) {
                                final quantity = double.tryParse(
                                    item['quantity']?.toString() ??
                                        '0.0') ??
                                    0.0;
                                final netAmount = double.tryParse(
                                    item['netAmount']?.toString() ??
                                        '0.0') ??
                                    0.0;

                                return ListTile(
                                  title:
                                  Text('Product: ${item['productName']}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Quantity: ${quantity.toStringAsFixed(2)},\nNet Amount: ${netAmount.toStringAsFixed(2)}'),
                                      Text(
                                          'Cash Discount : ${bill['cashDiscount']}\nPayment : ${bill['paymentStatus']}\nKasar : ${bill['kasar']}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            OverflowBar(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () async {
                                    // final pdf = await generatePdf(bill);
                                    // final tempDir =
                                    // await getTemporaryDirectory();
                                    // final file =
                                    // File('${tempDir.path}/bill.pdf');
                                    // await file.writeAsBytes(await pdf.save());
                                    // Share.shareFiles([file.path],
                                    //     text: 'Your Bill');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // editBill(billDoc, bill['items'],
                                    //     grandTotal.toStringAsFixed(2));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SaleBillEdit(
                                            billDocId: billDoc,
                                            items: bill['items']),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Bill'),
                                        content: const Text(
                                            'Are you sure you want to delete this bill?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldDelete == true) {
                                      await _deleteBill(bills[index].id);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.discount_outlined),
                                  onPressed: () {
                                    makePayment(context, grandTotal, billDoc);
                                  },
                                ),
                              ],
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
    );
  }

  void editBill(String billDocId, List billItems, String grandTotal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BillEditScreen(),
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

  double lastUpdateTotal = 0.0;

  double finalUpdateTotal(double grandTotal, double cashDiscountPercent) {
    if (cashDiscountPercent > 0) {
      double discountAmount = (grandTotal * cashDiscountPercent) / 100;
      double lastTotal = grandTotal - discountAmount;
      log('Last Total: $lastTotal | Discount Amount: $discountAmount | Grand Total: $grandTotal | Cash Discount: $cashDiscountPercent');
      return lastTotal;
    } else {
      lastUpdateTotal = grandTotal;
    }
    return lastUpdateTotal;
  }

  Future<void> _updatePaymentStatus(String paymentType, double receivedPayment,
      String billDocId, double cashDiscount, double kasar) async {
    final CollectionReference sellBillsCollection =
    FirebaseFirestore.instance.collection('sellBills');
    final DocumentSnapshot billSnapshot =
    await sellBillsCollection.doc(billDocId).get();

    if (billSnapshot.exists) {
      final billData = billSnapshot.data() as Map<String, dynamic>;
      final items = billData['items'] as List<dynamic>;
      final grandTotal = double.tryParse(billData['grandTotal']?.toString() ?? '0.0') ?? 0.0;
      double finalTotal = finalUpdateTotal(grandTotal, cashDiscount);

      for (var item in items) {
        if (paymentType == 'Full Payment') {
          item['paymentStatus'] = 'done';
        } else if (paymentType == 'Baki') {
          item['paymentStatus'] = 'baki';
        } else if (paymentType == 'Advance') {
          item['paymentStatus'] = 'advance';
        }
      }

      await sellBillsCollection.doc(billDocId).update({
        'items': items,
        'paymentStatus': paymentType,
        'grandTotal': finalTotal,
        'receivedPayment': receivedPayment,
        'cashDiscount': cashDiscount,
        'kasar': kasar
      });
    }
  }

  Future<pw.Document> generatePdf(Map<String, dynamic> bill) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill Details',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Party Name: ${bill['party_name']}'),
            pw.Text('Date: ${bill['date']}'),
            pw.Text('Bill Number: ${bill['billNumber']}'),
            pw.Text('Cash Discount: ${bill['cashDiscount']}'),
            pw.Text('Kasar: ${bill['kasar']}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Product', 'Quantity', 'Net Amount'],
              data: bill['items'].map<List<String>>((item) {
                return [
                  item['productName'],
                  item['quantity'].toString(),
                  item['netAmount'].toString(),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Amount: ${bill['grandTotal']}'),
          ],
        );
      },
    ));

    return pdf;
  }

  void makePayment(BuildContext context, double grandTotal, String billDocId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double receivedPayment = 0.0;
        double cashDiscount = 0.0;
        double kasar = 0.0;
        return AlertDialog(
          title: const Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Received Payment'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  receivedPayment = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cash Discount (%)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  cashDiscount = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Kasar'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  kasar = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                await _updatePaymentStatus('Full Payment', receivedPayment,
                    billDocId, cashDiscount, kasar);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
