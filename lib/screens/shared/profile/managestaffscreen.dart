import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ims/configs/myconfig.dart';
import 'package:ims/models/user.dart';
import 'package:http/http.dart' as http;

class ManageStaffScreen extends StatefulWidget {
  final User currentUser;
  const ManageStaffScreen({super.key, required this.currentUser});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  late double sWidth, sHeight, textSize;
  final UniqueKey _pendingTileKey = UniqueKey();
  final UniqueKey _userTileKey = UniqueKey();
  final UniqueKey _unverifiedTileKey = UniqueKey();
  final UniqueKey _rejectedTileKey = UniqueKey();

  final List<User> _pendingUserList = [];
  final List<User> _userList = [];
  final List<User> _unverifiedUserList = [];
  final List<User> _rejectedUserList = [];

  bool _isDataAvailable = false;
  bool _isPLExpand = true;
  bool _isULExpand = true;
  bool _isUULExpand = true;
  bool _isRUExpand = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Staff",
          style: TextStyle(
              color: Colors.black,
              fontSize: textSize * 1.25,
              fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SizedBox(
        width: sWidth,
        height: sHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Divider(color: Colors.black, height: 0),
              ExpansionTile(
                onExpansionChanged: (isExpand) {
                  setState(() {
                    _isULExpand = isExpand;
                  });
                },
                key: PageStorageKey(_userTileKey),
                initiallyExpanded: true,
                trailing: _isULExpand
                    ? Icon(Icons.arrow_drop_down_sharp,
                        color: Colors.black, size: textSize * 1.875)
                    : Icon(Icons.arrow_drop_up_sharp,
                        color: Colors.black, size: textSize * 1.875),
                title: Text(
                  "Active/Inactive User",
                  style: TextStyle(
                      fontSize: textSize * 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
                children: _userList.map(
                  (user) {
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            showUserDialog(user);
                          },
                          title: Text(
                            "${user.staffID.toString()} (${user.userName.toString()})",
                            style: TextStyle(
                              fontSize: textSize * 1.25,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                          subtitle: Text(
                            "Registration Date: ${user.userRegistrationDate}",
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                          trailing: Text(
                            user.userStatus.toString(),
                            style: TextStyle(
                              fontSize: textSize * 1.5,
                              fontWeight: FontWeight.bold,
                              color: user.userStatus == "Active"
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
              const Divider(color: Colors.black, height: 0),
              if (_pendingUserList.isNotEmpty)
                ExpansionTile(
                  onExpansionChanged: (isExpand) {
                    setState(() {
                      _isPLExpand = isExpand;
                    });
                  },
                  key: PageStorageKey(_pendingTileKey),
                  initiallyExpanded: true,
                  trailing: _isPLExpand
                      ? Icon(Icons.arrow_drop_down_sharp,
                          color: Colors.black, size: textSize * 1.875)
                      : Icon(Icons.arrow_drop_up_sharp,
                          color: Colors.black, size: textSize * 1.875),
                  title: Text(
                    "Pending User",
                    style: TextStyle(
                        fontSize: textSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  children: _pendingUserList.map(
                    (pendingUser) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              showUserDialog(pendingUser);
                            },
                            title: Text(
                              "${pendingUser.staffID.toString()} (${pendingUser.userName.toString()})",
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            subtitle: Text(
                              "Registration Date: ${pendingUser.userRegistrationDate}",
                              maxLines: 2,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    approveUserDialog(pendingUser);
                                  },
                                  icon: const CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 212, 0),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    rejectUserDialog(pendingUser);
                                  },
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              const Divider(color: Colors.black, height: 0),
              if (_unverifiedUserList.isNotEmpty)
                ExpansionTile(
                  onExpansionChanged: (isExpand) {
                    setState(() {
                      _isUULExpand = isExpand;
                    });
                  },
                  key: PageStorageKey(_unverifiedTileKey),
                  initiallyExpanded: true,
                  trailing: _isUULExpand
                      ? Icon(Icons.arrow_drop_down_sharp,
                          color: Colors.black, size: textSize * 1.875)
                      : Icon(Icons.arrow_drop_up_sharp,
                          color: Colors.black, size: textSize * 1.875),
                  title: Text(
                    "Unverified User",
                    style: TextStyle(
                        fontSize: textSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  children: _unverifiedUserList.map(
                    (unverifiedUser) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              showUserDialog(unverifiedUser);
                            },
                            title: Text(
                              "${unverifiedUser.staffID.toString()} (${unverifiedUser.userName.toString()})",
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            subtitle: Text(
                              "Registration Date: ${unverifiedUser.userRegistrationDate}",
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    approveUserDialog(unverifiedUser);
                                  },
                                  icon: const CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 212, 0),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    rejectUserDialog(unverifiedUser);
                                  },
                                  icon: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              const Divider(color: Colors.black, height: 0),
              if (_rejectedUserList.isNotEmpty)
                ExpansionTile(
                  onExpansionChanged: (isExpand) {
                    setState(() {
                      _isRUExpand = isExpand;
                    });
                  },
                  key: PageStorageKey(_rejectedTileKey),
                  initiallyExpanded: true,
                  trailing: _isRUExpand
                      ? Icon(Icons.arrow_drop_down_sharp,
                          color: Colors.black, size: textSize * 1.875)
                      : Icon(Icons.arrow_drop_up_sharp,
                          color: Colors.black, size: textSize * 1.875),
                  title: Text(
                    "Rejected User",
                    style: TextStyle(
                        fontSize: textSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  children: _rejectedUserList.map(
                    (rejectedUser) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              showUserDialog(rejectedUser);
                            },
                            onLongPress: () {
                              approveUserDialog(rejectedUser);
                            },
                            title: Text(
                              "${rejectedUser.staffID.toString()} (${rejectedUser.userName.toString()})",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            subtitle: Text(
                              "Registration Date: ${rejectedUser.userRegistrationDate}",
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "Rejected",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              const Divider(color: Colors.black, height: 0),
            ],
          ),
        ),
      ),
    );
  }

  void loadUsers() {
    http.post(
      Uri.parse(
        "${MyConfig.server}/ims/php/user/load_user.php",
      ),
      body: {},
    ).then(
      (response) {
        if (response.statusCode == 200) {
          log(response.body);
          var jsonData = jsonDecode(response.body);

          if (jsonData['status'] == "success") {
            var extractUsers = jsonData['data'];
            extractUsers['users'].forEach(
              (user) {
                User currentUser = User.fromJson(user);
                if (currentUser.userStatus == "Pending") {
                  _pendingUserList.add(currentUser);
                } else if (currentUser.userStatus == "Active" ||
                    currentUser.userStatus == "Inactive") {
                  _userList.add(currentUser);
                } else if (currentUser.userStatus == "Unverified") {
                  _unverifiedUserList.add(currentUser);
                } else if (currentUser.userStatus == "Rejected") {
                  _rejectedUserList.add(currentUser);
                }
              },
            );
            setState(() {
              _isDataAvailable = true;
            });
          } else {
            _isDataAvailable = false;
          }
        } else {
          _isDataAvailable = false;
        }
      },
    );
  }

  void showUserDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24,
          title: Text(
            "${user.staffID} (${user.userName})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Email:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                user.userEmail.toString(),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "Phone:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(user.userPhoneNumber.toString()),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "User Role:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(user.userRole.toString()),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "Registration Date:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(user.userRegistrationDate.toString()),
            ],
          ),
        );
      },
    );
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void rejectUserDialog(User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Reject ${user.userName}?",
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  rejectUser(user);
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
            ],
          );
        });
  }

  void rejectUser(User user) {
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/reject_staff.php"),
      body: {
        "staffID": user.staffID.toString(),
        "userEmail": user.userEmail.toString(),
        "userName": user.userName.toString(),
      },
    ).then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("${user.userName} Rejected");

          _isDataAvailable = false;
          _userList.clear();
          _pendingUserList.clear();
          _unverifiedUserList.clear();
          _rejectedUserList.clear();
          loadUsers();
        } else {
          showToastMessage("Something went wrong - SQL");
        }
      } else {
        showToastMessage("Something went wrong - HTTP");
      }
    });
  }

  void approveUserDialog(User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Approve ${user.userName}?",
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  approveUser(user);
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
            ],
          );
        });
  }

  void approveUser(User user) {
    http.post(
      Uri.parse("${MyConfig.server}/ims/php/user/approve_staff.php"),
      body: {
        "staffID": user.staffID.toString(),
        "userEmail": user.userEmail.toString(),
        "userName": user.userName.toString(),
      },
    ).then((response) {
      if (response.statusCode == 200) {
        log(response.body);
        dynamic jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          showToastMessage("${user.userName} approved");

          _isDataAvailable = false;
          _userList.clear();
          _pendingUserList.clear();
          _unverifiedUserList.clear();
          _rejectedUserList.clear();
          loadUsers();
        } else {
          showToastMessage("Something went wrong - SQL");
        }
      } else {
        showToastMessage("Something went wrong - HTTP");
      }
    });
  }
}
