class Inventory {
  String? inventoryID;
  String? inventoryName;
  String? inventoryCategory;
  String? inventoryQuantity;
  String? inventoryMaximumQuantity;
  String? inventoryBuyingPrice;
  String? inventorySellingPrice;
  String? inventorySupplierName;
  String? inventoryStaffID;
  String? inventoryRegistrationDate;

  Inventory({
    this.inventoryID,
    this.inventoryName,
    this.inventoryCategory,
    this.inventoryQuantity,
    this.inventoryMaximumQuantity,
    this.inventoryBuyingPrice,
    this.inventorySellingPrice,
    this.inventorySupplierName,
    this.inventoryStaffID,
    this.inventoryRegistrationDate,
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json['inventoryID'];
    inventoryName = json['inventoryName'];
    inventoryCategory = json['inventoryCategory'];
    inventoryQuantity = json['inventoryQuantity'];
    inventoryMaximumQuantity = json['inventoryMaximumQuantity'];
    inventoryBuyingPrice = json['inventoryBuyingPrice'];
    inventorySellingPrice = json['inventorySellingPrice'];
    inventorySupplierName = json['inventorySupplierName'];
    inventoryStaffID = json['inventoryStaffID'];
    inventoryRegistrationDate = json['inventoryRegistrationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['inventoryID'] = inventoryID;
    data['inventoryName'] = inventoryName;
    data['inventoryCategory'] = inventoryCategory;
    data['inventoryQuantity'] = inventoryQuantity;
    data['inventoryMaximumQuantity'] = inventoryMaximumQuantity;
    data['inventoryBuyingPrice'] = inventoryBuyingPrice;
    data['inventorySellingPrice'] = inventorySellingPrice;
    data['inventorySupplierName'] = inventorySupplierName;
    data['inventoryStaffID'] = inventoryStaffID;
    data['inventoryRegistrationDate'] = inventoryRegistrationDate;
    return data;
  }
}
