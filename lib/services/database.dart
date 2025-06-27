import 'package:cloud_firestore/cloud_firestore.dart';

/// Class to handle all database interactions with Firestore.
class DatabaseMethods {
  /// Adds user information to the "users" collection with a specific [id].
  Future addUserInfo(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  /// Adds an item uploaded by the user to their "Items" subcollection.
  Future addUserUploadItem(
    Map<String, dynamic> userInfoMap,
    String id,
    String itemid,
  ) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Items")
        .doc(itemid)
        .set(userInfoMap);
  }

  /// Adds a new item request to the "Requests" collection for admin approval.
  Future addAdminItem(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Requests")
        .doc(id)
        .set(userInfoMap);
  }

  /// Retrieves a stream of all pending item requests for the admin.
  Future<Stream<QuerySnapshot>> getAdminApproval() async {
    return FirebaseFirestore.instance
        .collection("Requests")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  /// Retrieves a stream of all pending item requests by a specific user.
  Future<Stream<QuerySnapshot>> getUserPendingRequests(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Items")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  /// Retrieves a stream of all pending redeem requests for admin review.
  Future<Stream<QuerySnapshot>> getAdminReedemApproval() async {
    return FirebaseFirestore.instance
        .collection("Reedem")
        .where("Status", isEqualTo: "Pending")
        .snapshots();
  }

  /// Retrieves a stream of all redeem transactions for a specific user.
  Future<Stream<QuerySnapshot>> getUserTransactions(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Reedem")
        .snapshots();
  }

  /// Updates the status of a specific admin item request to "Approved".
  Future updateAdminRequest(String id) async {
    print(
      "DatabaseMethods: Updating admin request ID: $id to Approved and adding ApprovedAt timestamp.",
    );
    return await FirebaseFirestore.instance
        .collection("Requests")
        .doc(id)
        .update({"Status": "Approved", "ApprovedAt": Timestamp.now()});
  }

  /// Updates the status of a specific user's item request to "Approved".
  Future updateUserRequest(String id, String itemid) async {
    print(
      "DatabaseMethods: Updating user $id's item $itemid to Approved and adding ApprovedAt timestamp.",
    );
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Items")
        .doc(itemid)
        .update({"Status": "Approved", "ApprovedAt": Timestamp.now()});
  }

  /// Updates the status of a specific admin redeem request to "Approved".
  // MODIFIED: Added RedeemedAt: Timestamp.now()
  Future updateAdminReedemRequest(String id) async {
    print(
      "DatabaseMethods: Updating admin redeem request ID: $id to Approved and adding RedeemedAt timestamp.",
    );
    return await FirebaseFirestore.instance.collection("Reedem").doc(id).update(
      {"Status": "Approved", "RedeemedAt": Timestamp.now()},
    );
  }

  /// Updates the status of a specific user's redeem request to "Approved".
  // MODIFIED: Added RedeemedAt: Timestamp.now()
  Future updateUserReedemRequest(String id, String itemid) async {
    print(
      "DatabaseMethods: Updating user $id's redeem item $itemid to Approved and adding RedeemedAt timestamp.",
    );
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Reedem")
        .doc(itemid)
        .update({"Status": "Approved", "RedeemedAt": Timestamp.now()});
  }

  /// Adds a new redeem transaction under a user's "Reedem" subcollection.
  Future addUserReedemPoints(
    Map<String, dynamic> userInfoMap,
    String id,
    String reedemid,
  ) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Reedem")
        .doc(reedemid)
        .set(userInfoMap);
  }

  /// Adds a new redeem request to the "Reedem" collection for admin processing.
  Future addAdminReedemRequests(
    Map<String, dynamic> userInfoMap,
    String reedemid,
  ) async {
    return await FirebaseFirestore.instance
        .collection("Reedem")
        .doc(reedemid)
        .set(userInfoMap);
  }

  // Update user's points (accepts String as per your Firestore structure)
  Future<void> updateUserPoints(String userId, String newPoints) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'Points': newPoints, // Store as a string
      });
      print(
        "DatabaseMethods: Successfully updated user $userId points to '$newPoints'",
      );
    } catch (e) {
      print("DatabaseMethods: Error updating user points for $userId: $e");
    }
  }

  /// Retrieves a single user document by their ID.
  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  // Method to get approved item requests for history
  Future<Stream<QuerySnapshot>> getApprovedItemsHistory() async {
    return FirebaseFirestore.instance
        .collection("Requests")
        .where("Status", isEqualTo: "Approved")
        .orderBy("ApprovedAt", descending: true)
        .snapshots();
  }

  // NEW METHOD: To get approved redeem requests for history
  Future<Stream<QuerySnapshot>> getApprovedRedeemHistory() async {
    return FirebaseFirestore.instance
        .collection(
          "Reedem",
        ) // Note: This is "Reedem" as per your existing code
        .where("Status", isEqualTo: "Approved")
        .orderBy("RedeemedAt", descending: true) // Will require an index!
        .snapshots();
  }
}
