import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Import for geolocation
import 'package:device_info_plus/device_info_plus.dart'; // Import for device info
import 'package:permission_handler/permission_handler.dart' as prefix;

import '../../Models/todays_history_model.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import '../../utils/no_internet_dialog.dart';import 'dart:developer';


class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool? isCheckedIn;
  bool isLoading = true;
  String totalHours = "0:00:00";
  List<TodaysHistoryModel> todaysHistory = [];
  String deviceInfo = '';
  var userId;
  String mLatiPosition = "";
  String? errorMessage;
  String mLogiPosition = "";
  bool isLocationEnabled = false;
  bool isInternetAvailable = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    updateUi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission();
    });
  }

  // Step 3: Check internet connection
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isInternetAvailable = false;
      });
      // showNoInternetDialog();
      NoInternetDialog(
            () {
          // Navigator.pop(context); // Close the dialog
          checkInternetConnection(); // Retry checking the connection
        },
      );
    } else {
      setState(() {
        isInternetAvailable = true;
      });
      updateUi(); // Proceed with updating UI if internet is available
    }
  }

  // Step 4: Show No Internet Dialog
  void showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without retrying
      builder: (BuildContext context) {
        return AlertDialog(
          content: NoInternetDialog(
                () {
              Navigator.pop(context); // Close the dialog
              checkInternetConnection(); // Retry checking the connection
            },
          ),
        );
      },
    );
  }

  // Future<void> requestLocationPermission() async {
  //   print("++requestLocationPermission");
  //   final serviceStatusLocation =
  //   await prefix.Permission.locationWhenInUse.isGranted;
  //   bool isLocation = serviceStatusLocation == ServiceStatus.enabled;
  //   final status = await prefix.Permission.locationWhenInUse.request();
  //   if (status == prefix.PermissionStatus.granted) {
  //     getCurrntlocation();
  //   } else if (status == prefix.PermissionStatus.denied) {
  //     print('Permission denied');
  //   } else if (status == prefix.PermissionStatus.permanentlyDenied) {
  //     print('Permission Permanently Denied');
  //     await prefix.openAppSettings();
  //   }
  // }

  Future<void> requestLocationPermission() async {
    print("++requestLocationPermission");

    // Check if the permission is already granted
    final serviceStatusLocation = await prefix.Permission.locationWhenInUse.isGranted;

    if (serviceStatusLocation == prefix.PermissionStatus.granted) {
      // If already granted, proceed to get location
      getCurrntlocation();
    } else {
      // Request the location permission
      final status = await prefix.Permission.locationWhenInUse.request();

      // Handle the permission status
      if (status == prefix.PermissionStatus.granted) {
        getCurrntlocation();  // Proceed if granted
      } else if (status == prefix.PermissionStatus.denied) {
        // If permission is denied, show a custom message and keep prompting
        print('Permission denied');
        exit(0);// This will shut down the app
        showPermissionRequiredDialog(); // Custom dialog/message
      } else if (status == prefix.PermissionStatus.permanentlyDenied) {
        // If permanently denied, navigate the user to app settings
        print('Permission Permanently Denied');
        exit(0);// This will shut down the app
        await prefix.openAppSettings();
      }
    }
  }

