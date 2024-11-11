import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/common_method.dart';
import '../Login/login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Visibility toggles for passwords
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // API Call Function
  Future<void> _signup() async {
    var uuid = Uuid().v4();
    log("uuid : ${uuid}");
    showLoader(context);
    final url = Uri.parse(URLS.SIGNUP_USER);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "name": _nameController.text,
      "login": _emailController.text,
      "password": _passwordController.text,
      "token": uuid,
    });

    log("body:${body}");

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      log("response.body:${response.body}");
      hideLoader(context);

      print("responseData['result']['status']:${responseData['result']['status']}");

      if (responseData['result']['status'] == 'success') {
        // Handle success response
        CallNextScreenAndClearStack(context, LoginPage());
      } else {
        // Handle error response
        snowSnackBar(context, responseData['result']['message']);
      }
    } catch (e) {
      hideLoader(context);
      snowSnackBar(context, "An error occurred. Please try again.");
    }
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
              SizedBox(height: height * 0.05), // Top spacing
              // App logo or image
              Image.asset(
                'assets/images/splash_image.jpeg', // Add your own image
                height: height * 0.25,
                width: width * 0.7,
              ),
              SizedBox(height: 20),
              // Welcome Text
              Text(
                'Create an Account',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                'Sign up to get started',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 30),
              // Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.orange),
                ),
              ),
              SizedBox(height: 20),
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
              // Confirm Password TextField with eye icon
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.orange),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Signup Button
              ElevatedButton(
                onPressed: () {
                  if (!isEmailValidated(_emailController.text)) {
                    snowSnackBar(context, "Please enter a valid email address.");
                    return;
                  }

                  if (_passwordController.text != _confirmPasswordController.text) {
                    snowSnackBar(context, "Passwords do not match");
                    return;
                  }

                  _signup(); // Call signup function if validation passes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(width * 0.9, 50), // Full width button
                ),
                child: Text(
                  'Signup',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Already have an account? Login text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate back to Login page
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
