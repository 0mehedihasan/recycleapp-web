import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recycleapp/pages/onboarding.dart';

void main() async {
  // Ensure Flutter engine is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on platform
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBbjlTT8YALbCnosYGFhL2snM63fgLSVjk",
        authDomain: "recycleapp-4bf0a.firebaseapp.com",
        projectId: "recycleapp-4bf0a",
        storageBucket: "recycleapp-4bf0a.firebasestorage.app",
        messagingSenderId: "183108400733",
        appId: "1:183108400733:web:4d9d5a7c7d7a6a91467fb4",
        measurementId: "G-6E3EN9DPY1",
      ),
    );
  } else {
    // For Android/iOS, Firebase.initializeApp() reads from flutter_firebase.json
    // or GoogleService-Info.plist respectively.
    await Firebase.initializeApp();
  }

  // Run your app, ensuring it starts with MaterialApp
  runApp(
    // MyApp is a common convention for the root widget that returns MaterialApp
    const MyApp(),
  );
}

// Define your root application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Optional: Set a title for your app (used by the OS for task switcher)
      title: 'Recycle App',
      // Optional: Hide the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,
      // The 'home' property defines the initial screen of your app
      home: const Onboarding(), // Your Onboarding screen is now properly nested
    );
  }
}