// Custom dialog/message to prompt user to allow permission
  void showPermissionRequiredDialog() {
    // Show a dialog or alert to inform the user that permission is needed
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text('Location permission is needed for this feature to work.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                requestLocationPermission(); // Re-check permission after dismissing dialog
              },
              child: Text('Allow Permission'),
            ),
          ],
        );
      },
    );
  }


  // Method to show a dialog when location services are disabled
  void showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Location Services Disabled"),
        content: Text("Please enable location services to use the app."),
        actions: [
          TextButton(
            child: Text("Enable"),
            onPressed: () async {
              await Geolocator.openLocationSettings(); // Open location settings
              // requestLocationPermission(); // Retry after user tries to enable location
            },
          ),
        ],
      ),
    );
  }

  Future<void> getCurrntlocation() async {
    // positions are latitude and logitude====>>>.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    mLatiPosition = position.latitude.toString();
    mLogiPosition = position.longitude.toString();
    SharedPrefre.saveCurrentLatitude(mLatiPosition);
    SharedPrefre.saveCurrentLongitude(mLogiPosition);
    print('01=====>getCurrntlocation() longitude------>>' + mLogiPosition);
  }

  Future<void> updateUi() async {
    userId = await SharedPrefre.getUserId();
    debugPrint("userId:$userId");
    await fetchStatusOfCheckIn();
    getDeviceInfo(); // Fetch device info
    await fetchTodaysHistory(); // Fetch todaysHistory data on screen load
  }

  // Fetch today's history from API
  Future<void> fetchTodaysHistory() async {
    final url = Uri.parse(URLS.TODAYS_ATTENDANCE_HISTORY);
    final params = {"user_id": userId};
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);
    log("TodaysHistory body:$body");
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['result']['status'] == 'success') {
          log("TodaysHistory responseData:$responseData");
          setState(() {
            totalHours = responseData['result']['total_hours'];
            todaysHistory = (responseData['result']['data'] as List)
                .map((data) => TodaysHistoryModel.fromJson(data))
                .toList();
            isLoading = false;
          });
        } else {
          errorMessage = responseData['result']['message'];
          setState(() {
            isLoading = false;
          });
          // snowSnackBar(context, responseData['result']['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        snowSnackBar(context,
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      snowSnackBar(context, "An error occurred. Please try again.");
    }
  }

  // Fetch check-in status from API
  Future<void> fetchStatusOfCheckIn() async {
    final url = Uri.parse(URLS.DASHBOARD_FLAG);
    final params = {"user_id": userId};
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);

    debugPrint("body:$body");
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("responseData:$responseData");
        if (responseData['result']['status'] == 'success') {
          setState(() {
            isCheckedIn = responseData['result']['is_checkedin'];
          });
          debugPrint("isCheckedIn:$isCheckedIn");
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
        snowSnackBar(context,
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      snowSnackBar(context, "An error occurred. Please try again.");
    }
  }

  // Get device info
  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    setState(() {
      deviceInfo =
          '${androidInfo.brand} ${androidInfo.model}, Android ${androidInfo.version.release}';
    });
    print("Device Info: $deviceInfo");
  }

  // Check-In API Call
  Future<void> checkIn() async {
    if(mLatiPosition != null && mLatiPosition.isNotEmpty &&  mLogiPosition != null && mLogiPosition.isNotEmpty && deviceInfo != null && deviceInfo.isNotEmpty) {
      print("logg: Location permission allowed on checkIn");
      final url = Uri.parse(URLS.CHECK_IN);
    final params = {
      "user_id": userId,
      "latitude": mLatiPosition,
      "longitude": mLogiPosition,
      "device_info": deviceInfo,
    };
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);

    print("body:$body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("responseData:${responseData}");
        if (responseData['result']['status'] == 'success') {
          snowSnackBar(context, "Check-In Successful!");
          fetchStatusOfCheckIn();
        } else {
          snowSnackBar(context, responseData['result']['message']);
        }
      } else {
        snowSnackBar(
            context, "Failed to check in. Status code: ${response.statusCode}");
      }
    } catch (e) {
      snowSnackBar(context, "An error occurred. Please try again.");
    }
  } else {
  snowSnackBar(context, "Location permission not allowed. Please try again.");
  }
  }

  // Check-Out API Call
  Future<void> checkOut() async {
    if(mLatiPosition != null && mLatiPosition.isNotEmpty &&  mLogiPosition != null && mLogiPosition.isNotEmpty && deviceInfo != null && deviceInfo.isNotEmpty) {
    print("logg: Location permission allowed on checkout");
      final url = Uri.parse(URLS.CHECK_OUT);

    final params = {
      "user_id": userId,
      "latitude": mLatiPosition,
      "longitude": mLogiPosition,
      "device_info": deviceInfo,
    };
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);

    print("checkout body:$body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("responseData checkout : ${responseData}");
        if (responseData['result']['status'] == 'success') {
          snowSnackBar(context, "Check-Out Successful!");
          fetchStatusOfCheckIn();
          await fetchTodaysHistory(); // Refresh today's history
        } else {
          snowSnackBar(context, responseData['result']['message']);
        }
      } else {
        snowSnackBar(context,
            "Failed to check out. Status code: ${response.statusCode}");
      }
    } catch (e) {
      snowSnackBar(context, "An error occurred. Please try again.");
    }
    } else {
      snowSnackBar(context, "Location permission not allowed. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
                )
              :  isInternetAvailable ?
      SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          isCheckedIn!
                              ? "You're currently checked in."
                              : "You're not checked in.",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 20),
                      isCheckedIn!
                          ? SlideAction(
                              onSubmit: checkOut,
                              text: 'Slide to Check-Out',
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              innerColor: Colors.black87,
                              outerColor: Colors.orange.withOpacity(0.8),
                              borderRadius: 12,
                            )
                          : SlideAction(
                              onSubmit: checkIn,
                              text: 'Slide to Check-In',
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              innerColor: Colors.black87,
                              outerColor: Colors.orange.withOpacity(0.8),
                              borderRadius: 12,
                            ),
                      SizedBox(height: 30),
                      // Total Hours
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Total hours",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            Text(
                              totalHours,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Today's History
                      Text(
                        "Today's History",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 10),
                      // List of todaysHistory Cards
                      todaysHistory.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Center(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .black87), // Customize the error message style
                                ),
                              ),
                            )
                          : Column(
                              children: todaysHistory
                                  .map((history) =>
                                      _buildAttendanceCard(history))
                                  .toList(),
                            ),
                    ],
                  ),
                ) : Container(),

    );
  }

  // Attendance card widget
  Widget _buildAttendanceCard(TodaysHistoryModel attendance) {
    return Card(
      color: Colors.orange[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date: ${attendance.formattedDate}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Check-In Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Check-In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Time: ${attendance.formattedCheckIn}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Check-Out Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Check-Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Time: ${attendance.formattedCheckOut}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
