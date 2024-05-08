import 'package:flutter/material.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/authentication/loginscreen.dart';
import 'package:ims/screens/employee/homescreen.dart';
import 'package:ims/screens/employer/homescreen.dart';
import 'package:ims/screens/employer/sales/salescreen.dart';
import 'package:ims/screens/employer/supplier/supplierscreen.dart';
import 'package:ims/screens/shared/inventory/inventoryscreen.dart';
import 'package:ims/screens/shared/profile/profilescreen.dart';
import 'package:ims/screens/shared/scanqrscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _curIndex = 0;
  late List<Widget> screenList;
  late List<BottomNavigationBarItem> navList;

  @override
  void initState() {
    super.initState();

    determineScreens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList[_curIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _curIndex,
        onTap: onTapMethod,
        items: navList,
      ),
    );
  }

  void onTapMethod(int value) {
    setState(() {
      _curIndex = value;
    });
  }

  void determineScreens() {
    if (widget.user.userRole == "Employer" ||
        widget.user.userRole == "Inventory Manager") {
      screenList = <Widget>[
        EmployerHomeScreen(user: widget.user),
        InventoryScreen(user: widget.user),
        const SaleScreen(),
        const SupplierScreen(),
        ProfileScreen(user: widget.user),
      ];

      navList = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.file_copy_outlined),
          label: "Inventory",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined),
          label: "Sales",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          label: "Supplier",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: "Profile",
        ),
      ];
    } else if (widget.user.userRole == "Employee") {
      screenList = <Widget>[
        const EmployeeHomeScreen(),
        InventoryScreen(user: widget.user),
        ScanQRScreen(user: widget.user),
        ProfileScreen(
          user: widget.user,
        ),
      ];

      navList = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.file_copy_outlined),
          label: "Inventory",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_sharp),
          label: "Scan QR",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: "Profile",
        ),
      ];
    }
  }
}
