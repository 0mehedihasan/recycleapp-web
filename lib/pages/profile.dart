import 'package:flutter/material.dart';
import 'package:recycleapp/pages/onboarding.dart';
import 'package:recycleapp/services/auth.dart';
import 'package:recycleapp/services/shared_pref.dart';
import 'package:recycleapp/services/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? id, name, email, image;

  getthesharedpref() async {
    id = await SharedpreferenceHelper().getUserId();
    name = await SharedpreferenceHelper().getUserName();
    email = await SharedpreferenceHelper().getUserEmail();
    image = await SharedpreferenceHelper().getUserImage();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // context is available here!
    return name == null
        ? const Center(child: CircularProgressIndicator()) // Added const
        : Container(
          margin: const EdgeInsets.only(top: 60.0), // Added const
          child: Column(
            children: [
              Center(
                child: Text(
                  "Profile Page",
                  style: AppWidget.healinetextstyle(28.0),
                ),
              ),
              const SizedBox(height: 20.0), // Added const
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ), // Added const
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    // Added const
                    color: Color.fromARGB(255, 233, 233, 249),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0), // Added const
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Image.network(
                            image!,
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0), // Added const
                      Container(
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.only(
                              // Added const
                              left: 10.0,
                              right: 10.0,
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              // Changed Row to Column to hold two rows of data
                              children: [
                                Row(
                                  // Row for Name
                                  children: [
                                    const Icon(
                                      // Added const
                                      Icons.person,
                                      color: Color(0xff4da9ba),
                                      size: 35.0,
                                    ),
                                    const SizedBox(width: 15.0), // Added const
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          // Added const
                                          "Name",
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          name!,
                                          style: const TextStyle(
                                            // Added const
                                            color: Colors.black,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ), // Spacer between Name and Email
                                Row(
                                  // Row for Email
                                  children: [
                                    const Icon(
                                      // Added const
                                      Icons.mail,
                                      color: Color(0xff4da9ba),
                                      size: 35.0,
                                    ),
                                    const SizedBox(width: 15.0), // Added const
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          // Added const
                                          "Email",
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          email!,
                                          style: const TextStyle(
                                            // Added const
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25.0), // Added const
                      GestureDetector(
                        onTap: () async {
                          await AuthMethods().SignOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const Onboarding(), // Added const
                            ),
                          );
                        },
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.only(
                              // Added const
                              left: 10.0,
                              right: 10.0,
                              top: 20.0,
                              bottom: 20.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              // Added const
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color(0xff4da9ba),
                                  size: 35.0,
                                ),
                                SizedBox(width: 15.0),
                                Text(
                                  "LogOut",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Color(0xff4da9ba),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0), // Added const
                      GestureDetector(
                        onTap: () async {
                          // Pass the context here!
                          await AuthMethods().deleteuser(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const Onboarding(), // Added const
                            ),
                          );
                        },
                        child: Material(
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.only(
                              // Added const
                              left: 10.0,
                              right: 10.0,
                              top: 20.0,
                              bottom: 20.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              // Added const
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Color(0xff4da9ba),
                                  size: 35.0,
                                ),
                                SizedBox(width: 15.0),
                                Text(
                                  "Delete Account",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Color(0xff4da9ba),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0), // Added const
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
