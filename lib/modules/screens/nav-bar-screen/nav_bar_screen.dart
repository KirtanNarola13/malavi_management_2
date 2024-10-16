import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:malavi_management/modules/screens/product-screen/all_products.dart';
import 'package:malavi_management/modules/screens/profit-screen/profitScreen.dart';

import '../bill-screen/bill_screen.dart';
import '../home-screen/home_screen.dart';

class NavBarScreen extends StatefulWidget {
  final int initialIndex;

  const NavBarScreen({super.key, this.initialIndex = 0});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const AllProducts(),
    const BillScreen(),
    const ProfitScreen(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    currentIndex = widget.initialIndex; // Set the initial index
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentIndex], // Display the current screen here
      bottomNavigationBar: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.circle,
        padding: const EdgeInsets.all(12),
        snakeViewColor: Colors.yellow,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Product'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Bill'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Malavi'),
        ],
      ),
    );
  }
}
