import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recycleapp/pages/bottomnav.dart';
import 'package:recycleapp/services/database.dart';
import 'package:recycleapp/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this line
// import 'package:flutter/foundation.dart' show kIsWeb; // Keep if needed for other web-specific logic

class AuthMethods {
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    // Initialize GoogleSignIn.
    // For web, you MUST provide the clientId from your Google Cloud Console
    // for the "Web application" OAuth 2.0 Client ID.
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          '183108400733-ur389c05sr8f8vaavtejfu8qcfjcnpqt.apps.googleusercontent.com',
      scopes: [
        'email',
        'profile',
        'openid', // IMPORTANT: Ensure this scope is requested
      ],
    );

    try {
      print('DEBUG: Starting Google Sign-In flow...');
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        print(
            'DEBUG: Google Sign-In cancelled or failed to get account (googleSignInAccount is null).');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In cancelled.')),
        );
        return;
      }

      print('DEBUG: GoogleSignInAccount obtained: ${googleSignInAccount.displayName}');

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount.authentication;

      print('DEBUG: GoogleSignInAuthentication object: $googleSignInAuthentication');
      if (googleSignInAuthentication != null) {
        print('DEBUG: Access Token available: ${googleSignInAuthentication.accessToken != null}');
        print('DEBUG: ID Token available: ${googleSignInAuthentication.idToken != null}');
        print('DEBUG: Raw Access Token (first 10 chars): ${googleSignInAuthentication.accessToken?.substring(0, 10)}...');
        print('DEBUG: Raw ID Token (first 10 chars): ${googleSignInAuthentication.idToken?.substring(0, 10) ?? 'null'}...');
      } else {
        print('DEBUG: GoogleSignInAuthentication is NULL.');
      }

      if (googleSignInAuthentication == null ||
          googleSignInAuthentication.accessToken == null) {
        print('DEBUG: Google Sign-In: Authentication failed or Access Token is null.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google authentication failed. Missing Access Token.'),
          ),
        );
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      print('DEBUG: Created Firebase credential.');

      UserCredential result = await firebaseAuth.signInWithCredential(
        credential,
      );
      User? userDetails = result.user;

      print('DEBUG: Firebase signInWithCredential result.user: $userDetails');

      if (userDetails == null) {
        print('DEBUG: Firebase sign-in successful, but user details are null (after signInWithCredential).');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to retrieve user details after sign-in.'),
          ),
        );
        return;
      }

      // 1. Save user details to SharedPreferences (always do this on login)
      await SharedpreferenceHelper().saveUserEmail(userDetails.email!);
      await SharedpreferenceHelper().saveUserId(userDetails.uid);
      await SharedpreferenceHelper().saveUserImage(userDetails.photoURL!);
      await SharedpreferenceHelper().saveUserName(userDetails.displayName!);
      print('DEBUG: User details saved to SharedPreferences.');

      // 2. Check if user document already exists in Firestore
      // Use the getUserDocument method from DatabaseMethods
      DocumentSnapshot userDoc = await DatabaseMethods().getUserDocument(userDetails.uid);
      print('DEBUG: Checked user document existence for ${userDetails.uid}. Exists: ${userDoc.exists}');


      if (!userDoc.exists) {
        // User is signing in for the first time or document was deleted
        print('DEBUG: User document does not exist. Creating new user entry with initial points "0".');
        Map<String, dynamic> newUserInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "image": userDetails.photoURL,
          "Id": userDetails.uid,
          "Points": "0", // Initialize points to "0" only for new users
        };
        await DatabaseMethods().addUserInfo(newUserInfoMap, userDetails.uid);
      } else {
        // User document exists, update other profile info but preserve Points
        print('DEBUG: User document exists. Updating non-point user info.');
        Map<String, dynamic> updateInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "image": userDetails.photoURL,
          "Id": userDetails.uid, // Keep ID updated if it somehow changed (unlikely for UID)
        };
        // Use .update() method directly to update specific fields without overwriting others
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userDetails.uid)
            .update(updateInfoMap);
      }

      // 3. Navigate to BottomNav, replacing the current route
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );

      print('DEBUG: Google Sign-In successful. User: ${userDetails.displayName}');
    } on FirebaseAuthException catch (e) {
      print('ERROR: FirebaseAuthException: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error: ${e.message}')),
      );
    } on Exception catch (e) {
      print('ERROR: General Exception during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    // Clear user data from SharedPreferences on sign out
    await SharedpreferenceHelper().saveUserId(''); // Clear User ID
    await SharedpreferenceHelper().saveUserName(''); // Clear User Name
    await SharedpreferenceHelper().saveUserEmail(''); // Clear User Email
    await SharedpreferenceHelper().saveUserImage(''); // Clear User Image
    print('DEBUG: User signed out successfully and SharedPreferences cleared.');
  }

  Future deleteuser(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.delete();
        print('User deleted successfully from Firebase Auth.');
        await GoogleSignIn().signOut();
        // Clear SharedPreferences after deletion
        await SharedpreferenceHelper().saveUserId('');
        await SharedpreferenceHelper().saveUserName('');
        await SharedpreferenceHelper().saveUserEmail('');
        await SharedpreferenceHelper().saveUserImage('');
        print('User deleted and SharedPreferences cleared.');
      } on FirebaseAuthException catch (e) {
        print('Error deleting user: ${e.code} - ${e.message}');
        if (e.code == 'requires-recent-login') {
          print(
              'User requires recent login to delete account. Prompt re-authentication.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please re-authenticate to delete your account.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: ${e.message}')),
          );
        }
      } catch (e) {
        print('An unexpected error occurred during user deletion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred during account deletion.',
            ),
          ),
        );
      }
    } else {
      print('DEBUG: No user is currently signed in to delete.');
    }
  }
}