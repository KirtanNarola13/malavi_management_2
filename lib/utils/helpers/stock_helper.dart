import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class StockHelper {
  StockHelper._();

  static final StockHelper stockHelper = StockHelper._();

  Future<void> removeNegativeStockEntries() async {
    final productStockRef =
        FirebaseFirestore.instance.collection('productStock');

    // Fetch all products in productStock collection
    final productDocsSnapshot = await productStockRef.get();
    final finalTempRed =
        await FirebaseFirestore.instance.collection('productStock');
    final tempSnapshot = await finalTempRed.get();
    var priviousesDocRef = tempSnapshot.docs[0].reference;
    var tempData = tempSnapshot.docs[0].data();

    int totalNativeStock = 0;
    for (final productDoc in productDocsSnapshot.docs) {
      final productName = productDoc.id;

      // Get the purchaseHistory sub-collection for each product
      final purchaseHistoryRef =
          productStockRef.doc(productName).collection('purchaseHistory');
      final purchaseHistorySnapshot = await purchaseHistoryRef.get();

      int totalStock = 0;

      // Iterate through each entry in purchaseHistory sub-collection
      for (final purchaseHistoryDoc in purchaseHistorySnapshot.docs) {
        final purchaseData = purchaseHistoryDoc.data();

        // Check if quantity is negative
        final quantity = (purchaseData['quantity'] as num?)?.toInt() ?? 0;

        if (quantity < 0) {
          // If the quantity is negative, remove the document from purchaseHistory

          totalNativeStock += quantity;

          await purchaseHistoryDoc.reference.delete();

          print(
              'Removed purchase history entry with negative stock for $productName');
        } else if (quantity > 0) {
          priviousesDocRef = purchaseHistoryDoc.reference;
          tempData = purchaseData;

          if (totalNativeStock <= 0) {
            totalStock += quantity;
            await purchaseHistoryDoc.reference.update(
                {'quantity': purchaseData['quantity'] + totalNativeStock}).then((e){

            });
          }

          totalNativeStock = 0;
        } else {
          // Otherwise, add the quantity to the total stock
          totalStock += quantity;
        }
      }
      // await priviousesDocRef
      //     .update({'quantity': tempData['quantity'] - totalNativeStock});
      // After removing negative stock entries, update the total stock for the product
      await productStockRef.doc(productName).update({
        'totalStock': totalStock,
        'updatedAt': Timestamp.now(),
      });

      print('Updated total stock for $productName: $totalStock');
    }

    print('Negative stock entries removed successfully.');
  }
}
