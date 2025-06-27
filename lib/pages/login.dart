import 'package:flutter/material.dart';
import 'package:recycleapp/services/auth.dart';
import 'package:recycleapp/services/widget_support.dart';
import 'package:recycleapp/Admin/admin_login.dart'; // Admin Login import

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // <-- FIX: Wrap with SingleChildScrollView for overflow
        child: Column(
          children: [
            Center(
              child: Image.asset(
                "images/login.png",
                height: 300,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20.0), // Added const
            Image.asset(
              "images/recycle1.png",
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20.0), // Added const
            Text(
              "Reduce. Reuse. Recycle.",
              style: AppWidget.healinetextstyle(25.0),
            ),
            Text("Repeat!", style: AppWidget.greentextstyle(32.0)),
            const SizedBox(height: 80.0), // Added const
            Text(
              "Every item you recycle\nmakes a difference!",
              textAlign: TextAlign.center,
              style: AppWidget.normaltextstyle(20.0),
            ),
            Text("Get Started!", style: AppWidget.greentextstyle(24.0)),
            const SizedBox(height: 30.0), // Added const
            /// Google Sign-In Button
            GestureDetector(
              onTap: () {
                AuthMethods().signInWithGoogle(context);
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0),
                    height: 80,
                    width:
                        MediaQuery.of(
                          context,
                        ).size.width, // Ensure it takes full width
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Image.asset(
                            "images/google.png",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Text(
                          "Sign in with Google",
                          style: AppWidget.whitetextstyle(25.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// Admin Login Button
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLogin()),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0),
                    height: 80,
                    width:
                        MediaQuery.of(
                          context,
                        ).size.width, // Ensure it takes full width
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      // <-- FIX: Removed 'const' here
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            // Added const where possible
                            Icons.admin_panel_settings,
                            color: Colors.black,
                            size: 50,
                          ),
                        ),
                        const SizedBox(width: 20.0), // Added const
                        const Text(
                          // Added const
                          "Admin Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40.0,
            ), // Added some extra padding at the bottom
          ],
        ),
      ),
    );
  }
}
