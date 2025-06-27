import 'package:flutter/material.dart';
import 'package:recycleapp/pages/login.dart';
import 'package:recycleapp/services/widget_support.dart'; // Make sure this path is correct

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Wrap the Column with SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add some initial spacing from the top
            SizedBox(height: 50.0),

            // Onboarding image
            Image.asset("images/onboard.png"),

            // Spacing after image
            SizedBox(height: 50.0),

            // Main headline text
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                // Use Align to push text to the left if needed
                alignment:
                    Alignment.centerLeft, // Align left within its padding
                child: Text(
                  "Recycle your waste products!",
                  style: AppWidget.healinetextstyle(32.0),
                ),
              ),
            ),

            // Spacing
            SizedBox(height: 30.0),

            // Sub-headline text
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Align(
                // Use Align to push text to the left if needed
                alignment:
                    Alignment.centerLeft, // Align left within its padding
                child: Text(
                  "Easily collect household waste and generate less waste",
                  style: AppWidget.normaltextstyle(18.0),
                ),
              ),
            ),

            // Flexible spacing to push the button towards the bottom if space allows
            // This is an alternative to a fixed SizedBox height, especially useful
            // if you want the button to generally be at the bottom but still scroll
            // if content above is too large.
            // Using a fixed SizedBox(height: 90.0) is also fine if that's the desired gap.
            // If the goal is for the button to be at the very bottom of the view,
            // even after scrolling, you'd put the button outside the SingleChildScrollView
            // and use a Stack or similar layout, but for simple scrolling,
            // keeping it inside and using a large SizedBox before it is common.
            SizedBox(height: 90.0),

            // Get Started Button
            GestureDetector(
              onTap: () {
                // The context here is valid because Onboarding is a child of MaterialApp's home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                );
              },
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width / 1.5,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: AppWidget.whitetextstyle(24.0),
                    ),
                  ),
                ),
              ),
            ),

            // Optional: Add some padding at the bottom of the scroll view
            // to ensure content isn't cut off right at the edge.
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
