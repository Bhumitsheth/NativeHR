import 'package:flutter/material.dart';

import '../Attendance/attendance_history_page.dart';
import '../Dashboard/dashboard_page.dart';
import '../Leave/leave_request_page.dart';
import '../Profile/profile_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    AttendanceHistoryScreen(),
    LeaveRequestScreen(),
    ProfileManagementScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Odoo Attendance App'),
      //   backgroundColor: Colors.orange.withOpacity(0.8),
      // ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.orange.withOpacity(0.8),
      //         ),
      //         child: Text(
      //           'Menu',
      //           style: TextStyle(
      //             color: Colors.black,
      //             fontSize: 24,
      //           ),
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.dashboard, color: Colors.black,),
      //         title: Text('Dashboard'),
      //         onTap: () {
      //           _onItemTapped(0);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.history, color: Colors.black,),
      //         title: Text('Attendance History'),
      //         onTap: () {
      //           _onItemTapped(1);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.person, color: Colors.black,),
      //         title: Text('Profile'),
      //         onTap: () {
      //           _onItemTapped(2);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.request_page, color: Colors.black,),
      //         title: Text('Leave Requests'),
      //         onTap: () {
      //           _onItemTapped(3);
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.5),
        // Set background color with opacity
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        // Color for selected icon
        unselectedItemColor: Colors.white,
        // Color for unselected icon
        selectedLabelStyle: TextStyle(
          color: Colors.orange,
          fontSize: 14, // Slightly larger text for selected label
          fontWeight: FontWeight.bold, // Bold selected label
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 12, // Slightly smaller text for unselected label
        ),
        showSelectedLabels: true,
        // Ensure labels are shown for selected items
        showUnselectedLabels: true,
        // Ensure labels are shown for unselected items
        type: BottomNavigationBarType.fixed,
        // Prevent icons from shifting
        elevation: 10,
        // Add elevation for a subtle shadow effect
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Leave',
          ), BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
