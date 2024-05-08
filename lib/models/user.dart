class User {
  String? userID;
  String? staffID;
  String? userName;
  String? userEmail;
  String? userPhoneNumber;
  String? userPassword;
  String? userRole;
  String? userStatus;
  String? userRegistrationDate;
  String? userOTP;

  User(
      {this.userID,
      this.staffID,
      this.userName,
      this.userEmail,
      this.userPhoneNumber,
      this.userPassword,
      this.userRole,
      this.userStatus,
      this.userRegistrationDate,
      this.userOTP});

  User.fromJson(Map<String, dynamic> json) {
    userID = json["userID"];
    staffID = json['staffID'];
    userName = json['userName'];
    userEmail = json['userEmail'];
    userPhoneNumber = json['userPhoneNumber'];
    userPassword = json['userPassword'];
    userRole = json['userRole'];
    userStatus = json['userStatus'];
    userRegistrationDate = json['userRegistrationDate'];
    userOTP = json['userOTP'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = userID;
    data['staffID'] = staffID;
    data['userName'] = userName;
    data['userEmail'] = userEmail;
    data['userPhoneNumber'] = userPhoneNumber;
    data['userPassword'] = userPassword;
    data['userRole'] = userRole;
    data['userStatus'] = userStatus;
    data['userRegistrationDate'] = userRegistrationDate;
    data['userOTP'] = userOTP;
    return data;
  }
}
