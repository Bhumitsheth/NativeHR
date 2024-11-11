import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:attendanceapp/utils/responsive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../View/Login/login_page.dart';

BuildContext? _progressContext;

// Clear all user data from SharedPreferences
Future<void> clearSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all stored data
}

// Show logout confirmation dialog
void showLogoutConfirmation(BuildContext context) {
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
      clearSharedPreferences().whenComplete(() {
        Navigator.pop(context); // Close the dialog
        CallNextScreenAndClearStack(context, LoginPage()); // Navigate to the LoginScreen and clear navigation stack
      });
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

bool isEmailValidated(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

void CallNextScreen(BuildContext context, StatefulWidget nextScreen) {
  // AnalyticsService().setEventName(nextScreen.toStringShort());
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => nextScreen,
          settings: RouteSettings(name: nextScreen.toString())));
}

void CallNextScreenClearOld(BuildContext context, StatefulWidget nextScreen) {
  // AnalyticsService().setEventName(nextScreen.toStringShort());
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => nextScreen,
        settings: RouteSettings(name: nextScreen.toString())),
  );
}

void CallNextScreenAndClearStack(
    BuildContext context, StatefulWidget nextScreen) {
  //AnalyticsService().setEventName(nextScreen.toStringShort());
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => nextScreen,
          settings: RouteSettings(name: nextScreen.toString())),
          (Route<dynamic> route) => false);
}

Future CallNextScreenWithResult(
    BuildContext context, StatefulWidget nextScreen) async {
  // AnalyticsService().setEventName(nextScreen.toStringShort());
  var action = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => nextScreen,
          settings: RouteSettings(name: nextScreen.toString())));

  return action;
}

SizedBox heightSizedBox(double height) {
  return SizedBox(
    height: height,
  );
}

SizedBox widthSizedBox(double width) {
  return SizedBox(
    width: width,
  );
}

void hideProgressDialog() {
  if (_progressContext != null) {
    Navigator.of(_progressContext!).pop(true);
    _progressContext = null;
  }
}

// Function to hide loader
void hideLoader(BuildContext context) {
  if (_progressContext != null) {
    Navigator.of(_progressContext!, rootNavigator: true).pop(); // Close the loader
    _progressContext = null; // Reset the context
  }
}

// Function to show loader
void showLoader(BuildContext context, {Color? loaderColor}) {
  if (_progressContext == null) { // Prevent showing multiple loaders
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext ctx) {
        _progressContext = ctx; // Store the context to close later
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: Stack(
            children: [
              // Dark background
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(0.5),
              ),
              // Loader widget
              Center(
                child: SpinKitWave(
                  color: loaderColor ?? Colors.blueGrey,
                  size: 50.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showProgressbarDialog(BuildContext context,
    {Color? loaderColor, String? text}) {
  if (_progressContext == null) {
    displayProgressDialog(
        context: context,
        barrierDismissible: false,
        builder: (con) {
          _progressContext = con;
          return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                  child: SpinKitWave(
                    color: Colors.white,
                  ),
                ),
              ));
        });
  }
}

Future<T?>? displayProgressDialog<T>(
    {@required BuildContext? context,
      bool barrierDismissible = true,
      Widget? child,
      WidgetBuilder? builder,
      bool useRootNavigator = true}) {
  assert(child == null || builder == null);
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context!));

  final ThemeData theme = Theme.of(context!);
  return showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    pageBuilder: (BuildContext? buildContext, Animation<double>? animation,
        Animation<double>? secondaryAnimation) {
      final Widget pageChild = child ?? Builder(builder: builder!);
      return SafeArea(
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    useRootNavigator: useRootNavigator,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black12.withOpacity(0.6),
    transitionDuration: const Duration(seconds: 1),
  );
}

double getHeightWidth(BuildContext context, double size) {
  return ResponsiveFlutter.of(context).scale(size);
}

double getFontSize(BuildContext context, double size) {
  return ResponsiveFlutter.of(context).fontSize(size);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}


Future<bool> checkImageSize(String path) async {
  print("PATH---$path");
  var bytes = await getFileSize(path);
  if (bytes > 5000000) {
    return true;
  } else {
    return false;
  }
}


Future<int> getFileSize(String filepath) async {
  var file = File(filepath);
  int bytes = await file.length();
  print("PATH---$bytes");
  return bytes;
}
// Future<String?> getId() async {
//   var deviceInfo = DeviceInfoPlugin();
//   if (Platform.isIOS) {
//     var iosDeviceInfo = await deviceInfo.iosInfo;
//     return iosDeviceInfo.identifierForVendor;
//   } else if (Platform.isAndroid) {
//     var androidDeviceInfo = await deviceInfo.androidInfo;
//     return androidDeviceInfo.id;
//   }
// }


// Future<userData.getProfileModel> prefrenceData() async {
//   var temp = await preferences.getPreference('USER_DATA', '');
//   userData.getProfileModel preferanceData =
//   userData.getProfileModel.fromJson(json.decode(temp));
//   return preferanceData;
//   print(preferanceData);
// }

Future<bool> isInternetAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

void snowSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    inviteSnackBar(context, msg),
  );
}

SnackBar inviteSnackBar(BuildContext context, String msg) {
  return SnackBar(
    padding:
    EdgeInsets.all(ResponsiveFlutter.of(context).scale(8)),
    content: Text(
      msg,
      style: TextStyle(color: Colors.white,),
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.grey.withOpacity(0.8),
    duration: const Duration(
      seconds: 5,
    ),
    behavior: SnackBarBehavior.fixed,
  );
}


