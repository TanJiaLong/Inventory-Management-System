import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/inventory.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  final List<Inventory> lowQuantityInventoryList;
  const NotificationScreen({super.key, required this.lowQuantityInventoryList});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late double sWidth, sHeight, textSize;
  late final List<Inventory> _lowQuantityInventoryList;

  @override
  void initState() {
    super.initState();
    _lowQuantityInventoryList = widget.lowQuantityInventoryList;
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshLowQuantityInventory();
        },
        child: ListView.builder(
          itemCount: _lowQuantityInventoryList.length,
          itemBuilder: (BuildContext context, int index) {
            Inventory curInventory = _lowQuantityInventoryList[index];
            double stockLevel = double.parse(
                    curInventory.inventoryQuantity.toString()) /
                double.parse(curInventory.inventoryMaximumQuantity.toString()) *
                100;
            return Container(
              margin: EdgeInsets.all(textSize / 4),
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(textSize / 4)),
              child: ListTile(
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.black,
                  ),
                ),
                title: const Text("Low Stock Level Notifications"),
                subtitle: Text.rich(
                  TextSpan(text: "Stock Level for ", children: [
                    TextSpan(
                        text: "InventoryID: ${curInventory.inventoryID}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: " is about "),
                    TextSpan(
                        text:
                            "$stockLevel% (${curInventory.inventoryQuantity}/${curInventory.inventoryMaximumQuantity})",
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void refreshLowQuantityInventory() async {
    _lowQuantityInventoryList.clear();

    await http.post(
        Uri.parse("${MyConfig.server}/ims/php/load_low_quantity_inventory.php"),
        body: {}).then((response) {
      if (response.statusCode == 200) {
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          dynamic extractLowQuantityInventories = jsonData['data'];
          extractLowQuantityInventories['inventories']
              .forEach((currentInventory) {
            _lowQuantityInventoryList.add(Inventory.fromJson(currentInventory));
          });
          setState(() {});
        } else {}
      } else {}
    });
  }
}
