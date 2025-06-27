import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:recycleapp/services/database.dart';
import 'package:recycleapp/services/widget_support.dart';

class AdminApproval extends StatefulWidget {
  const AdminApproval({super.key});

  @override
  State<AdminApproval> createState() => _AdminApprovalState();
}

class _AdminApprovalState extends State<AdminApproval>
    with SingleTickerProviderStateMixin {
  Stream? approvalStream; // Stream for admin's pending *item* requests
  Stream? approvedHistoryStream; // NEW Stream for approved items history

  late TabController _tabController; // Controller for the TabBar

  // Define the conversion rate
  static const double pointsToBdtRate = 0.5; // 1 point = 0.5 BDT

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 2 tabs: Pending, History
    getontheload();
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the tab controller
    super.dispose();
  }

  getontheload() async {
    print("AdminApproval: Fetching pending item requests...");
    approvalStream = await DatabaseMethods().getAdminApproval();
    print("AdminApproval: Fetching approved items history...");
    approvedHistoryStream =
        await DatabaseMethods().getApprovedItemsHistory(); // NEW
    setState(() {});
  }

  // Helper function to calculate points based on category and quantity
  int _calculatePoints(String category, String quantityStr) {
    int basePointsPerUnit = 0;
    switch (category) {
      case "Plastic":
        basePointsPerUnit = 50; // Points per unit/kg of Plastic
        break;
      case "Paper":
        basePointsPerUnit = 30; // Points per unit/kg of Paper
        break;
      case "Glass":
        basePointsPerUnit = 40; // Points per unit/kg of Glass
        break;
      case "Battery":
        basePointsPerUnit = 70; // Points per unit/kg of Battery
        break;
      default:
        basePointsPerUnit = 20; // Default points per unit/kg
        print(
          "AdminApproval: Unknown category '$category', assigning default 20 points per unit.",
        );
        break;
    }

    // Safely parse quantity. Default to 0.0 if not a valid number.
    double quantity = double.tryParse(quantityStr) ?? 0.0;
    if (quantity < 0) quantity = 0.0; // Ensure quantity is not negative

    // Calculate total points and round to the nearest integer
    return (basePointsPerUnit * quantity).round();
  }

  // Fetches a user's current points as a string from their user document
  Future<String> getUserPoints(String docId) async {
    try {
      print("AdminApproval: Attempting to get points for userId: $docId");
      DocumentSnapshot docSnapshot = await DatabaseMethods().getUserDocument(
        docId,
      );

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        var points = data['Points'];
        String pointsStr = points?.toString() ?? '0';
        print("AdminApproval: Found points for $docId: '$pointsStr'");
        return pointsStr;
      } else {
        print(
          "AdminApproval: User document not found for $docId. Returning '0'.",
        );
        return '0';
      }
    } catch (e) {
      print('AdminApproval: Error fetching user points for $docId: $e');
      return '0';
    }
  }

  // Widget to display all pending item approval requests for the admin
  Widget allApprovals() {
    return StreamBuilder(
      stream: approvalStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("AdminApproval: StreamBuilder connectionState: waiting");
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("AdminApproval: StreamBuilder hasError: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          print("AdminApproval: No pending item requests found.");
          return Center(
            child: Text(
              "No pending item requests.",
              style: AppWidget.normaltextstyle(18.0),
            ),
          );
        }

        print(
          "AdminApproval: StreamBuilder hasData, displaying ${snapshot.data.docs.length} requests.",
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            print(
              "AdminApproval: Processing request ID: ${ds.id}, UserID: ${ds["UserId"]}",
            );

            String userId = ds["UserId"];
            String requestId = ds.id;
            String userName = ds["Name"] ?? "Unknown User";
            String itemCategory = ds["Category"] ?? "Unknown";
            String itemQuantity = ds["Quantity"] ?? "N/A";
            String phoneNumber =
                ds["PhoneNumber"] ?? "N/A"; // Get the phone number

            // Calculate points and BDT equivalent to display using the helper
            int estimatedPoints = _calculatePoints(itemCategory, itemQuantity);
            double estimatedBdtEquivalent = estimatedPoints * pointsToBdtRate;

            return Container(
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 20.0,
              ),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          "images/coca.png", // Generic image for now, ensure path is correct
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.green,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    userName,
                                    style: AppWidget.normaltextstyle(20.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    ds["Address"] ?? "N/A",
                                    style: AppWidget.normaltextstyle(20.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // NEW: Phone Number Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone, // Phone icon
                                  color: Colors.green,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    "Phone: $phoneNumber",
                                    style: AppWidget.normaltextstyle(20.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.category,
                                  color: Colors.green,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    "Category: $itemCategory",
                                    style: AppWidget.normaltextstyle(20.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.line_weight,
                                  color: Colors.green,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    "Quantity: $itemQuantity",
                                    style: AppWidget.normaltextstyle(20.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.orange,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Text(
                                    "Est. Points: ${estimatedPoints} (${estimatedBdtEquivalent.toStringAsFixed(1)} BDT)",
                                    style: AppWidget.normaltextstyle(
                                      20.0,
                                    ).copyWith(color: Colors.deepOrange),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            GestureDetector(
                              onTap: () async {
                                print(
                                  "AdminApproval: Approve button tapped for UserID: $userId, RequestID: $requestId",
                                );
                                print(
                                  "AdminApproval: Item Category: '$itemCategory', Quantity: '$itemQuantity'",
                                );

                                String userPointsStr = await getUserPoints(
                                  userId,
                                );
                                int currentUserPoints =
                                    int.tryParse(userPointsStr) ?? 0;
                                print(
                                  "AdminApproval: Current user points for $userId: $currentUserPoints",
                                );

                                // Re-calculate pointsToAdd for approval using the helper
                                int pointsToAdd = _calculatePoints(
                                  itemCategory,
                                  itemQuantity,
                                );

                                print(
                                  "AdminApproval: Points to add for '$itemCategory' with quantity '$itemQuantity': $pointsToAdd",
                                );

                                int updatedPointsInt =
                                    currentUserPoints + pointsToAdd;
                                String updatedPointsString =
                                    updatedPointsInt.toString();

                                print(
                                  "AdminApproval: New user total points after addition: $updatedPointsInt",
                                );

                                try {
                                  await DatabaseMethods().updateUserPoints(
                                    userId,
                                    updatedPointsString,
                                  );
                                  print(
                                    "AdminApproval: Successfully updated user $userId's total points in Firestore.",
                                  );

                                  await DatabaseMethods().updateAdminRequest(
                                    requestId,
                                  );
                                  print(
                                    "AdminApproval: Successfully updated admin request status for $requestId.",
                                  );

                                  await DatabaseMethods().updateUserRequest(
                                    userId,
                                    requestId,
                                  );
                                  print(
                                    "AdminApproval: Successfully updated user $userId's item request status for $requestId in user's Items.",
                                  );

                                  double bdtEquivalent =
                                      pointsToAdd * pointsToBdtRate;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Recycling request approved for ${userName}. '
                                        '${pointsToAdd} points added (Approx. ${bdtEquivalent.toStringAsFixed(1)} BDT).',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  print(
                                    "AdminApproval: Error during approval process: $e",
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error approving recycling request: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Approve",
                                    style: AppWidget.whitetextstyle(20.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget to display all approved items history
  Widget allApprovedItems() {
    return StreamBuilder(
      stream: approvedHistoryStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
            "AdminApproval: StreamBuilder (Approved) connectionState: waiting",
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
            "AdminApproval: StreamBuilder (Approved) hasError: ${snapshot.error}",
          );
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          print(
            "AdminApproval: No approved items in history found or snapshot is empty.",
          );
          return Center(
            child: Text(
              "No approved items in history.",
              style: AppWidget.normaltextstyle(18.0),
            ),
          );
        }

        print(
          "AdminApproval: StreamBuilder (Approved) hasData, total docs received: ${snapshot.data.docs.length}",
        );
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          DocumentSnapshot doc = snapshot.data.docs[i];
          print(
            "   Doc ${i + 1}: ID=${doc.id}, Name=${doc['Name']}, Status=${doc['Status']}, ApprovedAt=${(doc['ApprovedAt'] as Timestamp?)?.toDate()}",
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            String userName = ds["Name"] ?? "Unknown User";
            String itemCategory = ds["Category"] ?? "Unknown";
            String itemQuantity = ds["Quantity"] ?? "N/A";
            String phoneNumber =
                ds["PhoneNumber"] ?? "N/A"; // Get the phone number
            Timestamp? approvedTimestamp = ds["ApprovedAt"];

            String approvedDate = "N/A";
            if (approvedTimestamp != null) {
              final dateTime = approvedTimestamp.toDate();
              approvedDate = DateFormat('dd MMM, hh:mm a').format(dateTime);
            }

            // Calculate points and BDT equivalent for display in history using the helper
            int awardedPoints = _calculatePoints(itemCategory, itemQuantity);
            double awardedBdtEquivalent = awardedPoints * pointsToBdtRate;

            return Container(
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 20.0,
              ),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          "images/coca.png", // Generic image for now
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "User: $userName",
                              style: AppWidget.normaltextstyle(18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // NEW: Phone Number Row for history
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone, // Phone icon
                                  color: Colors.green,
                                  size: 20.0, // Smaller icon for history list
                                ),
                                const SizedBox(width: 5.0),
                                Expanded(
                                  child: Text(
                                    "Phone: $phoneNumber",
                                    style: AppWidget.normaltextstyle(16.0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Category: $itemCategory",
                              style: AppWidget.normaltextstyle(16.0),
                            ),
                            Text(
                              "Quantity: $itemQuantity",
                              style: AppWidget.normaltextstyle(16.0),
                            ),
                            Text(
                              "Awarded: ${awardedPoints} points (${awardedBdtEquivalent.toStringAsFixed(1)} BDT)",
                              style: AppWidget.normaltextstyle(
                                16.0,
                              ).copyWith(color: Colors.green.shade700),
                            ),
                            Text(
                              "Approved On: $approvedDate",
                              style: AppWidget.normaltextstyle(
                                14.0,
                              ).copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 7),
                  Text(
                    "Admin Approval",
                    style: AppWidget.healinetextstyle(25.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // NEW: TabBar for switching between Pending and History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: AppWidget.normaltextstyle(18.0),
                tabs: const [Tab(text: "Pending"), Tab(text: "History")],
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Pending Approvals
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Color.fromARGB(255, 233, 233, 249),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),
                        Expanded(
                          child:
                              allApprovals(), // Displays pending item approval requests
                        ),
                      ],
                    ),
                  ),
                  // Tab 2: Approved History
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Color.fromARGB(255, 233, 233, 249),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),
                        Expanded(
                          child:
                              allApprovedItems(), // Displays approved items history
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
