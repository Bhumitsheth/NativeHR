import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Models/attendance_history_model.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  var userId;
  List<Data>? attendanceList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    updateUi();
  }

  Future<void> updateUi() async {
    userId = await SharedPrefre.getUserId();
    debugPrint("userId: $userId");
    if (userId != null) {
      await _fetchAttendanceData(userId);
    } else {
      setState(() {
        isLoading = false;
      });
      snowSnackBar(context, 'User ID not available');
    }
  }

  Future<void> _fetchAttendanceData(int? userIdd) async {
    final params = {
      "user_id": userIdd,
    };

    try {
      final response = await http.post(
        Uri.parse(URLS.ATTENDANCE_HISTORY),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(params),
      );

      debugPrint("body: ${response.body}");
      log("ATTENDANCE_HISTORY response.body:${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debugging: Print the entire response to see its structure
        log('Response Data: $data');

        // Check if the 'result' key exists and its 'status' is 'success'
        if (data['result'] != null && data['result']['status'] == 'success') {
          final List<dynamic> attendanceData = data['result']['data'];
          setState(() {
            attendanceList = attendanceData.map((item) => Data.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          snowSnackBar(context, data['result']['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        snowSnackBar(context, 'Failed to load attendance data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      snowSnackBar(context, 'Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        backgroundColor: Colors.orange.withOpacity(0.8),
      ),
      body: isLoading
          ? Center(
        child: SpinKitWave(
          color: Colors.blueGrey,
          size: 50.0,
        ),
      )
          : attendanceList == null || attendanceList!.isEmpty
          ? Center(
        child: Text('No attendance data found.'),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: attendanceList!.length,
          itemBuilder: (context, index) {
            final attendance = attendanceList![index];
            return _buildAttendanceCard(attendance, context);
          },
        ),
      ),
    );
  }
}

Widget _buildAttendanceCard(Data attendance, BuildContext context) {
  // Use MediaQuery to make the height responsive
  double cardHeight = MediaQuery.of(context).size.height * 0.27; // Adjusted proportionally

  return Container(
    height: cardHeight, // Dynamic height based on screen size
    child: Card(
      color: Colors.orange[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left:10, right: 10, bottom: 10 ),
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
              overflow: TextOverflow.ellipsis, // Add overflow handling
            ),
            SizedBox(height: 2),
            Text(
              'Company: ${attendance.companyId}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
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
                            overflow: TextOverflow.ellipsis,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Location: ${attendance.location}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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
                            overflow: TextOverflow.ellipsis,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Location: ${attendance.location_out}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
