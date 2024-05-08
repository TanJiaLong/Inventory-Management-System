class InventoryMovement {
  String? imId;
  String? imInventoryID;
  String? imInventoryMovementQuantity;
  String? imInventoryCurrentQuantity;
  String? imInventoryFlowType;
  String? imInventoryFlow;
  String? imStaffID;
  String? imRegistrationDate;

  InventoryMovement({
    this.imId,
    this.imInventoryID,
    this.imInventoryMovementQuantity,
    this.imInventoryCurrentQuantity,
    this.imInventoryFlowType,
    this.imInventoryFlow,
    this.imStaffID,
    this.imRegistrationDate,
  });

  InventoryMovement.fromJson(Map<String, dynamic> json) {
    imId = json['imID'];
    imInventoryID = json['imInventoryID'];
    imInventoryMovementQuantity = json['imInventoryMovementQuantity'];
    imInventoryCurrentQuantity = json['imInventoryCurrentQuantity'];
    imInventoryFlowType = json['imInventoryFlowType'];
    imInventoryFlow = json['imInventoryFlow'];
    imStaffID = json['imStaffID'];
    imRegistrationDate = json['imRegistrationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imID'] = imId;
    data['imInventoryID'] = imInventoryID;
    data['imInventoryMovementQuantity'] = imInventoryMovementQuantity;
    data['imInventoryCurrentQuantity'] = imInventoryCurrentQuantity;
    data['imInventoryFlowType'] = imInventoryFlowType;
    data['imInventoryFlow'] = imInventoryFlow;
    data['imStaffID'] = imStaffID;
    data['imRegistrationDate'] = imRegistrationDate;
    return data;
  }
}
