import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import '../../Models/leave_data_model.dart';
import '../../apiRepository/APIConstant.dart';
import '../../utils/appSharedPref.dart';
import '../../utils/common_method.dart';
import 'LeaveRequestFormPage.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveData>? leaveHistoryList;
  int? userId;
  String selectedValue = 'my_team';

  @override
  void initState() {
    super.initState();
    updateUi();
  }

  Future<void> updateUi() async {
    userId = await SharedPrefre.getUserId();
    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    final url = Uri.parse(URLS.LEAVE_HISTORY);
    final params = {"user_id": userId, "leave_filter": selectedValue,};
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(params);

    final response = await http.post(url, headers: headers, body: body);

    print("response${response.body}");
    debugPrint("body:${body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      debugPrint("data:${data}");
      if(data['result']['success'] == true) {
        debugPrint("leave_ids:${data['result']['leave_ids']}");
        final List<dynamic> leaveHistoryData = data['result']['leave_data'];
        setState(() {
          leaveHistoryList =
              leaveHistoryData.map((item) => LeaveData.fromJson(item)).toList();
        });
      } else{
        snowSnackBar(context, data['result']['message']);
      }
    } else {
      snowSnackBar(context, "Failed to load leave history");
    }
  }

  void approveLeave(int leaveId) async {
    showLoader(context);
    final url = Uri.parse(URLS.APPROVE_LEAVE);
    final body = jsonEncode({"user_id": userId, "leave_id": leaveId});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    final data = jsonDecode(response.body);

    log("body:$body");
    log("data:$data");

    if (response.statusCode == 200) {
      if (data['result']['success'] == true) {
        hideLoader(context);
        setState(() {
          updateUi();
        });
      } else {
        hideLoader(context);
        snowSnackBar(context, data['result']['message']);
      }
    } else {
      hideLoader(context);
      snowSnackBar(context, data['result']['message'] ?? 'Error occurred');
    }
  }

  void validateLeave(int leaveId) async {
    showLoader(context);
    final url = Uri.parse(URLS.VALIDATE_LEAVE);
    final body = jsonEncode({"user_id": userId, "leave_id": leaveId});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    final data = jsonDecode(response.body);

    log("body:$body");
    log("data:$data");

    if (response.statusCode == 200) {
      if (data['result']['success'] == true) {
        hideLoader(context);
        setState(() {
          updateUi();
        });
      } else {
        hideLoader(context);
        snowSnackBar(context, data['result']['message']);
      }
    } else {
      hideLoader(context);
      snowSnackBar(context, data['result']['message'] ?? 'Error occurred');
    }
  }

  void rejectLeave(int leaveId) async {
    showLoader(context);
    final url = Uri.parse(URLS.REJECT_LEAVE);
    final body = jsonEncode({"user_id": userId, "leave_id": leaveId});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);
    final data = jsonDecode(response.body);

    debugPrint("body:$body");
    debugPrint("data:$data");

    if (response.statusCode == 200) {
      if (data['result']['success'] == true) {
        hideLoader(context);
        setState(() {
          updateUi();
        });
      } else {
        hideLoader(context);
        snowSnackBar(context, data['result']['message']);
      }
    } else {
      hideLoader(context);
      snowSnackBar(context, data['result']['message'] ?? 'Error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange.withOpacity(0.8),
        title: Text(
          'Leave Request',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.transparent, // Slight transparent background
              borderRadius: BorderRadius.circular(12), // Rounded edges for dropdown container
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                icon: Icon(Icons.filter_list, color: Colors.black),
                dropdownColor: Colors.white, // Dropdown background color
                style: TextStyle(color: Colors.white, fontSize: 16), // Text style
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                    fetchLeaveData(); // Fetch data based on selected filter
                  });
                },
                items: <String>['my_team', 'all']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value == 'my_team' ? 'My Team' : 'All',
                        style: TextStyle(color: Colors.black, fontSize: 16), // Dropdown text style
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // CallNextScreen(context, LeaveRequestFormPage());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaveRequestFormPage()),
          ).then((result) {
            if (result == true) {
              updateUi(); // Re-fetch or update the UI
            }
          });

        },
        backgroundColor: Colors.orange.withOpacity(0.8),
        child: Icon(Icons.add),
      ),
      body: leaveHistoryList == null
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
            ) // Show loader while fetching data// Show loader while data is fetched
          : leaveHistoryList!.isEmpty
              ? Center(
                  child: Text('No leave requests available.')) // No data case
              : ListView.builder(
                  itemCount: leaveHistoryList!.length,
                  itemBuilder: (context, index) {
                    final leave = leaveHistoryList![index];
                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15), // For rounded corners
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              title: Text(leave.holidayStatusId!,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Employee: ${leave.employeeId}'),
                                  Text('Description: ${leave.privatename}'),
                                  Text('Start Date: ${leave.dateFrom}'),
                                  Text('End Date: ${leave.dateTo}'),
                                  // Text('Duration: ${leave.durationDisplay}'),
                                  // Display leave.state below Duration with colored text
                                  _buildStateText(leave.state!),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: _buildActionButtons(leave),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStateText(String state) {
    Color textColor;
    switch (state) {
      case 'Approved':
        textColor = Colors.green;
        break;
      case 'To Approve':
      case 'Second Approval':
        textColor = Colors.orange.withOpacity(0.8);
        break;
      case 'Refused':
        textColor = Colors.red;
        break;
      default:
        textColor = Colors.blueGrey;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(state, style: TextStyle(color: textColor)),
    );
  }

  // Build Approve, Validate, Refuse buttons based on conditions
  List<Widget> _buildActionButtons(LeaveData leave) {
    List<Widget> buttons = [];

    if (leave.isApprove == true) {
      buttons.add(
        TextButton.icon(
          icon: Icon(Icons.thumb_up, color: Colors.green),
          label: Text("Approve", style: TextStyle(color: Colors.green)),
          onPressed: () {
            approveLeave(leave.leaveid!);
            debugPrint("leave.leaveid!:${leave.leaveid!}");
          },
        ),
      );
    }

    if (leave.isValidate == true) {
      buttons.add(
        TextButton.icon(
          // onPressed: () => validateLeave(leave.id!),
          icon: Icon(Icons.check, color: Colors.blue),
          label: Text("Validate", style: TextStyle(color: Colors.blue)),
          onPressed: () {
            validateLeave(leave.leaveid!);
            debugPrint("leave.leaveid!:${leave.leaveid!}");
          },
        ),
      );
    }

    if (leave.isRefuse == true) {
      buttons.add(
        TextButton.icon(
          // onPressed: () => rejectLeave(leave.id!),
          icon: Icon(Icons.close, color: Colors.red),
          label: Text("Refuse", style: TextStyle(color: Colors.red)),
          onPressed: () {
            rejectLeave(leave.leaveid!);
            debugPrint("leave.leaveid!:${leave.leaveid!}");
          },
        ),
      );
    }

    return buttons;
  }
}
