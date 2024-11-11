import 'package:flutter/material.dart';

import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import '../Homepage/home_page.dart';
import '../Login/login_page.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () async {
      var userId = await SharedPrefre.getUserId();
      if (userId == null) {
        CallNextScreenAndClearStack(context, LoginPage());
      } else {
        CallNextScreenAndClearStack(context, HomeScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display splash image
            Image.asset(
              'assets/images/splash_image.jpeg', // Replace with your image path
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            // Display app name
            Text(
              'Nativeway HR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}