import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recycleapp/pages/upload_item.dart';
import 'package:recycleapp/services/database.dart';
import 'package:recycleapp/services/shared_pref.dart';
import 'package:recycleapp/services/widget_support.dart';

// Home page widget
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? id, name, userImage; // User ID, Name, and Image URL
  Stream? pendingStream; // Stream to hold user's pending requests

  @override
  void initState() {
    ontheload(); // Call on widget initialization
    super.initState();
  }

  // Load initial data when widget is created
  ontheload() async {
    await getthesharedpref();
    if (id != null) {
      // Ensure ID is not null before fetching pending requests
      pendingStream = await DatabaseMethods().getUserPendingRequests(id!);
    }
    setState(() {});
  }

  getthesharedpref() async {
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();
    userImage =
        await SharedpreferenceHelper()
            .getUserImage(); // Assuming you have a method to get the user image URL
    setState(() {}); // Update UI after fetching
  }

  // Widget to show all pending requests
  Widget allPendingRequests() {
    return StreamBuilder(
      stream: pendingStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0,
                  ),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black45, width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      // Show address with location icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 30.0,
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            ds["Address"],
                            style: AppWidget.normaltextstyle(20.0),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Display a sample image (you might want to fetch this from Firebase too if available per request)
                      Image.asset(
                        "images/chips.png", // This is still a static image. If each request has its own image, you'll need to use ds["ImageUrl"] here.
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10.0),
                      // Show quantity information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.layers,
                            color: Colors.green,
                            size: 30.0,
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            ds["Quantity"],
                            style: AppWidget.normaltextstyle(24.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                );
              },
            )
            : Container(); // Return empty container if no data
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          name == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading if name is null
              : SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section with greeting and profile picture
                      Row(
                        children: [
                          const SizedBox(width: 5.0),
                          Image.asset(
                            "images/wave.png",
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              "Hello, ",
                              style: AppWidget.healinetextstyle(26.0),
                            ),
                          ),
                          Text(name!, style: AppWidget.greentextstyle(25.0)),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  userImage != null && userImage!.isNotEmpty
                                      ? Image.network(
                                        userImage!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.error),
                                      )
                                      : Image.asset(
                                        "images/boy.jpg",
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ), // Center image (home banner)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Image.asset("images/home.png"),
                        ),
                      ),
                      const SizedBox(height: 20.0), // Categories section
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Categories",
                          style: AppWidget.healinetextstyle(24.0),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ), // Horizontal list of categories
                      Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        height: 130,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UploadItem(
                                          category: "Plastic",
                                          id: id!,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFececf8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black45,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "images/plastic.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Plastic",
                                    style: AppWidget.normaltextstyle(20.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            GestureDetector(
                              // <--- ADDED GestureDetector here
                              onTap: () {
                                // Add navigation for Paper category here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UploadItem(
                                          category:
                                              "Paper", // Pass the correct category
                                          id: id!,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFececf8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black45,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "images/paper.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Paper",
                                    style: AppWidget.normaltextstyle(20.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            GestureDetector(
                              // <--- ADDED GestureDetector here
                              onTap: () {
                                // Add navigation for Battery category here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UploadItem(
                                          category:
                                              "Battery", // Pass the correct category
                                          id: id!,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFececf8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black45,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "images/battery.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Battery",
                                    style: AppWidget.normaltextstyle(20.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            GestureDetector(
                              // <--- ADDED GestureDetector here
                              onTap: () {
                                // Add navigation for Glass category here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UploadItem(
                                          category:
                                              "Glass", // Pass the correct category
                                          id: id!,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFececf8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black45,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "images/glass.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "Glass",
                                    style: AppWidget.normaltextstyle(20.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0), // Pending Request section
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Pending Request",
                          style: AppWidget.healinetextstyle(22.0),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: allPendingRequests(),
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
    );
  }
}
