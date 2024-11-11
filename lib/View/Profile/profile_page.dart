import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Models/profiledata_model.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import '../Login/login_page.dart';

class ProfileManagementScreen extends StatefulWidget {
  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  bool isLoading = true;
  bool isUpdating = false; // Loader for update process
  Data? profileData; // Model to store profile data
  var userId;
  final TextEditingController messageController = TextEditingController(); // Controller for update profile message

  @override
  void initState() {
    super.initState();
    updateUi();
  }

  Future<void> updateUi() async {
    userId = await SharedPrefre.getUserId();
    debugPrint("userId:$userId");
    fetchProfileData();
  }

  // Fetch profile data from API
  Future<void> fetchProfileData() async {
    final url = Uri.parse(URLS.GET_PROFILE_DATA);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"user_id": userId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(
            "responseData['result']['status']: ${responseData['result']['status']}");
        if (responseData['result']['status'] == 'success') {
          setState(() {
            profileData = Data.fromJson(responseData['result']['data'][0]);
            isLoading = false;
          });
          print("profileData: $profileData");
        } else {
          setState(() {
            isLoading = false;
          });
          snowSnackBar(context, responseData['result']['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        snowSnackBar(
            context, "Failed to fetch profile data. Please try again.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
      snowSnackBar(context, "An error occurred. Please try again.");
    }
  }

  // Update profile API call
  Future<void> updateProfile() async {
    setState(() {
      isUpdating = true; // Show loader during the update
    });
    final url = Uri.parse(URLS.UPDATE_PROFILE);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "user_id": userId,
      "message": messageController.text
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("Update Response status: ${response.statusCode}");
      print("Update Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['result']['success'] == true) {
          snowSnackBar(context, responseData['result']['message']);
          messageController.clear();
          // Optionally, you can refresh profile data after update
          // fetchProfileData();
        } else {
          snowSnackBar(context, responseData['result']['message']);
        }
      } else {
        snowSnackBar(context, "Failed to update profile. Please try again.");
      }
    } catch (e) {
      print("Update Error: $e");
      snowSnackBar(context, "An error occurred while updating profile.");
    } finally {
      setState(() {
        isUpdating = false; // Hide loader after the update
      });
    }
  }

  Future<void> _logout(int userId) async {
    showLoader(context); // Assuming you have a function to show a loading indicator

    final url = Uri.parse(URLS.LOGOUT_USER);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "user_id": userId,

    });
    print("url:$url");
    print("body:$body");
    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      hideLoader(context); // Assuming you have a function to hide the loading indicator

      print("responseData:$responseData");

      if (responseData['result']['status'] == 'success') {
        // Handle success response
        print("fddfdf");
        clearSharedPreferences().whenComplete(() {
          Navigator.pop(context); // Close the dialog
          CallNextScreenAndClearStack(context, LoginPage()); // Navigate to the LoginScreen and clear navigation stack
        });
        // snowSnackBar(context, responseData['result']['message']);
        // Navigate to your login page or handle session management as needed
      } else {
        // Handle error response
        Navigator.pop(context);
        hideLoader(context);

        snowSnackBar(context, responseData['result']['message']);
      }
    } catch (e) {
      hideLoader(context);
      snowSnackBar(context, "An error occurred. Please try again.");
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context); // Close the dialog
      },
      child: Text(
        "No",
        style: TextStyle(color: Colors.orange), // Adjust color to match your theme
      ),
    );

    Widget continueButton = TextButton(
      onPressed: () {
        _logout(userId);
        // clearSharedPreferences().whenComplete(() {
        //   Navigator.pop(context); // Close the dialog
        //   CallNextScreenAndClearStack(context, LoginPage()); // Navigate to the LoginScreen and clear navigation stack
        // });
      },
      child: Text(
        "Yes",
        style: TextStyle(color: Colors.orange), // Adjust color to match your theme
      ),
    );

    // Create an AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: const Text("Do you want to Log-Out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // Show the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showLogoutConfirmationDialog(context);
            },
            icon: Image.asset(
              'assets/images/Logout.png', // Replace with your image path
              height: 30,
              width: 30,
            ),
          )
        ],
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        backgroundColor: Colors.orange.withOpacity(0.8),
      ),
      body: isLoading
          ? WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: Stack(
          children: [
            Center(
              child: SpinKitWave(
                color: Colors.blueGrey,
                size: 50.0,
              ),
            ),
          ],
        ),
      ) // Show loader while fetching data
          : profileData != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child:
                Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Name"),
              subtitle: Text(profileData!.name!.isNotEmpty ? profileData!.name! : 'N/A'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
              subtitle:
              Text(profileData!.workEmail!.isNotEmpty ? profileData!.workEmail! : 'N/A'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
              subtitle:  Text(profileData!.mobilePhone!.isNotEmpty ? profileData!.mobilePhone! : 'N/A'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.work),
              title: Text("Position"),
              subtitle: Text(profileData!.jobTitle!.isNotEmpty ? profileData!.jobTitle! : 'N/A'),
            ),
            Divider(),
            SizedBox(height: 20),
            // Title above TextFormField
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Request to Update Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // TextFormField for update profile
            TextFormField(
              controller: messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: name : ...',
              ),
            ),
            SizedBox(height: 20),
            // Button to update profile with loader
            Center(
              child: isUpdating
                  ? SpinKitWave(
                color: Colors.blueGrey,
                size: 40.0,
              )
                  : ElevatedButton(
                onPressed: () {
                  // Close the keyboard before the request
                  FocusScope.of(context).unfocus();
                  updateProfile(); // Call API to update profile
                },
                child: Text('Request to Update',style: TextStyle(color: Colors.black87),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      )
          : Center(child: Text('No Profile Data Available')),
    );
  }
}
