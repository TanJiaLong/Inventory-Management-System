import 'package:flutter/material.dart';
import 'package:ims/models/user.dart';
import 'package:ims/screens/authentication/loginscreen.dart';
import 'package:ims/screens/shared/displayinventoryqr.dart';
import 'package:ims/screens/shared/profile/managestaffscreen.dart';
import 'package:ims/screens/shared/profile/updateprofilescreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double sWidth, sHeight, textSize;
  late User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width;
    sHeight = MediaQuery.of(context).size.height;
    textSize = sWidth * 0.04;

    return Scaffold(
      body: SizedBox(
        width: sWidth,
        height: sHeight,
        child: Container(
          padding: EdgeInsets.all(textSize * 1.25).copyWith(bottom: 0),
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: SizedBox(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(textSize * 0.625),
                          child: const Image(
                            image: AssetImage('assets/images/profileIcon.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: textSize,
                      ),
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello",
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                              ),
                            ),
                            Text(
                              user.userName.toString(),
                              style: TextStyle(
                                fontSize: textSize * 1.5,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              "${user.staffID} (${user.userRole})",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: textSize,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact Information",
                      style: TextStyle(
                        fontSize: textSize * 2,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                    Expanded(
                      child: Container(
                        width: sWidth,
                        padding: EdgeInsets.all(textSize / 2)
                            .copyWith(left: textSize * 0.875),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email:",
                              style: TextStyle(
                                  fontSize: textSize * 1.75,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              user.userEmail.toString(),
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(
                              height: textSize,
                            ),
                            Text(
                              "Phone Number:",
                              style: TextStyle(
                                  fontSize: textSize * 1.75,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              user.userPhoneNumber.toString(),
                              style: TextStyle(
                                fontSize: textSize * 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: SizedBox(
                  width: sWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Admin only
                      if (user.userRole == "Employer" ||
                          user.userRole == "Inventory Manager")
                        Column(
                          children: [
                            const Divider(
                              thickness: 1,
                              height: 0,
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ManageStaffScreen(currentUser: user),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: sWidth,
                                height: sHeight * 0.075,
                                child: Text(
                                  "Manage Staff",
                                  style: TextStyle(
                                      fontSize: textSize * 1.25,
                                      fontWeight: FontWeight.w900,
                                      overflow: TextOverflow.visible),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const Divider(
                        thickness: 1,
                        height: 0,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          User? updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProfileScreen(
                                currentUser: user,
                              ),
                            ),
                          );

                          if (updatedUser == null) {
                            return;
                          }
                          user.userName = updatedUser.userName;
                          user.userEmail = updatedUser.userEmail;
                          user.userPhoneNumber = updatedUser.userPhoneNumber;
                          user.userPassword = updatedUser.userPassword;

                          setState(() {});
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: sWidth,
                          height: sHeight * 0.075,
                          child: Text(
                            "Update Profile",
                            style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.visible),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        height: 0,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DisplayInventoryQRScreen(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: sWidth,
                          height: sHeight * 0.075,
                          child: Text(
                            "Display Inventory QR",
                            style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.visible),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        height: 0,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: sWidth,
                          height: sHeight * 0.075,
                          child: Text(
                            "Sign Out",
                            style: TextStyle(
                                fontSize: textSize * 1.25,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.visible),
                          ),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        height: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
