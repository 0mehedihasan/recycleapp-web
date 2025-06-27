// Import necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:recycleapp/services/database.dart'; // Custom service to interact with Firestore
import 'package:recycleapp/services/widget_support.dart'; // Custom widget styling utilities

// AdminReedem is a StatefulWidget responsible for displaying redeem requests for admin approval
class AdminReedem extends StatefulWidget {
  const AdminReedem({super.key});

  @override
  State<AdminReedem> createState() => _AdminReedemState();
}

class _AdminReedemState extends State<AdminReedem>
    with SingleTickerProviderStateMixin {
  Stream? redeemStream; // Holds the stream of pending redeem requests
  Stream?
  redeemedHistoryStream; // NEW: Holds the stream of approved redeem requests history

  late TabController _tabController; // Controller for the TabBar

  // Define the conversion rate
  static const double pointsToBdtRate = 0.5; // 1 point = 0.5 BDT

  // Loads redeem request stream from Firestore on initialization
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 2 tabs: Pending, History
    getontheload(); // Called once when the widget is inserted into the widget tree
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the tab controller
    super.dispose();
  }

  getontheload() async {
    print("AdminReedem: Fetching pending redeem requests...");
    redeemStream =
        await DatabaseMethods()
            .getAdminReedemApproval(); // Fetch redeem requests needing approval
    print("AdminReedem: Fetching approved redeem history..."); // NEW
    redeemedHistoryStream =
        await DatabaseMethods().getApprovedRedeemHistory(); // NEW
    setState(() {}); // Refresh UI after loading data
  }

  // Fetches a user's current points as a string from their main user document
  // This method is needed to get the user's total points before subtracting
  Future<String> getUserPoints(String docId) async {
    try {
      print("AdminReedem: Attempting to get points for userId: $docId");
      DocumentSnapshot docSnapshot = await DatabaseMethods().getUserDocument(
        docId,
      ); // Re-using existing method

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        var points = data['Points'];
        String pointsStr = points?.toString() ?? '0';
        print("AdminReedem: Found points for $docId: '$pointsStr'");
        return pointsStr;
      } else {
        print(
          "AdminReedem: User document not found for $docId. Returning '0'.",
        );
        return '0';
      }
    } catch (e) {
      print('AdminReedem: Error fetching user points for $docId: $e');
      return '0';
    }
  }

  // Builds the list of all pending redeem approval requests using StreamBuilder
  Widget allApprovals() {
    return StreamBuilder(
      stream: redeemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
            "AdminReedem: StreamBuilder (Pending) connectionState: waiting",
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
            "AdminReedem: StreamBuilder (Pending) hasError: ${snapshot.error}",
          );
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          print("AdminReedem: No pending redeem requests found.");
          return Center(
            child: Text(
              "No pending redeem requests.",
              style: AppWidget.normaltextstyle(18.0),
            ),
          );
        }

        print(
          "AdminReedem: StreamBuilder (Pending) hasData, displaying ${snapshot.data.docs.length} requests.",
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds =
                snapshot.data.docs[index]; // Single redeem request document
            print(
              "AdminReedem: Processing redeem request ID: ${ds.id}, UserID: ${ds["UserId"]}",
            );

            String pointsRedeemedStr = ds["Points"] ?? '0';
            int pointsRedeemed = int.tryParse(pointsRedeemedStr) ?? 0;
            double bdtEquivalent = pointsRedeemed * pointsToBdtRate;

            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Date Display
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ds["Date"],
                      textAlign: TextAlign.center,
                      style: AppWidget.whitetextstyle(22.0),
                    ),
                  ),
                  const SizedBox(width: 20.0),

                  // User Info and Actions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Name
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.green,
                              size: 25.0,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                ds["Name"],
                                style: AppWidget.normaltextstyle(18.0),
                                overflow:
                                    TextOverflow.ellipsis, // Handle long names
                              ),
                            ),
                          ],
                        ),
                        // Points Redeemed
                        Row(
                          children: [
                            const Icon(
                              Icons.point_of_sale,
                              color: Colors.green,
                              size: 25.0,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                "Points Redeemed: ${pointsRedeemed}",
                                style: AppWidget.normaltextstyle(18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // BDT Equivalent (NEW)
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_bitcoin, // Icon for BDT conversion
                              color: Colors.orange,
                              size: 25.0,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                "Equals: ${bdtEquivalent.toStringAsFixed(2)} BDT",
                                style: AppWidget.normaltextstyle(
                                  18.0,
                                ).copyWith(color: Colors.deepOrange),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // BKASH/UPI number
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.green,
                              size: 25.0,
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                "Bkash Number: ${ds["BkashNumber"] ?? ds["UPI"]}", // Check both "BkashNumber" and "UPI"
                                style: AppWidget.normaltextstyle(18.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0),

                        // Approve Button
                        GestureDetector(
                          onTap: () async {
                            String userId = ds["UserId"];
                            String redeemRequestId = ds.id;
                            String pointsRedeemedStr =
                                ds["Points"]; // Points specified in the redeem request

                            print(
                              "AdminReedem: Approve button tapped for UserID: $userId, RedeemRequestID: $redeemRequestId",
                            );
                            print(
                              "AdminReedem: Points to be subtracted (from request): '$pointsRedeemedStr'",
                            );

                            // 1. Get current user's total points from their main user document
                            String currentUserTotalPointsStr =
                                await getUserPoints(userId);
                            int currentUserTotalPoints =
                                int.tryParse(currentUserTotalPointsStr) ?? 0;
                            int pointsToSubtract =
                                int.tryParse(pointsRedeemedStr) ??
                                0; // Ensure it's an int

                            print(
                              "AdminReedem: Current user total points (fetched from users collection): $currentUserTotalPoints",
                            );
                            print(
                              "AdminReedem: Points to subtract (from redeem request document): $pointsToSubtract",
                            );

                            // Validate before subtracting
                            if (currentUserTotalPoints >= pointsToSubtract) {
                              // 2. Calculate new total points for the user
                              int updatedUserTotalPoints =
                                  currentUserTotalPoints - pointsToSubtract;
                              String updatedUserTotalPointsStr =
                                  updatedUserTotalPoints.toString();

                              print(
                                "AdminReedem: New user total points after subtraction: $updatedUserTotalPointsStr",
                              );

                              try {
                                // 3. Update the user's total points in their main document
                                await DatabaseMethods().updateUserPoints(
                                  userId,
                                  updatedUserTotalPointsStr,
                                );
                                print(
                                  "AdminReedem: Successfully updated user $userId's total points.",
                                );

                                // 4. Update the status of the admin redeem request (and add RedeemedAt timestamp)
                                await DatabaseMethods()
                                    .updateAdminReedemRequest(redeemRequestId);
                                print(
                                  "AdminReedem: Successfully updated admin redeem request status for $redeemRequestId.",
                                );

                                // 5. Update the status of the user's specific redeem transaction (and add RedeemedAt timestamp)
                                await DatabaseMethods().updateUserReedemRequest(
                                  userId,
                                  redeemRequestId,
                                );
                                print(
                                  "AdminReedem: Successfully updated user $userId's redeem transaction status for $redeemRequestId.",
                                );

                                // Calculate BDT equivalent for snackbar feedback
                                double bdtConverted =
                                    pointsToSubtract * pointsToBdtRate;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Redeem request approved for ${ds["Name"]}! ${pointsToSubtract} points subtracted (Worth ${bdtConverted.toStringAsFixed(2)} BDT).',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print(
                                  "AdminReedem: Error during approval process: $e",
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error approving redeem request: $e',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              print(
                                "AdminReedem: Error: User $userId trying to redeem $pointsToSubtract points, but only has $currentUserTotalPoints.",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error: User has insufficient points for this redemption.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 150,
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
            );
          },
        );
      },
    );
  }

  // NEW WIDGET: To display all approved redeem requests history
  Widget allRedeemedHistory() {
    return StreamBuilder(
      stream: redeemedHistoryStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
            "AdminReedem: StreamBuilder (Approved History) connectionState: waiting",
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
            "AdminReedem: StreamBuilder (Approved History) hasError: ${snapshot.error}",
          );
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          print(
            "AdminReedem: No approved redeem items in history found or snapshot is empty.",
          );
          return Center(
            child: Text(
              "No approved redeem items in history.",
              style: AppWidget.normaltextstyle(18.0),
            ),
          );
        }

        print(
          "AdminReedem: StreamBuilder (Approved History) hasData, total docs received: ${snapshot.data.docs.length}",
        );
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          DocumentSnapshot doc = snapshot.data.docs[i];
          print(
            "   Doc ${i + 1}: ID=${doc.id}, Name=${doc['Name']}, Status=${doc['Status']}, RedeemedAt=${(doc['RedeemedAt'] as Timestamp?)?.toDate()}",
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            String userName = ds["Name"] ?? "Unknown User";
            String pointsRedeemedStr = ds["Points"] ?? '0';
            String bkashNumber = ds["BkashNumber"] ?? ds["UPI"] ?? "N/A";
            Timestamp? redeemedTimestamp = ds["RedeemedAt"];

            String redeemedDate = "N/A";
            if (redeemedTimestamp != null) {
              final dateTime = redeemedTimestamp.toDate();
              redeemedDate = DateFormat('dd MMM, hh:mm a').format(dateTime);
            }

            int pointsRedeemed = int.tryParse(pointsRedeemedStr) ?? 0;
            double bdtEquivalent = pointsRedeemed * pointsToBdtRate;

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
                          "images/coin.png", // Using coin image for redeem history
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
                            Text(
                              "Redeemed: ${pointsRedeemed} points",
                              style: AppWidget.normaltextstyle(16.0),
                            ),
                            Text(
                              "Worth: ${bdtEquivalent.toStringAsFixed(2)} BDT",
                              style: AppWidget.normaltextstyle(
                                16.0,
                              ).copyWith(color: Colors.deepOrange),
                            ),
                            Text(
                              "Bkash Number: $bkashNumber",
                              style: AppWidget.normaltextstyle(16.0),
                            ),
                            Text(
                              "Redeemed On: $redeemedDate",
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

  // Main build method rendering the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back
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

                  // Page Title
                  Text(
                    "Redeem Approval", // Corrected typo: Reedem -> Redeem
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

            // Main Content Container
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
                              allApprovals(), // Displays pending redeem approval requests
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
                              allRedeemedHistory(), // Displays approved redeem history
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
