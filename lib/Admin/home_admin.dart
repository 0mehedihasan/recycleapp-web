import 'package:flutter/material.dart';
import 'package:recycleapp/Admin/admin_approval.dart';
import 'package:recycleapp/Admin/admin_reedem.dart';
import 'package:recycleapp/services/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:recycleapp/pages/login.dart'; // Assuming your login page is here

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  // Function to handle logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the current user
      // Navigate to the login page and remove all previous routes from the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LogIn()), // Replace LogIn with your actual login page widget
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error during logout: $e");
      // Optionally show a message to the user if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to logout. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Home Admin", style: AppWidget.healinetextstyle(30.0)),
              ],
            ),

            SizedBox(height: 20.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Color.fromARGB(255, 233, 233, 249),
                ),
                child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow on smaller screens if more options are added
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminApproval()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0), // Added bottom margin
                          child: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "images/approval.png",
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 50.0),
                                  Text(
                                    "Admin\n Approval",
                                    textAlign: TextAlign.center,
                                    style: AppWidget.healinetextstyle(25.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0), // Reduced spacing slightly
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminReedem()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0), // Added bottom margin
                          child: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "images/reedem.png",
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 50.0),
                                  Text(
                                    "Reedem\n Request",
                                    textAlign: TextAlign.center,
                                    style: AppWidget.healinetextstyle(25.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0), // Spacing before the new logout button
                      // New Logout Button
                      GestureDetector(
                        onTap: _logout, // Call the logout function
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon( // Replaced Image.asset with Icon
                                    Icons.logout, // Using a default logout icon from Material Design
                                    size: 100, // Adjusted size to match original image height/width
                                    color: Colors.red, // Example color for logout icon
                                  ),
                                  SizedBox(width: 50.0),
                                  Text(
                                    "Logout",
                                    textAlign: TextAlign.center,
                                    style: AppWidget.healinetextstyle(25.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
