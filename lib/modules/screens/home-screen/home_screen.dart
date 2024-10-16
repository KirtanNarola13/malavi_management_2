import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/utils/components/add_account.dart';
import 'package:malavi_management/utils/components/add_category.dart';
import 'package:malavi_management/utils/components/product_screen.dart';
import 'package:malavi_management/utils/components/purchase_bill/purchase_bill_screen.dart';
import 'package:malavi_management/utils/components/purchase_bill_history.dart';
import 'package:malavi_management/utils/components/sale_bill.dart';
import 'package:malavi_management/utils/components/view_stoke.dart';

import '../../../utils/components/add_company.dart';
import '../../../utils/helpers/stock_helper.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  Future<void> updateStock() async {
    await StockHelper.stockHelper.removeNegativeStockEntries();
  }

  @override
  Widget build(BuildContext context) {
    updateStock();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
        ),
      ),
      body: GridView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(
          30,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 40,
          crossAxisSpacing: 40,
        ),
        children: [
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(
                30,
              ),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(
                    0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.add_box_outlined,
                        size: 35,
                      ),
                      Text(
                        "Add Products",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewStock(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(
                    0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      30,
                    ),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.inventory_outlined,
                        size: 35,
                      ),
                      Text(
                        "View Stock",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAccount(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.account_box_outlined,
                        size: 35,
                      ),
                      Text(
                        "Add Account",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCompany(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.apartment,
                        size: 35,
                      ),
                      Text(
                        "Add Company",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCategory(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.category,
                        size: 35,
                      ),
                      Text(
                        "Add Category",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseBillScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.add_shopping_cart,
                        size: 35,
                      ),
                      Text(
                        "Purchase Bill",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseBillHistory(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.history,
                        size: 35,
                      ),
                      Text(
                        "P.Bill History",
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(
              milliseconds: 1500,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellBillScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(
                30,
              ),
              splashColor: Colors.yellow,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(
                    0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      30,
                    ),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1,
                      ),
                      Icon(
                        Icons.sell_outlined,
                        size: 35,
                      ),
                      Text(
                        "Sale Bill",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
