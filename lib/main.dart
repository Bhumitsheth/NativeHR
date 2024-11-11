import 'package:flutter/material.dart';
import 'View/Splash/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nativeway HR',
      theme: ThemeData(
        primaryColor: Colors.orange.withOpacity(0.8),
        // colorScheme: ColorScheme.fromSwatch(
        //   accentColor: Colors.blueGrey
        // ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}