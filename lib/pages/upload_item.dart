import 'dart:io' show File; // Only import File for non-web platforms
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:recycleapp/services/database.dart';
import 'package:recycleapp/services/shared_pref.dart';
import 'package:recycleapp/services/widget_support.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Import kIsWeb for platform checks
import 'dart:typed_data'; // For Uint8List on web

// UploadItem screen to upload an item for recycling
class UploadItem extends StatefulWidget {
  // Controllers for input fields
  final String category; // Changed to final as it's passed in constructor
  final String id; // Changed to final as it's passed in constructor

  UploadItem({super.key, required this.category, required this.id});

  @override
  State<UploadItem> createState() => _UploadItemState();
}

class _UploadItemState extends State<UploadItem> {
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController quantitycontroller = TextEditingController();
  TextEditingController phonenumbercontroller =
      TextEditingController(); // New controller for phone number

  final ImagePicker _picker = ImagePicker();
  // Changed selectedImage to hold XFile directly
  // We'll process it differently based on platform
  XFile? _pickedXFile;
  Uint8List? _webImageBytes; // To store bytes for web display

  // Variables for user id and name
  String? userId, userName; // Renamed to avoid conflict with widget.id/category

  // Function to get user id and name from shared preferences
  getTheSharedPref() async {
    // Renamed for consistency
    userId = await SharedpreferenceHelper().getUserId();
    userName = await SharedpreferenceHelper().getUserName();
    setState(() {}); // Update UI after fetching
  }

  @override
  void initState() {
    super.initState();
    getTheSharedPref(); // Call the renamed function
  }

  Future<void> getImage() async {
    // Changed return type to void Future
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _pickedXFile = image;
        });

        if (kIsWeb) {
          // Read image bytes for web display
          _webImageBytes = await image.readAsBytes();
        } else {
          // For mobile/desktop, we can directly use File
          // selectedImage = File(image.path); // Old approach, not strictly needed with XFile
          // If you need a dart:io.File for other operations on mobile, you'd create it here.
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Added SingleChildScrollView to prevent overflow
        child: Container(
          margin: const EdgeInsets.only(top: 40.0), // Added const
          child: Column(
            children: [
              // Top bar with back button and title
              Padding(
                padding: const EdgeInsets.only(left: 20.0), // Added const
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(60),
                        child: Container(
                          padding: const EdgeInsets.all(6), // Added const
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            // Added const
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 5.5),
                    Text(
                      "Upload Item",
                      style: AppWidget.healinetextstyle(25.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0), // Added const
              // Main container
              Container(
                // Removed Expanded as SingleChildScrollView wraps the whole column
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  // Added const
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Color.fromARGB(255, 233, 233, 249),
                ),
                child: Padding(
                  // Added Padding here for content inside the container
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ), // Consistent padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30.0), // Added const
                      // Show selected image or camera icon
                      Center(
                        child: GestureDetector(
                          onTap: getImage, // Call getImage
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black45,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                _pickedXFile != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child:
                                          kIsWeb
                                              ? (_webImageBytes != null
                                                  ? Image.memory(
                                                    _webImageBytes!,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : const Center(
                                                    child: Text(
                                                      'Loading image...',
                                                    ),
                                                  ))
                                              : Image.file(
                                                // Use dart:io.File only for non-web
                                                File(_pickedXFile!.path),
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                    : const Icon(
                                      // Added const
                                      Icons.camera_alt_outlined,
                                      size: 30.0,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0), // Added const
                      // Address input field
                      Text(
                        "Enter your Address you want the item to be picked.",
                        style: AppWidget.normaltextstyle(18.0),
                      ),
                      const SizedBox(height: 10.0), // Added const
                      Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: addresscontroller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                // Added const
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              hintText: "Enter Address",
                              hintStyle: AppWidget.normaltextstyle(20.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0), // Spacing for new field
                      // Phone Number input field
                      Text(
                        "Enter your Phone Number.",
                        style: AppWidget.normaltextstyle(18.0),
                      ),
                      const SizedBox(height: 10.0), // Added const
                      Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller:
                                phonenumbercontroller, // Assign new controller
                            keyboardType:
                                TextInputType.phone, // Suggest phone keyboard
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                Icons.phone, // Phone icon
                                color: Colors.green,
                              ),
                              hintText: "Enter Phone Number",
                              hintStyle: AppWidget.normaltextstyle(20.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0), // Added const
                      // Quantity input field
                      Text(
                        "Enter the Quantity of item to be picked.",
                        style: AppWidget.normaltextstyle(18.0),
                      ),
                      const SizedBox(height: 10.0), // Added const
                      Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: quantitycontroller,
                            keyboardType:
                                TextInputType.number, // Suggest number keyboard
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                // Added const
                                Icons.inventory,
                                color: Colors.green,
                              ),
                              hintText: "Enter Quantity",
                              hintStyle: AppWidget.normaltextstyle(20.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60.0), // Added const
                      // Upload button
                      GestureDetector(
                        onTap: () async {
                          if (addresscontroller.text.isNotEmpty &&
                              quantitycontroller.text.isNotEmpty &&
                              phonenumbercontroller
                                  .text
                                  .isNotEmpty && // Check phone number field
                              _pickedXFile != null) {
                            // Ensure an image is picked
                            String itemId = randomAlphaNumeric(10);

                            // You will need to uncomment and set up Firebase Storage for image upload
                            // For web, you'd use firebaseStorageRef.putData(_webImageBytes!) or similar
                            // For mobile, you'd use firebaseStorageRef.putFile(File(_pickedXFile!.path))

                            // For now, setting Image to empty string as upload is commented
                            Map<String, dynamic> addItem = {
                              "Image":
                                  "", // This will be the download URL after upload
                              "Address": addresscontroller.text,
                              "PhoneNumber":
                                  phonenumbercontroller
                                      .text, // Add phone number to map
                              "Quantity": quantitycontroller.text,
                              "UserId": userId, // Use userId
                              "Name": userName, // Use userName
                              "Status": "Pending",
                              "Category":
                                  widget
                                      .category, // Use the category passed from widget
                            };

                            // Add item to user and admin collections
                            await DatabaseMethods().addUserUploadItem(
                              addItem,
                              userId!,
                              itemId,
                            );

                            await DatabaseMethods().addAdminItem(
                              addItem,
                              itemId,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  "Item has been uploaded Successfully!",
                                  style: AppWidget.whitetextstyle(22.0),
                                ),
                              ),
                            );

                            // Clear fields after upload
                            setState(() {
                              addresscontroller.text = "";
                              quantitycontroller.text = "";
                              phonenumbercontroller.text =
                                  ""; // Clear phone number field
                              _pickedXFile = null;
                              _webImageBytes = null;
                            });
                          } else {
                            // Show error if fields are empty or image not picked
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "Please fill all fields and select an image.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Material(
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width / 1.5,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Upload",
                                  style: AppWidget.whitetextstyle(26.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0), // Added bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
