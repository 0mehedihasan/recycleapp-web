import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:recycleapp/services/database.dart';
import 'package:recycleapp/services/shared_pref.dart';
import 'package:recycleapp/services/widget_support.dart';

class Points extends StatefulWidget {
  const Points({super.key});

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  String? id; // User ID from shared preferences
  String? mypoints; // User points, WILL BE UPDATED BY the StreamBuilder
  String? name; // User name from shared preferences

  Stream? userRedeemTransactionsStream;

  TextEditingController pointscontroller = TextEditingController();
  TextEditingController upicontroller = TextEditingController();

  // Define the conversion rate
  static const double pointsToBdtRate = 0.5; // 1 point = 0.5 BDT

  @override
  void initState() {
    super.initState();
    _loadUserDataAndStreams();
  }

  _loadUserDataAndStreams() async {
    print("Points Page: Loading user data from shared preferences...");
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();
    print("Points Page: Loaded userId: $id, userName: $name");

    if (id != null) {
      userRedeemTransactionsStream = await DatabaseMethods()
          .getUserTransactions(id!);
      print("Points Page: Initialized userRedeemTransactionsStream.");
    } else {
      print(
        "Points Page: User ID is null, cannot initialize userRedeemTransactionsStream.",
      );
    }
    setState(() {});
  }

  Widget allUserRedeemTransactions() {
    if (userRedeemTransactionsStream == null) {
      print(
        "Points Page: userRedeemTransactionsStream is null, showing loading indicator.",
      );
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder(
      stream: userRedeemTransactionsStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
            "Points Page: Redeem transactions StreamBuilder connectionState: waiting",
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(
            "Points Page: Redeem transactions StreamBuilder hasError: ${snapshot.error}",
          );
          return Center(
            child: Text('Error loading transactions: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          print("Points Page: No redemption transactions found for user.");
          return Center(
            child: Text(
              "No redemption transactions yet.",
              style: AppWidget.normaltextstyle(16.0),
            ),
          );
        }

        print(
          "Points Page: Redeem transactions StreamBuilder hasData, displaying ${snapshot.data.docs.length} transactions.",
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];

            // Calculate BDT equivalent
            double points = double.tryParse(ds["Points"] ?? '0') ?? 0;
            double bdtEquivalent = points * pointsToBdtRate;

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
                          "images/coin.png",
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Redeemed: ${ds["Points"]} points",
                            style: AppWidget.normaltextstyle(18.0),
                          ),
                          Text(
                            "Equals: ${bdtEquivalent.toStringAsFixed(2)} BDT", // Display BDT
                            style: AppWidget.normaltextstyle(16.0),
                          ),
                          Text(
                            "Bkash: ${ds["BkashNumber"]}",
                            style: AppWidget.normaltextstyle(16.0),
                          ),
                          Text(
                            "Status: ${ds["Status"]}",
                            style: AppWidget.normaltextstyle(16.0).copyWith(
                              color:
                                  ds["Status"] == "Approved"
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                          Text(
                            "Date: ${ds["Date"]}",
                            style: AppWidget.normaltextstyle(14.0),
                          ),
                        ],
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

  Future<void> openBox() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                      const SizedBox(width: 30.0),
                      Text(
                        "Redeem Points",
                        style: AppWidget.greentextstyle(20.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Points to Redeem",
                    style: AppWidget.normaltextstyle(18.0),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: pointscontroller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Points",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text("Bkash Number", style: AppWidget.normaltextstyle(18.0)),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black38, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: upicontroller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Bkash Number",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () async {
                      print("Points Page: Redeem button tapped.");
                      if (pointscontroller.text.isNotEmpty &&
                          upicontroller.text.isNotEmpty) {
                        int pointsToRedeem =
                            int.tryParse(pointscontroller.text) ?? 0;
                        int currentMyPoints =
                            int.tryParse(mypoints ?? '0') ?? 0;
                        print(
                          "Points Page: Attempting to redeem $pointsToRedeem points. Current points: $currentMyPoints",
                        );

                        if (pointsToRedeem > 0 &&
                            currentMyPoints >= pointsToRedeem) {
                          DateTime now = DateTime.now();
                          String formattedDate = DateFormat(
                            'd MMM, hh:mm a',
                          ).format(now);

                          // Calculate the equivalent BDT amount for the redemption request
                          double bdtEquivalent =
                              pointsToRedeem * pointsToBdtRate;

                          Map<String, dynamic> redeemRequestMap = {
                            "Name": name,
                            "Points": pointscontroller.text,
                            "BkashNumber": upicontroller.text,
                            "Status": "Pending", // Set status to Pending
                            "Date": formattedDate,
                            "UserId": id,
                            "BDT_Equivalent": bdtEquivalent.toStringAsFixed(
                              2,
                            ), // Add BDT equivalent to the request
                          };
                          String redeemid = randomAlphaNumeric(10);

                          await DatabaseMethods().addUserReedemPoints(
                            redeemRequestMap,
                            id!,
                            redeemid,
                          );
                          print("Points Page: Added user redeem history.");

                          await DatabaseMethods().addAdminReedemRequests(
                            redeemRequestMap,
                            redeemid,
                          );
                          print("Points Page: Added admin redeem request.");

                          pointscontroller.clear();
                          upicontroller.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Redemption request submitted successfully! Waiting for admin approval.',
                              ),
                            ),
                          );
                        } else if (pointsToRedeem <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a positive amount of points to redeem.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Insufficient points to redeem.'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields.'),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Redeem",
                            style: AppWidget.whitetextstyle(20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      print(
        "Points Page: build method - User ID is null, showing loading indicator.",
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    print("Points Page: build method - User ID is $id. Building main UI.");
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Center(
              child: Text(
                "Points Page",
                style: AppWidget.healinetextstyle(28.0),
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 233, 249),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30.0),
                    // --- StreamBuilder for User Points ---
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(id)
                              .snapshots(),
                      builder: (context, snapshot) {
                        print(
                          "Points Page: User Points StreamBuilder - connectionState: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}",
                        );

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Error loading points: ${snapshot.error}',
                            style: AppWidget.normaltextstyle(16.0),
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          mypoints = "0";
                          print(
                            "Points Page: User Points StreamBuilder - No data or document doesn't exist. Setting mypoints to '0'.",
                          );
                          return Text(
                            'User data not found for points.',
                            style: AppWidget.normaltextstyle(16.0),
                          );
                        }

                        var userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        mypoints = userData['Points']?.toString() ?? '0';
                        print(
                          "Points Page: User Points StreamBuilder - Fetched points: '$mypoints'",
                        );

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: Material(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10.0),
                                  Image.asset(
                                    "images/coin.png",
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 30.0),
                                  Column(
                                    children: [
                                      Text(
                                        "Points Earned",
                                        style: AppWidget.normaltextstyle(20.0),
                                      ),
                                      Text(
                                        mypoints!,
                                        style: AppWidget.greentextstyle(30.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // --- END: StreamBuilder for User Points ---
                    const SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () {
                        openBox();
                      },
                      child: Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Center(
                            child: Text(
                              "Redeem Points",
                              style: AppWidget.whitetextstyle(23.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Text(
                                "Last Transactions",
                                style: AppWidget.normaltextstyle(22.0),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Expanded(child: allUserRedeemTransactions()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
