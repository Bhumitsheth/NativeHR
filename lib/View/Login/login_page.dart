import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import '../Homepage/home_page.dart';
import '../Signup/signup_page.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Visibility toggle for password
  bool _isPasswordVisible = false;

  // API Call Function for login
  Future<void> _login() async {
    var uuid = Uuid().v4();
    log("uuid : ${uuid}");
    showLoader(context); // Show loader before starting API call
    final url = Uri.parse(URLS.LOGIN_USER);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "login": _emailController.text,
      "password": _passwordController.text,
      "token" : uuid,
    });

    // try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      debugPrint("responseData:${responseData}");
      debugPrint("status:${responseData['result']['status']}");

      hideLoader(context); // Hide loader after API call completes

      if (responseData['result']['status'] == 'success') {
        var userId = responseData['result']['user_id'];
        var name = responseData['result']['name'];
        var email = responseData['result']['email'];
        var deviceToken = responseData['result']['device_token'];
        SharedPrefre.saveUserId(userId!);
        SharedPrefre.saveUserName(name!);
        SharedPrefre.saveUserEmail(email!);
        debugPrint("userId:$userId");
        debugPrint("name:$name");
        debugPrint("email:$email");
        CallNextScreenAndClearStack(context, HomeScreen());
      } else {
        // Handle error response
        snowSnackBar(context, responseData['result']['message']);
      }
    // } catch (e) {
    //   hideLoader(context); // Hide loader on error
    //   snowSnackBar(context, "An error occurred. Please try again.");
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.1), // Top spacing
              // App logo or image
              Image.asset(
                'assets/images/splash_image.jpeg', // Add your own image
                height: height * 0.25,
                width: width * 0.7,
              ),
              SizedBox(height: 20),
              // Welcome Text
              Text(
                'Welcome',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                'Please login to your account',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 30),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.orange),
                ),
              ),
              SizedBox(height: 20),
              // Password TextField with eye icon
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.orange),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  // if (!isEmailValidated(_emailController.text)) {
                  //   snowSnackBar(context, "Please enter a valid email address.");
                  //   return;
                  // }

                  if (_emailController.text.isEmpty) {
                    snowSnackBar(context, "Please enter a valid value");
                    return;
                  }

                  if (_passwordController.text.isEmpty) {
                    snowSnackBar(context, "Password are required!");
                    return;
                  }

                  _login(); // Call login function if validation passes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(width * 0.9, 50), // Full width button
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // SizedBox(height: 20),
              // // Don't have an account? Signup text
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Don't have an account?",
              //       style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         // Navigate to Signup page
              //         CallNextScreen(context, SignupPage());
              //       },
              //       child: Text(
              //         'Signup',
              //         style: GoogleFonts.roboto(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.orange,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
