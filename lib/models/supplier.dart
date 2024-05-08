class Supplier {
  String? supplierId;
  String? supplierName;
  String? supplierEmail;
  String? supplierPhone;
  String? supplierSuppliedCategory;

  Supplier({
    this.supplierId,
    this.supplierName,
    this.supplierEmail,
    this.supplierPhone,
    this.supplierSuppliedCategory,
  });

  Supplier.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplierID'];
    supplierName = json['supplierName'];
    supplierEmail = json['supplierEmail'];
    supplierPhone = json['supplierPhone'];
    supplierSuppliedCategory = json['supplierSuppliedCategory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['supplierID'] = supplierId;
    data['supplierName'] = supplierName;
    data['supplierEmail'] = supplierEmail;
    data['supplierPhone'] = supplierPhone;
    data['supplierSuppliedCategory'] = supplierSuppliedCategory;
    return data;
  }
}
