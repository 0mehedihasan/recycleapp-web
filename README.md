# RecycleApp

A mobile application built with Flutter and Firebase that aims to promote recycling by allowing users to upload recyclable items, earn points, and track their progress. This app includes features for both regular users and admin access, including item uploads, points tracking, and administrative controls for approval and management.

## Features

- **Onboarding**: Provides a seamless introduction to the app for first-time users.
- **Authentication**: Sign up, login, and user profile management with Firebase Authentication.
- **Points System**: Users can upload recyclable items and earn points.
- **Admin Panel**: Admins can approve or reject uploaded items and manage user points.
- **Bottom Navigation Bar**: Easy access to the Home, Points, and Profile screens for the user.
- **Firebase Integration**: Real-time database to track user points, uploaded items, and authentication.

## Screenshots

![Home Screen](assets/images/home_screen.png)
![Profile Screen](assets/images/profile_screen.png)

## Tech Stack

- **Flutter**: Framework used to build the app's UI and logic.
- **Firebase**: Used for authentication, database, and storage.
- **Provider**: State management for handling app-wide state.
- **Curved Navigation Bar**: Custom navigation bar for a better user experience.
  
## Getting Started

### Prerequisites

- Flutter SDK
- Firebase Project

### Setup

1. **Clone the Repository**  
   First, clone this repository to your local machine:
   ```bash
   git clone https://github.com/0mehedihasan/recycleapp.git
   cd recycleapp

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Login.dart ( Both User and Admin ) 
```login
import 'package:flutter/material.dart';
import 'package:recycleapp/services/auth.dart';
import 'package:recycleapp/services/widget_support.dart';
import 'package:recycleapp/Admin/admin_login.dart'; // ✅ Admin Login import

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            SizedBox(height: 20.0),
            Image.asset("images/recycle1.png",
                height: 120, width: 120, fit: BoxFit.cover),
            SizedBox(height: 20.0),
            Text("Reduce. Reuse. Recycle.",
                style: AppWidget.healinetextstyle(25.0)),
            Text("Repeat!", style: AppWidget.greentextstyle(32.0)),
            SizedBox(height: 80.0),
            Text(
              "Every item you recycle\nmakes a difference!",
              textAlign: TextAlign.center,
              style: AppWidget.normaltextstyle(20.0),
            ),
            Text("Get Started!", style: AppWidget.greentextstyle(24.0)),
            SizedBox(height: 30.0),

            /// ✅ Google Sign-In Button
            GestureDetector(
              onTap: () {
                AuthMethods().signInWithGoogle(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
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
                        SizedBox(width: 20.0),
                        Text("Sign in with Google",
                            style: AppWidget.whitetextstyle(25.0)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// ✅ Admin Login Button (Styled like Google Sign-In)
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLogin()),
                );
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.black,
                            size: 50,
                          ),
                        ),
                        SizedBox(width: 20.0),
                        Text("Admin Login",
                            style: AppWidget.whitetextstyle(25.0)),
                      ],
                    ),
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

```

```
import 'package:flutter/material.dart';
import 'package:recycleapp/services/auth.dart';
import 'package:recycleapp/services/widget_support.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            SizedBox(height: 20.0,),
            Image.asset("images/recycle1.png", height: 120, width: 120, fit: BoxFit.cover,),
               SizedBox(height: 20.0,),
            Text("Reduce. Reuse. Recycle.", style: AppWidget.healinetextstyle(25.0),),
            Text("Repeat!", style:AppWidget.greentextstyle(32.0) ,),
               SizedBox(height: 80.0,),
            Text("Every item you recycle\nmakes a difference!",textAlign: TextAlign.center, style: AppWidget.normaltextstyle(20.0),),
            Text("Get Started!", style: AppWidget.greentextstyle(24.0),),
            SizedBox(height: 30.0,),
            GestureDetector(
              onTap: (){
                AuthMethods().signInWithGoogle(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    
                       height: 80,
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      Container(
                     
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(60)),
                        child: Image.asset("images/google.png", height: 50, width: 50, fit: BoxFit.cover,)),
                        SizedBox(width: 20.0,),
                        Text("Sign in with Google", style: AppWidget.whitetextstyle(25.0),)
                    ],),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
```

