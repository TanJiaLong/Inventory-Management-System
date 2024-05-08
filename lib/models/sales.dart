class Sales {
  String? saleInventoryName;
  String? saleQuantity;
  String? salePrice;
  String? salesRegistrationDate;


  Sales({
    this.saleInventoryName,
    this.saleQuantity,
    this.salePrice,
    this.salesRegistrationDate,
  });

  Sales.fromJson(Map<String, dynamic> json) {
    saleInventoryName = json['saleInventoryName'];
    saleQuantity = json['saleQuantity'];
    salePrice = json['salePrice'];
    salesRegistrationDate = json['salesRegistrationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['saleInventoryName'] = saleInventoryName;
    data['saleQuantity'] = saleQuantity;
    data['salePrice'] = salePrice;
    data['salesRegistrationDate'] = salesRegistrationDate;
    return data;
  }
}
